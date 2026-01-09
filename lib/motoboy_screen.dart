import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../config.dart'; 

class MotoboyScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MotoboyScreen({super.key, required this.userData});

  @override
  State<MotoboyScreen> createState() => _MotoboyScreenState();
}

class _MotoboyScreenState extends State<MotoboyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Listas de Dados
  List<dynamic> _entregasDisponiveis = [];
  List<dynamic> _minhasEntregas = [];

  // Dados do Extrato
  List<dynamic> _historicoGanhos = [];
  double _totalGanhos = 0.0;
  int _qtdEntregasFeitas = 0;

  // Controles
  bool _isLoading = false;
  Timer? _timerAtualizacao;
  int _quantidadeAnterior = 0;

  // Filtro do Extrato (Apenas o básico agora)
  String _filtroSelecionado = 'hoje'; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarDados();
    _carregarExtrato(); 

    // Robô de atualização automática
    _timerAtualizacao = Timer.periodic(const Duration(seconds: 30), (timer) {
      _buscarEntregasDisponiveis(silencioso: true);
    });
  }

  @override
  void dispose() {
    _timerAtualizacao?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // --- API ---

  Future<void> _carregarDados() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.wait([_buscarEntregasDisponiveis(), _buscarMinhasEntregas()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _carregarExtrato() async {
    // API simplificada: manda período e loja
    String url = '${Config.baseUrl}/entregas/ganhos/?periodo=$_filtroSelecionado&loja_id=${Config.lojaId}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Token ${widget.userData['token']}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          _totalGanhos = (data['total'] as num).toDouble(); 
          _qtdEntregasFeitas = data['quantidade'];
          _historicoGanhos = data['historico'];
        });
      }
    } catch (e) {
      print("Erro extrato: $e");
    }
  }

  // --- FUNÇÕES DE UTILIDADE (Maps, Zap, Busca) ---

  Future<void> _abrirMapa(String endereco) async {
    final query = Uri.encodeComponent(endereco);
    final googleUrl = "https://www.google.com/maps/search/?api=1&query=$query";
    final Uri uri = Uri.parse(googleUrl);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch map';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao abrir mapa'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _abrirWhatsApp(String? url) async {
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sem telefone!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      if (!await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Erro Zap';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao abrir WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _buscarEntregasDisponiveis({bool silencioso = false}) async {
    try {
      // Adicionado loja_id
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/entregas/disponiveis/?loja_id=${Config.lojaId}'),
        headers: {'Authorization': 'Token ${widget.userData['token']}'},
      );
      if (response.statusCode == 200) {
        List<dynamic> novaLista = jsonDecode(utf8.decode(response.bodyBytes));
        if (!silencioso &&
            novaLista.length > _quantidadeAnterior &&
            _quantidadeAnterior != 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔔 NOVA ENTREGA DISPONÍVEL!'),
              backgroundColor: Colors.purple,
            ),
          );
        }
        _quantidadeAnterior = novaLista.length;
        if (mounted) setState(() => _entregasDisponiveis = novaLista);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _buscarMinhasEntregas() async {
    try {
      // Adicionado loja_id
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/entregas/minhas/?loja_id=${Config.lojaId}'),
        headers: {'Authorization': 'Token ${widget.userData['token']}'},
      );
      if (response.statusCode == 200) {
        if (mounted)
          setState(
            () => _minhasEntregas = jsonDecode(utf8.decode(response.bodyBytes)),
          );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _assumirEntrega(int id) async {
    try {
      // Adicionado loja_id
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/entregas/assumir/$id/?loja_id=${Config.lojaId}'),
        headers: {'Authorization': 'Token ${widget.userData['token']}'},
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aceito!'),
            backgroundColor: Colors.green,
          ),
        );
        _carregarDados();
        _tabController.animateTo(1);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _finalizarEntrega(int id) async {
    try {
      // Adicionado loja_id
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/entregas/finalizar/$id/?loja_id=${Config.lojaId}'),
        headers: {'Authorization': 'Token ${widget.userData['token']}'},
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Finalizado!'),
            backgroundColor: Colors.green,
          ),
        );
        _carregarDados();
        _carregarExtrato(); 
      }
    } catch (e) {
      print(e);
    }
  }

  // --- TELA PRINCIPAL ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Olá, ${widget.userData['nome']}"),
        backgroundColor: const Color(0xFF15A0A5),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.map), text: "Disponíveis"),
            Tab(icon: Icon(Icons.history), text: "Minhas"),
            Tab(icon: Icon(Icons.monetization_on), text: "Ganhos"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _carregarDados();
              _carregarExtrato();
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListaDisponiveis(),
          _buildListaMinhas(),
          _buildTelaGanhos(),
        ],
      ),
    );
  }

  // --- WIDGETS DE LISTA ---

  Widget _buildListaDisponiveis() {
    if (_isLoading && _entregasDisponiveis.isEmpty)
      return const Center(child: CircularProgressIndicator());
    if (_entregasDisponiveis.isEmpty)
      return const Center(
        child: Text(
          "Sem entregas disponíveis",
          style: TextStyle(color: Colors.grey),
        ),
      );

    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _entregasDisponiveis.length,
        itemBuilder: (context, index) => _buildCardEntrega(
          _entregasDisponiveis[index],
          isMinhasEntregas: false,
        ),
      ),
    );
  }

  Widget _buildListaMinhas() {
    if (_minhasEntregas.isEmpty)
      return const Center(
        child: Text(
          "Nenhuma entrega assumida",
          style: TextStyle(color: Colors.grey),
        ),
      );
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _minhasEntregas.length,
      itemBuilder: (context, index) =>
          _buildCardEntrega(_minhasEntregas[index], isMinhasEntregas: true),
    );
  }

  Widget _buildCardEntrega(dynamic entrega, {required bool isMinhasEntregas}) {
    bool emRota = entrega['status'] == 'EM_ROTA';
    bool concluido =
        entrega['status'] == 'ENTREGUE' || entrega['status'] == 'CONCLUÍDO';
    double valorNumerico = (entrega['valor'] as num).toDouble();

    return Card(
      color: concluido ? const Color(0xFF1E1E1E) : const Color(0xFF2C2C2C),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: emRota
              ? Colors.orange
              : (concluido ? Colors.green : Colors.grey),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "#${entrega['id']} - ${entrega['cliente']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "R\$ ${valorNumerico.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey),

            // Endereço + Mapa
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "📍 ${entrega['endereco']}",
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.map, color: Colors.blueAccent),
                  onPressed: () => _abrirMapa(entrega['endereco']),
                ),
              ],
            ),

            Row(
              children: [
                const Icon(Icons.payment, size: 16, color: Colors.greenAccent),
                const SizedBox(width: 5),
                Text(
                  "Pagamento: ${entrega['pagamento'] ?? 'Não informado'}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // BLOCO NOVO: SÓ APARECE SE TIVER TROCO
            if (entrega['troco_para'] != null && entrega['troco_para'] > 0) ...[
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amberAccent),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amberAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "LEVAR TROCO PARA R\$ ${(entrega['troco_para'] as num).toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Mostra quanto exato de troco tem que dar 
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2),
                child: Text(
                  "Valor do troco: R\$ ${(entrega['troco_para'] - entrega['valor']).toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 5),

            Text(
              "📦 ${(entrega['itens'] ?? []).join(', ')}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                if (entrega['whatsapp_link'] != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                      onPressed: () => _abrirWhatsApp(entrega['whatsapp_link']),
                      child: const FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                Expanded(
                  child: isMinhasEntregas
                      ? (emRota
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () =>
                                  _finalizarEntrega(entrega['id']),
                              child: const Text(
                                "FINALIZAR",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                "CONCLUÍDO ✅",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15A0A5),
                          ),
                          onPressed: () => _assumirEntrega(entrega['id']),
                          child: const Text(
                            "ACEITAR",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- TELA DE GANHOS  ---
  Widget _buildTelaGanhos() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. FILTROS 
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filtroSelecionado,
                dropdownColor: const Color(0xFF2C2C2C),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'hoje', child: Text("Hoje (Padrão)")),
                  DropdownMenuItem(value: 'semana', child: Text("Esta Semana")),
                  DropdownMenuItem(value: 'mes', child: Text("Este Mês")),
                ],
                onChanged: (value) {
                  setState(() => _filtroSelecionado = value!);
                  _carregarExtrato(); 
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. CARD DO VALOR TOTAL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF15A0A5), Color(0xFF0D6E72)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  "Ganhos no Período",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  "R\$ ${_totalGanhos.toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "$_qtdEntregasFeitas entregas realizadas",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. LISTA DE EXTRATO DETALHADO
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Histórico Detalhado",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: _historicoGanhos.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhuma entrega neste período.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _historicoGanhos.length,
                    itemBuilder: (context, index) {
                      final item = _historicoGanhos[index];
                      double val = (item['valor'] as num).toDouble();
                      return Card(
                        color: const Color(0xFF1E1E1E),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(
                            item['cliente'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            item['data'],
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Text(
                            "+ R\$ ${val.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}