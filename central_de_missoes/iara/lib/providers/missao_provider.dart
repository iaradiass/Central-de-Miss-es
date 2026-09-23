import 'package:flutter/foundation.dart';
import '../models/missao.dart';
import '../services/missao_service.dart';

class MissaoProvider extends ChangeNotifier {
  final MissaoService _service;
  MissaoProvider({MissaoService? service}) : _service = service ?? MissaoService();

  List<Missao> _missoes = [];
  bool _carregando = false;
  String? _erro;

  List<Missao> get missoes => List.unmodifiable(_missoes);
  bool get carregando => _carregando;
  String? get erro => _erro;

  int get pontosTotais => _missoes
      .where((m) => m.concluida)
      .fold(0, (total, m) => total + m.pontos);

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      _missoes = await _service.buscarTodas();
    } catch (e) {
      _erro = 'Não foi possível carregar as missões: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> adicionar(String titulo, String dificuldade) async {
    final pontos = _pontosDaDificuldade(dificuldade);
    final hoje = DateTime.now();
    final data = '${hoje.day.toString().padLeft(2, '0')}/${hoje.month.toString().padLeft(2, '0')}/${hoje.year}';
    await _service.adicionar(Missao(
      titulo: titulo.trim(),
      dificuldade: dificuldade,
      pontos: pontos,
      concluida: false,
      data: data,
    ));
    await carregar();
  }

  Future<void> concluir(Missao missao) async {
    if (missao.concluida) return;
    missao.concluida = true;
    await _service.atualizar(missao);
    await carregar();
  }

  Future<void> excluir(Missao missao) async {
    if (missao.id == null) return;
    await _service.excluir(missao.id!);
    await carregar();
  }

  int _pontosDaDificuldade(String dificuldade) {
    switch (dificuldade) {
      case 'Médio': return 20;
      case 'Difícil': return 30;
      default: return 10;
    }
  }
}
