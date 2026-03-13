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

  // --- CORES DO TEMA GLASSMORPHISM E PROFUNDIDADE ---
  final Color corFundoApp = const Color(
    0xFF121212,
  ); // Cinza super profundo neutro
  final Color corFundoCard = const Color(
    0xFF1E1E1E,
  ); // Cinza levemente mais claro para dar "elevação"
  final Color corBordaVidro = Colors.white.withOpacity(
    0.08,
  ); // Borda quase transparente simulando vidro
  final Color corAcento = const Color(
    0xFF4D96FF,
  ); // Azul Elétrico premium (Apple-like)
  final Color corAlerta = const Color(
    0xFFFF4757,
  ); // Vermelho coral para o crachá do carrinho

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
          content: Text(
            "Ops! Só temos ${p.estoque} unidades em estoque.",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: corAlerta,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      carrinho[p.id] = qtdNoCarrinho + 1;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Adicionado ao carrinho!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: corAcento, // Azul elétrico no aviso
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoApp, // Fundo ultra escuro
      appBar: AppBar(
        title: Text(
          "${Config.nomeLoja} ",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: corFundoApp,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ), // Ícone vazado moderno
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
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: corAlerta, // Vermelho elegante
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: corAlerta.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${carrinho.values.fold(0, (a, b) => a + b)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: corFundoApp,
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text(
                "Menu Cliente",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                Config.nomeLoja,
                style: TextStyle(color: corAcento),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: corFundoCard,
                child: Icon(Icons.person, color: corAcento),
              ),
              decoration: BoxDecoration(
                color: corFundoApp,
                border: Border(
                  bottom: BorderSide(color: corBordaVidro, width: 1),
                ), // Borda separadora de vidro
              ),
            ),
            ListTile(
              leading: Icon(Icons.receipt_long, color: corAcento),
              title: const Text(
                "Meus Pedidos",
                style: TextStyle(color: Colors.white70),
              ),
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
          ? Center(child: CircularProgressIndicator(color: corAcento))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 10.0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _filtrarResultados(value),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar produto...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white54,
                      ),
                      filled: true,
                      fillColor: corFundoCard,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: corBordaVidro,
                          width: 1,
                        ), // Borda de vidro
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: corAcento,
                          width: 1.5,
                        ), // Foca em azul
                      ),
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
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 5, 14, 15),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                          itemCount: produtosFiltrados.length,
                          itemBuilder: (context, index) {
                            final prod = produtosFiltrados[index];
                            String caminhoImagem =
                                SmartImageService.buscarPorId(prod.id);

                            Widget iconeFallback = Container(
                              color: const Color(
                                0xFFF5F5F5,
                              ), // Branco gelo para destacar a foto
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey[400],
                                  size: 40,
                                ),
                              ),
                            );

                            Widget widgetImagem;

                            if (prod.imagemUrl != null) {
                              widgetImagem = Image.network(
                                prod.imagemUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  if (caminhoImagem.isNotEmpty) {
                                    return Image.asset(
                                      caminhoImagem,
                                      fit: BoxFit.contain,
                                      errorBuilder: (ctx, err, stack) =>
                                          iconeFallback,
                                    );
                                  }
                                  return iconeFallback;
                                },
                              );
                            } else {
                              if (caminhoImagem.isNotEmpty) {
                                widgetImagem = Image.asset(
                                  caminhoImagem,
                                  fit: BoxFit.contain,
                                  errorBuilder: (ctx, err, stack) =>
                                      iconeFallback,
                                );
                              } else {
                                widgetImagem = iconeFallback;
                              }
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: corFundoCard,
                                borderRadius: BorderRadius.circular(
                                  16,
                                ), // Bordas um pouco mais arredondadas (estilo iOS)
                                border: Border.all(
                                  color: corBordaVidro,
                                  width: 1.5,
                                ), // Borda fina de "vidro"
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(14),
                                        ),
                                      ),
                                      child: widgetImagem,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 36,
                                          child: Text(
                                            prod.nome,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight
                                                  .w600, // Menos bold, mais elegante
                                              fontSize: 13,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "R\$ ${prod.preco.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            color:
                                                corAcento, // Azul elétrico super nítido
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 36,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              // A MÁGICA DO GLASSMORPHISM NO BOTÃO: Fundo levemente transparente
                                              backgroundColor: corAcento
                                                  .withOpacity(0.15),
                                              foregroundColor: corAcento,
                                              side: BorderSide(
                                                color: corAcento.withOpacity(
                                                  0.4,
                                                ),
                                                width: 1,
                                              ), // Borda sutil
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              elevation: 0,
                                            ),
                                            onPressed: () =>
                                                adicionarAoCarrinho(prod),
                                            child: const Text(
                                              "ADICIONAR",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
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
