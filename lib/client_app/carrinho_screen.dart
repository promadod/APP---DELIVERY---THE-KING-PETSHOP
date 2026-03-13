import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'produto_model.dart';
import '../config.dart'; 

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
  
  bool isDelivery = true; 
  double valorEntrega = 5.00; 

  // --- CORES UNIFICADAS COM A VITRINE (AZUL MEIA-NOITE E ARDÓSIA) ---
  final Color corFundoApp = const Color(0xFF0A192F); // Fundo Azul Meia-Noite (Igual à Vitrine)
  final Color corFundoCard = const Color(0xFF172A45); // Azul Ardósia (Fundo dos cards)
  final Color corAcento = const Color(0xFF4D96FF); // Azul Elétrico Brilhante (Destaques, ícones e bordas)
  final Color corAlerta = const Color(0xFFFF4757); // Vermelho Coral (Deletar itens/erros)
  final Color corSucesso = const Color(0xFF4D96FF); // Verde Neon (Sucesso/Pix)

  @override
  void initState() {
    super.initState();
    _carregarDadosLocais();
    _buscarTaxaEntrega(); 
  }

  Future<void> _buscarTaxaEntrega() async {
    try {
      final response = await http.get(Uri.parse("${Config.baseUrl}/api/taxa_entrega/?loja_id=${Config.lojaId}"));
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
        Uri.parse("${Config.baseUrl}/api/cliente/buscar/?telefone=$telefone&loja_id=${Config.lojaId}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['encontrou'] == true) {
          setState(() {
            _nomeController.text = data['nome'];
            _enderecoController.text = data['endereco'];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Seus dados foram encontrados! 👋", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: corAcento,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
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

  double get valorTotalProdutos {
    double total = 0;
    widget.carrinho.forEach((id, qtd) {
      try {
        final produto = widget.todosProdutos.firstWhere((p) => p.id == id);
        total += produto.preco * qtd;
      } catch (e) {}
    });
    return total;
  }

  void _incrementar(int id, int estoqueMax) {
    if (widget.carrinho[id]! < estoqueMax) {
      setState(() {
        widget.carrinho[id] = widget.carrinho[id]! + 1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Estoque máximo atingido ($estoqueMax)", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _decrementar(int id) {
    if (widget.carrinho[id]! > 1) {
      setState(() {
        widget.carrinho[id] = widget.carrinho[id]! - 1;
      });
    } else {
      _removerItem(id);
    }
  }

  void _removerItem(int id) {
    setState(() {
      widget.carrinho.remove(id);
    });
    if (widget.carrinho.isEmpty) {
      Navigator.pop(context, true); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Seu carrinho está vazio.", style: TextStyle(color: Colors.white)), backgroundColor: corAlerta, behavior: SnackBarBehavior.floating),
      );
    }
  }

  void copiarChavePix() {
    Clipboard.setData(ClipboardData(text: chavePixLoja));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Chave PIX copiada! Agora pague no seu banco.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: corSucesso,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> enviarPedido() async {
    if (!_formKey.currentState!.validate()) return;

    if (formaPagamento != 'DINHEIRO' && _trocoController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Troco é apenas para Dinheiro!', style: TextStyle(color: Colors.white)), backgroundColor: corAlerta, behavior: SnackBarBehavior.floating),
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

    double taxaFinal = isDelivery ? valorEntrega : 0.0;
    double totalComTaxa = valorTotalProdutos + taxaFinal;
    String enderecoFinal = isDelivery ? _enderecoController.text : "Retirada na Loja";

    Map<String, dynamic> pedidoJson = {
      "loja_id": Config.lojaId, 
      "cliente_nome": _nomeController.text,
      "telefone": _telefoneController.text,
      "total": totalComTaxa, 
      "endereco": enderecoFinal,
      "pagamento": formaPagamento,
      "obs": obsFinal,
      "itens": itensParaEnviar,
      "taxa_entrega": taxaFinal,
      "eh_entrega": isDelivery
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
            backgroundColor: corFundoCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: corAcento.withOpacity(0.5))),
            title: const Text("Pedido Enviado! 🚀", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Text(
              isDelivery 
                ? "Seu pedido chegou na loja e já vamos separar para entrega."
                : "Seu pedido foi recebido! Pode vir buscar na loja.",
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("OK", style: TextStyle(color: corAcento, fontWeight: FontWeight.bold)),
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
            backgroundColor: corAlerta, 
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        var dadosErro = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(dadosErro['erro'] ?? "Erro ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Falha ao enviar: $e", style: const TextStyle(color: Colors.white)), backgroundColor: corAlerta, behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => enviando = false);
    }
  }

  // ESTILO DE INPUTS: Fundo azul escuro (app), borda sutil, foco vibrante
  InputDecoration _estiloInput(String label, IconData icone) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icone, color: corAcento), // Destaque Azul Elétrico nos ícones
      filled: true,
      fillColor: corFundoApp, // Textfield tem a mesma cor do fundo do app para dar profundidade no card
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: corAcento.withOpacity(0.3), width: 1), // Borda fina azulada
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: corAcento, width: 1.5), // Borda viva ao clicar
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    double taxaAtiva = isDelivery ? valorEntrega : 0.0;
    double totalExibicao = valorTotalProdutos + taxaAtiva;

    return Scaffold(
      backgroundColor: corFundoApp,
      appBar: AppBar(
        title: const Text("Seu Carrinho", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: corFundoApp,
        elevation: 0,
        iconTheme: IconThemeData(color: corAcento), // Seta de voltar azulada
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // 1. BLOCO: PRODUTOS
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text("Itens do Pedido", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: corFundoCard, // Fundo Azul Ardósia
                  border: Border.all(color: corAcento.withOpacity(0.2)), 
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.carrinho.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: corAcento.withOpacity(0.1)), 
                  itemBuilder: (ctx, i) {
                    int id = widget.carrinho.keys.elementAt(i);
                    int qtd = widget.carrinho.values.elementAt(i);
                    final prod = widget.todosProdutos.firstWhere(
                      (p) => p.id == id,
                      orElse: () => Produto(id: 0, nome: "Removido", preco: 0.0, estoque: 0),
                    );

                    return Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(prod.nome, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text("R\$ ${(prod.preco * qtd).toStringAsFixed(2)}", style: TextStyle(color: corAcento, fontWeight: FontWeight.w800, fontSize: 15)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.white54),
                                onPressed: () => _decrementar(id),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('$qtd', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline, color: corAcento),
                                onPressed: () => _incrementar(id, prod.estoque),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: corAlerta),
                            onPressed: () => _removerItem(id),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              // 2. BLOCO: ENTREGA OU RETIRADA
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text("Como deseja receber?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => isDelivery = true),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isDelivery ? corAcento.withOpacity(0.15) : corFundoCard,
                          border: Border.all(color: isDelivery ? corAcento : corAcento.withOpacity(0.2), width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.motorcycle, color: isDelivery ? corAcento : Colors.white54, size: 20),
                            const SizedBox(width: 8),
                            Text("Entrega", style: TextStyle(color: isDelivery ? corAcento : Colors.white54, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => isDelivery = false),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: !isDelivery ? corAcento.withOpacity(0.15) : corFundoCard,
                          border: Border.all(color: !isDelivery ? corAcento : corAcento.withOpacity(0.2), width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.storefront, color: !isDelivery ? corAcento : Colors.white54, size: 20),
                            const SizedBox(width: 8),
                            Text("Retirar", style: TextStyle(color: !isDelivery ? corAcento : Colors.white54, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // 3. BLOCO: DADOS DO CLIENTE
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text("Seus Dados", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: corFundoCard, // Fundo Azul Ardósia
                  border: Border.all(color: corAcento.withOpacity(0.2)), 
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _telefoneController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _estiloInput("WhatsApp / Telefone", Icons.phone),
                            keyboardType: TextInputType.phone,
                            validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
                            onFieldSubmitted: (valor) => _buscarClienteNoDjango(valor),
                          ),
                        ),
                        if (buscandoCliente)
                          Padding(padding: const EdgeInsets.all(12.0), child: CircularProgressIndicator(color: corAcento))
                        else
                          IconButton(
                            icon: Icon(Icons.search, color: corAcento, size: 28),
                            onPressed: () => _buscarClienteNoDjango(_telefoneController.text),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nomeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _estiloInput("Seu Nome", Icons.person),
                      validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
                    ),
                    
                    if (isDelivery) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _enderecoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _estiloInput("Endereço Completo", Icons.map),
                        maxLines: 2,
                        validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
                      ),
                    ]
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // 4. BLOCO: PAGAMENTO E OBSERVAÇÕES
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text("Pagamento e Detalhes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: corFundoCard, // Fundo Azul Ardósia
                  border: Border.all(color: corAcento.withOpacity(0.2)), 
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: formaPagamento,
                      dropdownColor: corFundoCard, // Fundo das opções do dropdown
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: _estiloInput("Forma de Pagamento", Icons.payment),
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
                          color: corSucesso.withOpacity(0.1),
                          border: Border.all(color: corSucesso.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.pix, color: corSucesso),
                                const SizedBox(width: 10),
                                const Text("Pague via PIX (Copia e Cola)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text("Beneficiário: $nomeBeneficiario", style: const TextStyle(fontSize: 13, color: Colors.white70)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      chavePixLoja,
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: corSucesso),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: copiarChavePix,
                                  icon: const Icon(Icons.copy, size: 18),
                                  label: const Text("Copiar"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: corSucesso.withOpacity(0.2), 
                                    foregroundColor: corSucesso,
                                    elevation: 0,
                                    side: BorderSide(color: corSucesso.withOpacity(0.5)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    if (formaPagamento == "DINHEIRO")
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextFormField(
                          controller: _trocoController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _estiloInput("Troco para quanto? (Ex: 50.00)", Icons.money),
                          keyboardType: TextInputType.number,
                        ),
                      ),

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _obsController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _estiloInput("Observação do Pedido", Icons.note),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              
              // 5. BLOCO: RESUMO FINAL
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: corFundoCard, 
                  border: Border.all(color: corAcento.withOpacity(0.4), width: 1.5), // Borda mais forte no resumo
                  borderRadius: BorderRadius.circular(14)
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Subtotal:", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        Text("R\$ ${valorTotalProdutos.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Taxa de Entrega:", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        Text(isDelivery ? "R\$ ${taxaAtiva.toStringAsFixed(2)}" : "Grátis", 
                             style: TextStyle(color: isDelivery ? Colors.white : corSucesso, fontSize: 16, fontWeight: isDelivery ? FontWeight.w600 : FontWeight.bold)),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: corAcento.withOpacity(0.2), height: 1), 
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("TOTAL:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text("R\$ ${totalExibicao.toStringAsFixed(2)}", 
                             style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: corAcento)), // Preço final em Azul Elétrico
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // BOTÃO FINALIZAR
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corAcento, // Fundo Azul Elétrico
                    foregroundColor: Colors.white, // Letra Branca
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 5,
                    shadowColor: corAcento.withOpacity(0.5),
                  ),
                  onPressed: enviando ? null : enviarPedido,
                  child: enviando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("FINALIZAR COMPRA"),
                          SizedBox(width: 10),
                          Icon(Icons.check_circle_outline, size: 22),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}