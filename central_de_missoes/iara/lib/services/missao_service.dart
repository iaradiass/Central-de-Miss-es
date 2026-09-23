import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/missao.dart';

class MissaoService {
  final CollectionReference<Map<String, dynamic>> _collection =
      FirebaseFirestore.instance.collection('missoes');

  Future<void> adicionar(Missao missao) async {
    await _collection.add(missao.toMap());
  }

  Future<List<Missao>> buscarTodas() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Missao.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> atualizar(Missao missao) async {
    if (missao.id == null) return;
    await _collection.doc(missao.id).update(missao.toMap());
  }

  Future<void> excluir(String id) async {
    await _collection.doc(id).delete();
  }
}
