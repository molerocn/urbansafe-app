import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/risk_measurement.dart';
import '../models/user.dart';
import '../repositories/measurement_repository.dart';

/// Página que muestra el historial de mediciones de riesgo de un usuario.
class MeasurementsHistoryPage extends StatefulWidget {
  final User user;

  const MeasurementsHistoryPage({super.key, required this.user});

  @override
  State<MeasurementsHistoryPage> createState() =>
      _MeasurementsHistoryPageState();
}

class _MeasurementsHistoryPageState extends State<MeasurementsHistoryPage> {
  final MedicionRepository _repo = MedicionRepository();
  final List<RiskMeasurement> _items = [];
  DocumentSnapshot? _lastDoc;
  bool _loading = false;
  bool _hasMore = true;
  final int _pageSize = 12;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  // Devuelve un ícono representativo del nivel de riesgo de la medición.
  Icon _iconForMedicion(RiskMeasurement m) {
    final label = (m.nivelRiesgoLabel ?? '').toLowerCase();
    if (label.contains('muy') && label.contains('alta')) {
      return const Icon(Icons.priority_high, color: Colors.red);
    }
    if (label.contains('alta')) {
      return const Icon(Icons.warning, color: Colors.redAccent);
    }
    if (label.contains('media')) {
      return const Icon(Icons.report_problem, color: Colors.orange);
    }
    if (label.contains('baja')) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    // fallback based on numeric
    final v = m.nivelRiesgo;
    if (v >= 3.5) {
      return const Icon(Icons.priority_high, color: Colors.red);
    }
    if (v >= 2.5) {
      return const Icon(Icons.warning, color: Colors.redAccent);
    }
    if (v >= 1.5) {
      return const Icon(Icons.report_problem, color: Colors.orange);
    }
    return const Icon(Icons.check_circle, color: Colors.green);
  }

  // Formatea la fecha de la medición para mostrarla en la lista.
  String _formatDate(Timestamp? ts) {
    if (ts == null) return 'Fecha pendiente';
    final dt = ts.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  // Carga una página de mediciones desde Firestore.
  Future<void> _loadPage() async {
    if (_loading || !_hasMore) return;
    final uid = widget.user.id;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final snap = await _repo.getMedicionesPageForUser(
        uid,
        limit: _pageSize,
        startAfter: _lastDoc,
      );
      final docs = snap.docs;
      if (docs.isEmpty) {
        _hasMore = false;
      } else {
        final pageItems = docs.map((d) => RiskMeasurement.fromDoc(d)).toList();
        _items.addAll(pageItems);
        _lastDoc = docs.last;
        if (docs.length < _pageSize) _hasMore = false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error cargando página de mediciones: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  // Construye la interfaz de usuario para la página de historial de mediciones.
  @override
  Widget build(BuildContext context) {
    final uid = widget.user.id;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Historial de mediciones')),
        body: const Center(child: Text('Usuario no identificado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de mediciones')),
      body: _items.isEmpty && _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final m = _items[index];
                      final label =
                          m.nivelRiesgoLabel ?? m.nivelRiesgo.toString();
                      return ListTile(
                        leading: _iconForMedicion(m),
                        title: Text(label),
                        subtitle: Text(_formatDate(m.fecha)),
                        trailing: Text(m.user?['nombre'] ?? ''),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Medición - $label'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Nivel: $label'),
                                  const SizedBox(height: 8),
                                  Text('Fecha: ${_formatDate(m.fecha)}'),
                                  if (m.ubicacionLat != null &&
                                      m.ubicacionLng != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ubicación: ${m.ubicacionLat}, ${m.ubicacionLng}',
                                    ),
                                  ],
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                if (_hasMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _loadPage,
                            child: const Text('Cargar más'),
                          ),
                  ),
                if (!_hasMore)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'No hay más mediciones',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
    );
  }
}
