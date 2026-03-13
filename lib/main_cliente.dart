import 'package:flutter/material.dart';
import 'client_app/smart_image_service.dart'; 
import 'client_app/vitrine_screen.dart'; // <--- AQUI! Trouxemos a vitrine de volta
import 'client_app/selecionar_loja_screen.dart'; 
import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SmartImageService.carregarDicionario();

  runApp(const MagnoAppCliente());
}

class MagnoAppCliente extends StatelessWidget {
  const MagnoAppCliente({super.key});

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
      
      // A MÁGICA INTELIGENTE:
      home: Config.isRede ? const SelecionarLojaScreen() : const VitrineScreen(),
    );
  }
}