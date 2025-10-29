import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:urbansafe/src/app_logger.dart';
import '../models/risk_measurement.dart';
import '../models/user.dart';

/// Repositorio para gestionar mediciones de riesgo en Firestore.
class MedicionRepository {
  final CollectionReference _col;

  MedicionRepository({FirebaseFirestore? firestore})
    : _col = (firestore ?? FirebaseFirestore.instance).collection('mediciones');

  /// Crea una nueva medición de riesgo asociada a un usuario.
  Future<DocumentReference> createMedicionForUser({
    required User user,
    required RiskMeasurement medicion,
  }) async {
    appLog(
      'medicion ubicacion: lat=${medicion.ubicacionLat}, lng=${medicion.ubicacionLng}',
      tag: 'MedicionRepository',
    );
    final map = medicion.toJson();

    if (user.id != null) map['userId'] = user.id;
    map['user'] = {'id': user.id, 'nombre': user.nombre};

    if (map['fecha'] == null) map['fecha'] = FieldValue.serverTimestamp();
    appLog('map keys: ${map.keys.toList()}', tag: 'MedicionRepository');
    appLog('map preview: $map', tag: 'MedicionRepository');

    final ref = await _col.add(map);
    return ref;
  }

  /// Stream de mediciones para un usuario (ordenadas por fecha desc).
  Stream<List<RiskMeasurement>> streamMedicionesForUser(String uid) {
    final q = _col
        .where('userId', isEqualTo: uid)
        .orderBy('fecha', descending: true);
    return q.snapshots().map(
      (snap) => snap.docs.map((d) => RiskMeasurement.fromDoc(d)).toList(),
    );
  }

  /// Obtener mediciones de un usuario (una sola vez)
  Future<List<RiskMeasurement>> getMedicionesForUser(
    String uid, {
    int limit = 100,
  }) async {
    final q = await _col
        .where('userId', isEqualTo: uid)
        .orderBy('fecha', descending: true)
        .limit(limit)
        .get();
    return q.docs.map((d) => RiskMeasurement.fromDoc(d)).toList();
  }

  /// Paginación: obtiene una página de mediciones para un usuario.
  Future<QuerySnapshot> getMedicionesPageForUser(
    String uid, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query q = _col
        .where('userId', isEqualTo: uid)
        .orderBy('fecha', descending: true)
        .limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snap = await q.get();
    return snap;
  }
}
