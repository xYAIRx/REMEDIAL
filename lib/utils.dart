import 'package:flutter/material.dart';

const estados = ['Pendiente', 'En proceso', 'Completado'];
const tipos = ['Preventivo', 'Correctivo', 'Instalación', 'Inspección'];
const prioridades = ['Baja', 'Media', 'Alta'];

Color colorEstado(String estado) {
  switch (estado) {
    case 'Completado':
      return Colors.green;
    case 'En proceso':
      return Colors.blue;
    default:
      return Colors.orange;
  }
}

Color colorPrioridad(String prioridad) {
  switch (prioridad) {
    case 'Alta':
      return Colors.red;
    case 'Media':
      return Colors.amber.shade800;
    default:
      return Colors.teal;
  }
}

void mostrarMensaje(BuildContext context, String texto, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(texto),
      backgroundColor: error ? Colors.red.shade700 : null,
    ));
}
