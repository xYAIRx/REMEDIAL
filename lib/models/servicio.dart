import 'package:cloud_firestore/cloud_firestore.dart';

class Servicio {
  final String? id;
  final String uid;
  final String titulo;
  final String cliente;
  final String tipo;
  final String prioridad;
  final String descripcion;
  final String tecnico;
  final String estado;
  final double costo;
  final DateTime fecha;

  Servicio({
    this.id,
    required this.uid,
    required this.titulo,
    required this.cliente,
    required this.tipo,
    required this.prioridad,
    required this.descripcion,
    required this.tecnico,
    required this.estado,
    required this.costo,
    required this.fecha,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'titulo': titulo,
        'cliente': cliente,
        'tipo': tipo,
        'prioridad': prioridad,
        'descripcion': descripcion,
        'tecnico': tecnico,
        'estado': estado,
        'costo': costo,
        'fecha': Timestamp.fromDate(fecha),
        'creado': FieldValue.serverTimestamp(),
      };

  factory Servicio.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Servicio(
      id: doc.id,
      uid: d['uid'] ?? '',
      titulo: d['titulo'] ?? '',
      cliente: d['cliente'] ?? '',
      tipo: d['tipo'] ?? 'Preventivo',
      prioridad: d['prioridad'] ?? 'Media',
      descripcion: d['descripcion'] ?? '',
      tecnico: d['tecnico'] ?? '',
      estado: d['estado'] ?? 'Pendiente',
      costo: (d['costo'] ?? 0).toDouble(),
      fecha: (d['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
