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
  
  final String apiUrl = "${Config.baseUrl}/cliente/pedidos/";
  
  List<dynamic> pedidos = [];
  bool isLoading = true;
  String? telefoneSalvo;

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
        Uri.parse("$apiUrl?telefone=$tel&loja_id=${Config.lojaId}")
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

  
  Color getCorStatus(String status) {
    if (status == 'PENDENTE') return Colors.amber;
    if (status == 'EM_PREPARACAO') return Colors.blue;
    if (status == 'SAIU_ENTREGA') return Colors.purple;
    if (status == 'CONCLUIDO') return Colors.green;
    if (status == 'CANCELADO') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Pedidos"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : telefoneSalvo == null
              ? const Center(child: Text("Você ainda não fez nenhum pedido."))
              : pedidos.isEmpty
                  ? const Center(child: Text("Nenhum pedido encontrado nesta loja."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: pedidos.length,
                      itemBuilder: (context, index) {
                        final pedido = pedidos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Pedido #${pedido['id']}", 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(pedido['data'], style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                const Divider(),
                                ...pedido['itens'].map<Widget>((item) => Text(item)).toList(),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Total: R\$ ${pedido['total'].toStringAsFixed(2)}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                    
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: getCorStatus(pedido['cor_status']),
                                        borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: Text(pedido['status'], 
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}