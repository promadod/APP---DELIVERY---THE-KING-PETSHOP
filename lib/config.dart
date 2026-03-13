class Config {
  // 1. O  SERVIDOR
  static const String ipServidor = "127.0.0.1:8000"; //"192.168.11.144:8000";
  static const String baseUrl =  "https://preapdev.pythonanywhere.com"; //"http://127.0.0.1:8000";

  // Se for gerar o APK do The King, mude para true. 
  // Se for gerar o APK da Magno Distribuidora, mude para false.
  static const bool isRede = true; 

  // Se isRede for false, o App já entra direto nesta loja sem perguntar nada:
  static int lojaId = 3; 

  static String nomeLoja = "The King";
}