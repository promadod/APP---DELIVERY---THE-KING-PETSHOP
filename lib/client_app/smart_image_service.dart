import 'package:flutter/services.dart';

class SmartImageService {
  static List<String> _arquivosDisponiveis = [];

  static Future<void> carregarDicionario() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _arquivosDisponiveis = manifest
          .listAssets()
          .where((key) => key.contains('assets/produtos/'))
          .toList();
      print("🧠 Imagens carregadas: ${_arquivosDisponiveis.length}");
    } catch (e) {
      print("❌ Erro ao ler imagens: $e");
    }
  }

  static String buscarPorId(int id) {
    // Monta o caminho esperado: assets/produtos/986.png
    String caminhoExato = "assets/produtos/$id.png";

    // Verifica se esse arquivo REALMENTE existe na lista carregada
    if (_arquivosDisponiveis.contains(caminhoExato)) {
      return caminhoExato;
    }

    // Se não achou pelo ID, retorna vazio
    return "";
  }
}
