import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'produto_model.dart';
import 'carrinho_screen.dart';
import 'meus_pedidos_screen.dart';
import 'smart_image_service.dart';
import '../config.dart';

class VitrineScreen extends StatefulWidget {
  const VitrineScreen({super.key});

  @override
  State<VitrineScreen> createState() => _VitrineScreenState();
}

class _VitrineScreenState extends State<VitrineScreen> {
  final String urlProdutos =
      "${Config.baseUrl}/api/produtos/?loja_id=${Config.lojaId}";

  List<Produto> produtosTodos = [];
  List<Produto> produtosFiltrados = [];

  bool isLoading = true;
  String erro = "";
  Map<int, int> carrinho = {};

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    buscarProdutos();
  }

  Future<void> buscarProdutos() async {
    try {
      final response = await http.get(Uri.parse(urlProdutos));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          produtosTodos = data.map((json) => Produto.fromJson(json)).toList();
          produtosFiltrados = produtosTodos;
          isLoading = false;
        });
      } else {
        setState(() {
          erro = "Erro servidor";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        erro = "Erro conexão";
        isLoading = false;
      });
    }
  }

  void _filtrarResultados(String query) {
    List<Produto> resultados = [];
    if (query.isEmpty) {
      resultados = produtosTodos;
    } else {
      resultados = produtosTodos
          .where(
            (prod) => prod.nome.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

    setState(() {
      produtosFiltrados = resultados;
    });
  }

  void adicionarAoCarrinho(Produto p) {
    int qtdNoCarrinho = carrinho[p.id] ?? 0;

    if (qtdNoCarrinho >= p.estoque) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ops! Só temos ${p.estoque} unidades em estoque."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      carrinho[p.id] = qtdNoCarrinho + 1;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Adicionado ao carrinho!"),
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("${Config.nomeLoja} 🍺"),
        backgroundColor: Colors.greenAccent[800],
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () async {
                  if (carrinho.isEmpty) return;
                  final pedidoFeito = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarrinhoScreen(
                        carrinho: carrinho,
                        todosProdutos: produtosTodos,
                      ),
                    ),
                  );
                  if (pedidoFeito == true) setState(() => carrinho.clear());
                },
              ),
              if (carrinho.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${carrinho.values.fold(0, (a, b) => a + b)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("Menu Cliente"),
              accountEmail: const Text(Config.nomeLoja),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.greenAccent),
              ),
              decoration: BoxDecoration(color: Colors.greenAccent[800]),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.blue),
              title: const Text("Meus Pedidos"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MeusPedidosScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _filtrarResultados(value),

                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Pesquisar produto...',

                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 10,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: produtosFiltrados.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhum produto encontrado.",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: produtosFiltrados.length,
                          itemBuilder: (context, index) {
                            final prod = produtosFiltrados[index];
                            String caminhoImagem =
                                SmartImageService.buscarPorId(prod.id);

                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15),
                                        ),
                                      ),
                                      child: caminhoImagem.isNotEmpty
                                          ? Image.asset(
                                              caminhoImagem,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[200],
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          color: Colors.grey,
                                                          size: 50,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                            )
                                          : Container(
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                  size: 50,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          child: Text(
                                            prod.nome,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "R\$ ${prod.preco.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            color: Colors.green[800],
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.greenAccent[800],
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () =>
                                                adicionarAoCarrinho(prod),
                                            child: const Text("ADICIONAR"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
