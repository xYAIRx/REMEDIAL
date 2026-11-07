import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/servicio.dart';
import '../services/servicio_repository.dart';
import 'servicio_form_screen.dart';
import 'servicios_list_screen.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final repo = ServicioRepository();
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Mantenimiento'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Bienvenido', style: tema.textTheme.titleMedium),
          Text(user.email ?? '',
              style: tema.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700)),
          const SizedBox(height: 20),
          StreamBuilder<List<Servicio>>(
            stream: repo.servicios(user.uid),
            builder: (context, snap) {
              final lista = snap.data ?? [];
              int n(String e) => lista.where((s) => s.estado == e).length;
              return Column(
                children: [
                  Row(
                    children: [
                      _Resumen('Pendientes', n('Pendiente'), Colors.orange, Icons.schedule),
                      _Resumen('En proceso', n('En proceso'), Colors.blue, Icons.engineering),
                      _Resumen('Completados', n('Completado'), Colors.green, Icons.check_circle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Total de servicios: ${lista.length}',
                      style: tema.textTheme.bodyMedium),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          _Accion(
            icono: Icons.add_circle_outline,
            titulo: 'Registrar servicio',
            subtitulo: 'Agrega un nuevo servicio de mantenimiento',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ServicioFormScreen(uid: user.uid)),
            ),
          ),
          const SizedBox(height: 12),
          _Accion(
            icono: Icons.list_alt,
            titulo: 'Ver servicios',
            subtitulo: 'Consulta, filtra y actualiza el estado',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ServiciosListScreen(uid: user.uid)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  final String titulo;
  final int valor;
  final Color color;
  final IconData icono;
  const _Resumen(this.titulo, this.valor, this.color, this.icono);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icono, color: color, size: 28),
              const SizedBox(height: 6),
              Text('$valor',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: color)),
              Text(titulo,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _Accion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;
  const _Accion({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(icono, size: 38, color: color),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
