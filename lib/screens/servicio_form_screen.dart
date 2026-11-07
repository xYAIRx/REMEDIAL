import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/servicio.dart';
import '../services/servicio_repository.dart';
import '../utils.dart';

class ServicioFormScreen extends StatefulWidget {
  final String uid;
  const ServicioFormScreen({super.key, required this.uid});

  @override
  State<ServicioFormScreen> createState() => _ServicioFormScreenState();
}

class _ServicioFormScreenState extends State<ServicioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _cliente = TextEditingController();
  final _tecnico = TextEditingController();
  final _descripcion = TextEditingController();
  final _costo = TextEditingController();
  final _repo = ServicioRepository();

  String _tipo = tipos.first;
  String _prioridad = 'Media';
  String _estado = estados.first;
  DateTime _fecha = DateTime.now();
  bool _guardando = false;

  @override
  void dispose() {
    _titulo.dispose();
    _cliente.dispose();
    _tecnico.dispose();
    _descripcion.dispose();
    _costo.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final f = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (f != null) setState(() => _fecha = f);
  }

  String? _requerido(String? v, String campo) {
    if (v == null || v.trim().isEmpty) return '$campo es obligatorio';
    return null;
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final servicio = Servicio(
        uid: widget.uid,
        titulo: _titulo.text.trim(),
        cliente: _cliente.text.trim(),
        tipo: _tipo,
        prioridad: _prioridad,
        descripcion: _descripcion.text.trim(),
        tecnico: _tecnico.text.trim(),
        estado: _estado,
        costo: double.parse(_costo.text.trim().replaceAll(',', '.')),
        fecha: _fecha,
      );
      await _repo.agregar(servicio).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      mostrarMensaje(context, 'Servicio registrado correctamente');
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        mostrarMensaje(context, 'No se pudo guardar. Revisa tu conexión.', error: true);
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar servicio')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titulo,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Título del servicio',
                prefixIcon: Icon(Icons.build),
              ),
              validator: (v) => _requerido(v, 'El título'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _cliente,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Cliente / Área',
                prefixIcon: Icon(Icons.business),
              ),
              validator: (v) => _requerido(v, 'El cliente'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _tecnico,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Técnico asignado',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => _requerido(v, 'El técnico'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _tipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de servicio',
                prefixIcon: Icon(Icons.category),
              ),
              items: tipos.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _tipo = v!),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _prioridad,
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                prefixIcon: Icon(Icons.flag),
              ),
              items: prioridades.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _prioridad = v!),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _estado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                prefixIcon: Icon(Icons.timelapse),
              ),
              items: estados.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _estado = v!),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _elegirFecha,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha programada',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _costo,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Costo estimado',
                prefixText: '\$ ',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El costo es obligatorio';
                final n = double.tryParse(v.trim().replaceAll(',', '.'));
                if (n == null) return 'Ingresa un número válido';
                if (n < 0) return 'El costo no puede ser negativo';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descripcion,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción del trabajo',
                alignLabelWithHint: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'La descripción es obligatoria';
                if (v.trim().length < 10) return 'Describe un poco más (mín. 10 caracteres)';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5))
                    : const Icon(Icons.save),
                label: const Text('Guardar servicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
