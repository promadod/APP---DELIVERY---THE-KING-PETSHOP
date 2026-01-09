class Produto {
  final int id;
  final String nome;
  final double preco;
  final int estoque;

  Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.estoque,
  });

  
  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome_venda'], 
      
      preco: double.parse(json['preco_venda'].toString()),
      estoque: json['estoque_atual'] ?? 0,
    );
  }

  

  
  String get imagemAsset {
    
    String nomeLimpo = nome.toLowerCase();

    
    nomeLimpo = _removerAcentos(nomeLimpo);

    
    nomeLimpo = nomeLimpo.replaceAll(' ', '_');

    
    return "assets/produtos/$nomeLimpo.png";
  }

  
  String _removerAcentos(String texto) {
    var comAcento =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    var semAcento =
        'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

    for (int i = 0; i < comAcento.length; i++) {
      texto = texto.replaceAll(comAcento[i], semAcento[i]);
    }
    return texto;
  }
}
