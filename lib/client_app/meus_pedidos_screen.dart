import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class MeusPedidosScreen extends StatefulWidget {
  const MeusPedidosScreen({super.key});

  @override
  State<MeusPedidosScreen> createState() => _MeusPedidosScreenState();
}

class _MeusPedidosScreenState extends State<MeusPedidosScreen> {
  final String apiUrl = "${Config.baseUrl}/api/cliente/pedidos/";

  List<dynamic> pedidos = [];
  bool isLoading = true;
  String? telefoneSalvo;

  // --- CORES DO TEMA GLASSMORPHISM E PROFUNDIDADE ---
  final Color corFundoApp = const Color(0xFF121212); // Cinza super profundo neutro
  final Color corFundoCard = const Color(0xFF1E1E1E); // Cinza levemente mais claro
  final Color corBordaVidro = Colors.white.withOpacity(0.08); // Borda de vidro
  final Color corAcento = const Color(0xFF4D96FF); // Azul Elétrico premium
  final Color corAlerta = const Color(0xFFFF4757); // Vermelho coral

  @override
  void initState() {
    super.initState();
    carregarPedidos();
  }

  Future<void> carregarPedidos() async {
    final prefs = await SharedPreferences.getInstance();
    String? tel = prefs.getString('cliente_telefone');

    if (tel == null || tel.isEmpty) {
      setState(() {
        isLoading = false;
        telefoneSalvo = null;
      });
      return;
    }

    setState(() => telefoneSalvo = tel);

    try {
      final response = await http.get(
        Uri.parse("$apiUrl?telefone=$tel&loja_id=${Config.lojaId}"),
      );

      if (response.statusCode == 200) {
        setState(() {
          pedidos = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erro: $e");
      setState(() => isLoading = false);
    }
  }

  // Cores de status adaptadas para brilhar no tema escuro!
  Color getCorStatus(String status) {
    if (status == 'PENDENTE') return Colors.amberAccent;
    if (status == 'EM_PREPARACAO') return corAcento; // Usa o azul elétrico do app
    if (status == 'SAIU_ENTREGA') return Colors.purpleAccent;
    if (status == 'CONCLUIDO') return const Color(0xFF00E676); // Verde neon para sucesso
    if (status == 'CANCELADO') return corAlerta; // Vermelho coral
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundoApp, // Fundo ultra escuro do app
      appBar: AppBar(
        title: const Text(
          "Meus Pedidos", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5)
        ),
        backgroundColor: corFundoApp, // Integrado com o fundo
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Seta de voltar branca
        bottom: PreferredSize(
          // Linha fininha de vidro separando o AppBar do conteúdo
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: corBordaVidro, height: 1.0),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: corAcento))
          : telefoneSalvo == null
          ? const Center(child: Text("Você ainda não fez nenhum pedido.", style: TextStyle(color: Colors.white54, fontSize: 16)))
          : pedidos.isEmpty
          ? const Center(child: Text("Nenhum pedido encontrado nesta loja.", style: TextStyle(color: Colors.white54, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];
                
                // Trocamos o Card nativo por um Container para dar o efeito de Vidro
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: corFundoCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: corBordaVidro, width: 1.5), // Borda fina de vidro
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4)
                      )
                    ]
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Pedido #${pedido['id']}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              pedido['data'],
                              style: const TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                        Divider(color: corBordaVidro, height: 24, thickness: 1), // Divisor translúcido
                        
                        // Lista de itens do pedido com bolinhas para melhor leitura
                        ...pedido['itens'].map<Widget>((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            "• $item", 
                            style: const TextStyle(color: Colors.white70, fontSize: 14)
                          ),
                        )).toList(),
                        
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total: R\$ ${pedido['total'].toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: corAcento, // Destaque Azul Elétrico no preço
                                fontSize: 16,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: getCorStatus(pedido['cor_status']).withOpacity(0.15), // Fundo transparente da cor do status
                                border: Border.all(color: getCorStatus(pedido['cor_status']).withOpacity(0.5)), // Bordinha do status
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                pedido['status'],
                                style: TextStyle(
                                  color: getCorStatus(pedido['cor_status']), // Texto na cor viva
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}