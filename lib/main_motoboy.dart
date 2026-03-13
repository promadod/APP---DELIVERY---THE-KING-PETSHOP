import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'motoboy_screen.dart'; 
import 'client_app/smart_image_service.dart';
import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregamos o dicionário também no app do motoboy, caso precise ver fotos
  await SmartImageService.carregarDicionario();

  runApp(const MagnoAppMotoboy());
}

class MagnoAppMotoboy extends StatelessWidget {
  const MagnoAppMotoboy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Área do Entregador',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        
        primaryColor: const Color(0xFF2196F3),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2196F3),
          secondary: Color(0xFF2196F3),
        ), 
      ),
      
      home: const LoginPage(),
    );
  }
}

// --- TELA DE LOGIN ---

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

    final String url = '${Config.baseUrl}/api/login/';

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
            const SnackBar(
              content: Text(
                'Acesso Admin Mobile não configurado nesta versão.',
              ),
            ),
          );
        } else {
          // SUCESSO: Vai para a tela do Motoboy
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
        SnackBar(
          content: Text('Erro de Conexão: $e'),
          backgroundColor: Colors.orange,
        ),
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
              const Text(
                "ÁREA DO ENTREGADOR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(
                  labelText: 'Usuário (CPF)',
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
                    backgroundColor: const Color(0xFF2196F3), // Azul Motoboy
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
