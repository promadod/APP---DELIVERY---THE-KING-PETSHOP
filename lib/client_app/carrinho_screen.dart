import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'produto_model.dart';
import '../config.dart'; 

const Color minhaCorPadrao = Color(0xFF15A0A5);

class CarrinhoScreen extends StatefulWidget {
  final Map<int, int> carrinho;
  final List<Produto> todosProdutos;

  const CarrinhoScreen({
    super.key,
    required this.carrinho,
    required this.todosProdutos,
  });

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  
  final String chavePixLoja = "21986855874"; 
  final String nomeBeneficiario = Config.nomeLoja; 

  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _obsController = TextEditingController();
  final _trocoController = TextEditingController();

  String formaPagamento = "DINHEIRO";
  bool enviando = false;
  bool buscandoCliente = false;
  
  
  double valorEntrega = 5.00; 

  @override
  void initState() {
    super.initState();
    _carregarDadosLocais();
    _buscarTaxaEntrega(); 
  }

  
  Future<void> _buscarTaxaEntrega() async {
    try {
      
      final response = await http.get(Uri.parse("${Config.baseUrl}/taxa_entrega/?loja_id=${Config.lojaId}"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          valorEntrega = double.parse(data['taxa'].toString());
        });
      }
    } catch (e) {
      print("Erro ao buscar taxa: $e");
    }
  }

  Future<void> _carregarDadosLocais() async {
    final prefs = await SharedPreferences.getInstance();
    String? telefoneSalvo = prefs.getString('cliente_telefone');

    if (telefoneSalvo != null && telefoneSalvo.isNotEmpty) {
      _telefoneController.text = telefoneSalvo;
      _buscarClienteNoDjango(telefoneSalvo);
    }
  }

  Future<void> _buscarClienteNoDjango(String telefone) async {
    if (telefone.length < 8) return;

    setState(() => buscandoCliente = true);

    try {
      
      final response = await http.get(
        Uri.parse("${Config.baseUrl}/cliente/buscar/?telefone=$telefone&loja_id=${Config.lojaId}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['encontrou'] == true) {
          setState(() {
            _nomeController.text = data['nome'];
            _enderecoController.text = data['endereco'];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Seus dados foram encontrados! 👋"),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print("Erro ao buscar cliente: $e");
    } finally {
      setState(() => buscandoCliente = false);
    }
  }

  Future<void> _salvarDadosLocais() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cliente_telefone', _telefoneController.text);
  }

  double get valorTotal {
    double total = 0;
    widget.carrinho.forEach((id, qtd) {
      
      try {
        final produto = widget.todosProdutos.firstWhere((p) => p.id == id);
        total += produto.preco * qtd;
      } catch (e) {
        print("Produto $id não encontrado na lista.");
      }
    });
    return total;
  }

  void copiarChavePix() {
    Clipboard.setData(ClipboardData(text: chavePixLoja));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Chave PIX copiada! Agora pague no seu banco."),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> enviarPedido() async {
    if (!_formKey.currentState!.validate()) return;

    if (formaPagamento != 'DINHEIRO' && _trocoController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Troco é apenas para Dinheiro!')),
      );
      return;
    }

    setState(() => enviando = true);

    await _salvarDadosLocais();

    List<Map<String, dynamic>> itensParaEnviar = [];
    widget.carrinho.forEach((id, qtd) {
      itensParaEnviar.add({"id_produto": id, "quantidade": qtd});
    });

    String obsFinal = _obsController.text;
    if (formaPagamento == 'DINHEIRO' && _trocoController.text.isNotEmpty) {
      obsFinal += " (Troco p/: R\$ ${_trocoController.text})";
    }
    if (formaPagamento == 'PIX') {
      obsFinal += " (Pagamento via PIX)";
    }

    Map<String, dynamic> pedidoJson = {
      "loja_id": Config.lojaId, 
      "cliente_nome": _nomeController.text,
      "telefone": _telefoneController.text,
      "total": valorTotal, 
      "endereco": _enderecoController.text,
      "pagamento": formaPagamento,
      "obs": obsFinal,
      "itens": itensParaEnviar,
      "taxa_entrega": valorEntrega,
    };

    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/api/pedido/criar/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(pedidoJson),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        
        
        Navigator.of(context).pop(true);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Pedido Enviado! 🚀"),
            content: const Text(
              "Seu pedido chegou na loja e já vamos separar.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else if (response.statusCode == 403) {
        
        var dadosErro = jsonDecode(utf8.decode(response.bodyBytes));
        String mensagem = dadosErro['erro'] ?? 'Loja Fechada';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagem, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: Colors.red, 
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        throw Exception("Erro ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Falha ao enviar: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Finalizar Pedido"),
        backgroundColor: minhaCorPadrao,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const Text(
                "Resumo:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.carrinho.length,
                  itemBuilder: (ctx, i) {
                    int id = widget.carrinho.keys.elementAt(i);
                    int qtd = widget.carrinho.values.elementAt(i);
                    
                    
                    final prod = widget.todosProdutos.firstWhere(
                      (p) => p.id == id,
                      orElse: () => Produto(id: 0, nome: "Item Removido", preco: 0.0, estoque: 0),
                    );

                    return ListTile(
                      title: Text(prod.nome),
                      subtitle: Text(
                        "${qtd}x R\$ ${prod.preco.toStringAsFixed(2)}",
                      ),
                      trailing: Text(
                        "R\$ ${(prod.preco * qtd).toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  
                  "Total + Entrega: R\$ ${(valorTotal + valorEntrega).toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[400],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              
              const Text(
                "Seus Dados:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _telefoneController,
                      decoration: const InputDecoration(
                        labelText: "WhatsApp / Telefone",
                        prefixIcon: Icon(Icons.phone),
                        hintText: "Digite para buscar...",
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
                      onFieldSubmitted: (valor) =>
                          _buscarClienteNoDjango(valor),
                    ),
                  ),
                  if (buscandoCliente)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.blue),
                      onPressed: () =>
                          _buscarClienteNoDjango(_telefoneController.text),
                    ),
                ],
              ),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: "Seu Nome",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
              ),
              TextFormField(
                controller: _enderecoController,
                decoration: const InputDecoration(
                  labelText: "Endereço Completo",
                  prefixIcon: Icon(Icons.map),
                ),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
              ),

              const SizedBox(height: 20),

              
              const Text(
                "Pagamento:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: formaPagamento,
                items: ["DINHEIRO", "PIX", "CREDITO", "DEBITO"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => formaPagamento = v!),
              ),

              

              if (formaPagamento == "PIX")
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.pix, color: minhaCorPadrao),
                          SizedBox(width: 10),
                          Text(
                            "Pague via PIX (Copia e Cola)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Beneficiário: $nomeBeneficiario",
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                chavePixLoja,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: copiarChavePix,
                            icon: const Icon(Icons.copy),
                            label: const Text("Copiar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: minhaCorPadrao,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Copie a chave, pague no seu banco e envie o comprovante se necessário.",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey, 
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              if (formaPagamento == "DINHEIRO")
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextFormField(
                    controller: _trocoController,
                    decoration: const InputDecoration(
                      labelText: "Troco para quanto? (Ex: 50.00)",
                      prefixIcon: Icon(Icons.money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

              const SizedBox(height: 10),
              TextFormField(
                controller: _obsController,
                decoration: const InputDecoration(
                  labelText: "Observação",
                  prefixIcon: Icon(Icons.note),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: minhaCorPadrao,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: enviando ? null : enviarPedido,
                  child: enviando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("ENVIAR PEDIDO", style: TextStyle(color: Colors.white)),
                          SizedBox(width: 10),
                          Icon(Icons.rocket_launch, color: Colors.white),
                        ],
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}