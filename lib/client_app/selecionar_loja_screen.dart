import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'vitrine_screen.dart';

class SelecionarLojaScreen extends StatefulWidget {
  const SelecionarLojaScreen({super.key});

  @override
  State<SelecionarLojaScreen> createState() => _SelecionarLojaScreenState();
}

class _SelecionarLojaScreenState extends State<SelecionarLojaScreen> {
  List<dynamic> lojas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarLojas();
  }

  Future<void> _carregarLojas() async {
    // Busca as lojas cadastradas no seu Django
    final url = Uri.parse("${Config.baseUrl}/api/lojas/?rede=the-king");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          lojas = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar lojas: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O Container com a imagem de fundo substitui a cor sólida do Scaffold
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            // O caminho exato da sua imagem. 
            image: const AssetImage('assets/fundo_theking.png'), 
            fit: BoxFit.cover, // Preenche a tela toda sem achatar a foto
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.65), // Película escura para dar destaque às letras
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Ícone ou Logo da Rede
                //const Icon(Icons.store_mall_directory, size: 80, color: Color(0xFF15A0A5)),
                const SizedBox(height: 20),
                const Text(
                  "Bem-vindo ao The King Petshop!",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Escolha a unidade mais próxima de você:",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 255, 255, 255)),
                ),
                const SizedBox(height: 30),
                
                isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 189, 120, 17)))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: lojas.length,
                          itemBuilder: (context, index) {
                            final loja = lojas[index];
                            return Card(
                              // Fundo preto com 70% de opacidade para a foto aparecer no fundo do botão!
                              color: Colors.black.withOpacity(0.7),
                              margin: const EdgeInsets.only(bottom: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                // Borda fina com a cor principal do sistema
                                side: const BorderSide(color: Color.fromARGB(255, 189, 120, 17), width: 1),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                leading: const Icon(Icons.location_on, color: Color.fromARGB(255, 189, 120, 17), size: 30),
                                title: Text(
                                  loja['nome'], // Ex: Botânico, Metrópoles
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                                ),
                                subtitle: (loja['bairro'] != null && loja['bairro'] != "") 
                                    ? Text(loja['bairro'], style: const TextStyle(color: Colors.grey))
                                    : null,
                                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
                                onTap: () {
                                  // 1. O App memoriza de qual loja o cliente é
                                  Config.lojaId = loja['id'];

                                  Config.nomeLoja = loja['nome'];
                                  
                                  // 2. Vai para a Vitrine (Sua tela principal)
                                  Navigator.pushReplacement(
                                    context, 
                                    MaterialPageRoute(builder: (context) => const VitrineScreen()) 
                                  );
                                },
                              ),
                            );
                          }
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}