import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/missao.dart';
import '../providers/missao_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _tituloController = TextEditingController();
  String _dificuldade = 'Fácil';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MissaoProvider>().carregar();
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    final titulo = _tituloController.text.trim();
    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o título da missão.')));
      return;
    }
    await context.read<MissaoProvider>().adicionar(titulo, _dificuldade);
    _tituloController.clear();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Missão cadastrada com sucesso!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Central de Missões'), centerTitle: true),
      body: Consumer<MissaoProvider>(
        builder: (context, provider, _) => RefreshIndicator(
          onRefresh: provider.carregar,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Nova missão', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(controller: _tituloController, decoration: const InputDecoration(labelText: 'Título da missão', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _dificuldade,
                      decoration: const InputDecoration(labelText: 'Dificuldade', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Fácil', child: Text('⭐ Fácil — 10 pontos')),
                        DropdownMenuItem(value: 'Médio', child: Text('⭐⭐ Médio — 20 pontos')),
                        DropdownMenuItem(value: 'Difícil', child: Text('⭐⭐⭐ Difícil — 30 pontos')),
                      ],
                      onChanged: (v) => setState(() => _dificuldade = v ?? 'Fácil'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _cadastrar, icon: const Icon(Icons.add_task), label: const Text('CADASTRAR MISSÃO'))),
                  ]),
                ),
              ),
              const SizedBox(height: 12),
              Card(color: Theme.of(context).colorScheme.primaryContainer, child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [const Icon(Icons.emoji_events, size: 32), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('PONTOS CONQUISTADOS'), Text('${provider.pontosTotais} pontos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))])])) ,
              const SizedBox(height: 16),
              if (provider.carregando) const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())),
              if (!provider.carregando && provider.missoes.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(30), child: Text('Nenhuma missão cadastrada.'))),
              if (provider.erro != null) Padding(padding: const EdgeInsets.all(8), child: Text(provider.erro!, style: const TextStyle(color: Colors.red))),
              ...provider.missoes.map((missao) => _MissaoCard(missao: missao)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissaoCard extends StatelessWidget {
  final Missao missao;
  const _MissaoCard({required this.missao});

  String _estrelas(String dificuldade) => dificuldade == 'Difícil' ? '⭐⭐⭐' : dificuldade == 'Médio' ? '⭐⭐' : '⭐';

  @override
  Widget build(BuildContext context) {
    final provider = context.read<MissaoProvider>();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetalhesPage(missao: missao))),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(missao.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), Icon(missao.concluida ? Icons.check_circle : Icons.radio_button_unchecked, color: missao.concluida ? Colors.green : Colors.grey)]),
            const SizedBox(height: 8),
            Text('Dificuldade: ${_estrelas(missao.dificuldade)} ${missao.dificuldade}'),
            Text('Pontos: ${missao.pontos}'),
            Text('Data: ${missao.data}'),
            Text('Status: ${missao.concluida ? 'Concluída' : 'Pendente'}'),
            const SizedBox(height: 8),
            Row(children: [
              if (!missao.concluida) Expanded(child: ElevatedButton(onPressed: () async { await provider.concluir(missao); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Missão concluída! Você conquistou ${missao.pontos} pontos.'))); }, child: const Text('CONCLUIR'))),
              if (!missao.concluida) const SizedBox(width: 8),
              Expanded(child: OutlinedButton.icon(onPressed: () async { await provider.excluir(missao); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Missão removida.'))); }, icon: const Icon(Icons.delete_outline), label: const Text('EXCLUIR'))),
            ]),
          ]),
        ),
      ),
    );
  }
}

class DetalhesPage extends StatelessWidget {
  final Missao missao;
  const DetalhesPage({super.key, required this.missao});
  String _estrelas(String dificuldade) => dificuldade == 'Difícil' ? '⭐⭐⭐' : dificuldade == 'Médio' ? '⭐⭐' : '⭐';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detalhes da Missão')),
    body: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(missao.titulo, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24), Text('Dificuldade: ${_estrelas(missao.dificuldade)} ${missao.dificuldade}', style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 12), Text('Pontos: ${missao.pontos}', style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 12), Text('Data: ${missao.data}', style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 12), Text('Status: ${missao.concluida ? 'Concluída' : 'Pendente'}', style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 24),
      if (!missao.concluida) SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async { await context.read<MissaoProvider>().concluir(missao); if (context.mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Missão concluída! Você conquistou ${missao.pontos} pontos.'))); Navigator.pop(context); } }, child: const Text('CONCLUIR MISSÃO'))),
    ])),
  );
}
