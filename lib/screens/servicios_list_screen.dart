import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/servicio.dart';
import '../services/servicio_repository.dart';
import '../utils.dart';

class ServiciosListScreen extends StatefulWidget {
  final String uid;
  const ServiciosListScreen({super.key, required this.uid});

  @override
  State<ServiciosListScreen> createState() => _ServiciosListScreenState();
}

class _ServiciosListScreenState extends State<ServiciosListScreen> {
  final _repo = ServicioRepository();
  String _filtro = 'Todos';

  Future<void> _eliminar(Servicio s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar servicio'),
        content: Text('¿Eliminar "${s.titulo}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.eliminar(s.id!);
      if (mounted) mostrarMensaje(context, 'Servicio eliminado');
    } catch (_) {
      if (mounted) mostrarMensaje(context, 'No se pudo eliminar', error: true);
    }
  }

  Future<void> _cambiarEstado(Servicio s, String estado) async {
    try {
      await _repo.cambiarEstado(s.id!, estado);
      if (mounted) mostrarMensaje(context, 'Estado actualizado a $estado');
    } catch (_) {
      if (mounted) mostrarMensaje(context, 'No se pudo actualizar', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servicios')),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: ['Todos', ...estados]
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(e),
                          selected: _filtro == e,
                          onSelected: (_) => setState(() => _filtro = e),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Servicio>>(
              stream: _repo.servicios(widget.uid),
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Center(child: Text('Error al cargar los servicios'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final lista = snap.data!
                    .where((s) => _filtro == 'Todos' || s.estado == _filtro)
                    .toList();
                if (lista.isEmpty) {
                  return const Center(child: Text('No hay servicios registrados'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: lista.length,
                  itemBuilder: (context, i) => _TarjetaServicio(
                    servicio: lista[i],
                    onEstado: (e) => _cambiarEstado(lista[i], e),
                    onEliminar: () => _eliminar(lista[i]),
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

class _TarjetaServicio extends StatelessWidget {
  final Servicio servicio;
  final ValueChanged<String> onEstado;
  final VoidCallback onEliminar;
  const _TarjetaServicio({
    required this.servicio,
    required this.onEstado,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final s = servicio;
    final tema = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(s.titulo,
                      style: tema.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) => v == 'eliminar' ? onEliminar() : onEstado(v),
                  itemBuilder: (_) => [
                    ...estados.map((e) => PopupMenuItem(
                        value: e, child: Text('Marcar como $e'))),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                  ],
                ),
              ],
            ),
            Text('${s.cliente}  •  ${s.tipo}', style: tema.textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(s.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tema.textTheme.bodySmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _Etiqueta(s.estado, colorEstado(s.estado)),
                _Etiqueta('Prioridad ${s.prioridad}', colorPrioridad(s.prioridad)),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 4),
                  Expanded(child: Text(s.tecnico, style: tema.textTheme.bodySmall)),
                  const Icon(Icons.calendar_today, size: 14),
                  const SizedBox(width: 4),
                  Text(DateFormat('dd/MM/yyyy').format(s.fecha),
                      style: tema.textTheme.bodySmall),
                  const SizedBox(width: 12),
                  Text('\$${s.costo.toStringAsFixed(2)}',
                      style: tema.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  final Color color;
  const _Etiqueta(this.texto, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(texto,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
