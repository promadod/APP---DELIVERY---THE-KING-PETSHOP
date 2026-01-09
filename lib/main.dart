import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'motoboy_screen.dart';
import 'client_app/vitrine_screen.dart';
import 'client_app/smart_image_service.dart'; 
import 'config.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega o "Dicionário" de imagens
  await SmartImageService.carregarDicionario();

  runApp(const MagnoApp());
}

class MagnoApp extends StatelessWidget {
  const MagnoApp({super.key});

  // ---  WHITE LABEL ---
  static const String tipoApp = String.fromEnvironment('TIPO_APP', defaultValue: 'CLIENTE');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.nomeLoja,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        primaryColor: const Color(0xFF15A0A5),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF15A0A5),
          secondary: Color(0xFF15A0A5),
        ),
      ),
      
      home: tipoApp == 'MOTOBOY' 
          ? const LoginPage() 
          : const VitrineScreen(),
    );
  }
}


// TELA DE LOGIN (Usada apenas para Motoboy/Admin)


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _fazerLogin() async {
    setState(() => _isLoading = true);

    final String url = '${Config.baseUrl}/login/';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'username': _userController.text,
          'password': _passController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bem-vindo, ${data['nome']}!'),
            backgroundColor: Colors.green,
          ),
        );

        if (data['is_superuser'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Acesso Admin Mobile não configurado nesta versão.'))
          );
        } else {
          // Login Motoboy
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MotoboyScreen(userData: data),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário ou senha incorretos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.orange),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Image.asset(
                  'assets/logocarlinho1.PNG',
                  width: MediaQuery.of(context).size.width * 0.90,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              const SizedBox(height: 40),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15A0A5),
                  ),
                  onPressed: _isLoading ? null : _fazerLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'ENTRAR',
                          style: TextStyle(fontSize: 18, color: Colors.white),
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