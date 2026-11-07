import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/servicio.dart';

class ServicioRepository {
  final _col = FirebaseFirestore.instance.collection('servicios');

  Stream<List<Servicio>> servicios(String uid) {
    return _col.where('uid', isEqualTo: uid).snapshots().map((snap) {
      final lista = snap.docs.map(Servicio.fromDoc).toList();
      lista.sort((a, b) => b.fecha.compareTo(a.fecha));
      return lista;
    });
  }

  Future<void> agregar(Servicio servicio) => _col.add(servicio.toMap());

  Future<void> cambiarEstado(String id, String estado) =>
      _col.doc(id).update({'estado': estado});

  Future<void> eliminar(String id) => _col.doc(id).delete();
}
