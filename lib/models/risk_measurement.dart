import 'package:cloud_firestore/cloud_firestore.dart';

// Representa una medición de riesgo almacenada en Firestore para el flujo típico de la app.
// Modelo mínimo que contiene solo los campos usados por el flujo de medición:
// - userId / user
// - nivelRiesgo / nivelRiesgoLabel
// - fecha (Timestamp)
// - ubicacionLat / ubicacionLng
class RiskMeasurement {
  final String? userId;
  final Map<String, dynamic>? user;
  final String? id;
  final double nivelRiesgo;
  final String? nivelRiesgoLabel;
  final Timestamp? fecha;
  final double? ubicacionLat;
  final double? ubicacionLng;

  RiskMeasurement({
    this.userId,
    this.user,
    this.id,
    required this.nivelRiesgo,
    this.nivelRiesgoLabel,
    this.fecha,
    this.ubicacionLat,
    this.ubicacionLng,
  });

  /// Crea una instancia a partir de un DocumentSnapshot de Firestore
  factory RiskMeasurement.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};

    double parseNivel(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    double? lat;
    double? lng;
    if (data['ubicacion'] is Map) {
      final u = data['ubicacion'] as Map<String, dynamic>;
      if (u['latitud'] != null) {
        lat = (u['latitud'] as num).toDouble();
      } else if (u['lat'] != null) {
        lat = (u['lat'] as num).toDouble();
      }
      if (u['longitud'] != null) {
        lng = (u['longitud'] as num).toDouble();
      } else if (u['lng'] != null) {
        lng = (u['lng'] as num).toDouble();
      }
    }
    if (lat == null && data['latitud'] != null) {
      lat = (data['latitud'] as num).toDouble();
    }
    if (lng == null && data['longitud'] != null) {
      lng = (data['longitud'] as num).toDouble();
    }

    return RiskMeasurement(
      userId: (data['userId'] ?? data['id_usuario']) as String?,
      user: data['user'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(data['user'] as Map)
          : null,
      id: doc.id,
      nivelRiesgo: parseNivel(data['nivel_riesgo'] ?? data['nivelRiesgo']),
      nivelRiesgoLabel:
          (data['nivel_riesgo_text'] ?? data['nivelRiesgoText']) as String?,
      fecha: data['fecha'] as Timestamp?,
      ubicacionLat: lat,
      ubicacionLng: lng,
    );
  }

  /// Crea una instancia a partir de un mapa JSON (por ejemplo en tests)
  factory RiskMeasurement.fromJson(Map<String, dynamic> json, {String? id}) {
    double parseNivel(dynamic v) {
      if (v == null) {
        return 0.0;
      }
      if (v is num) {
        return v.toDouble();
      }
      if (v is String) {
        return double.tryParse(v) ?? 0.0;
      }
      return 0.0;
    }

    return RiskMeasurement(
      id: id,
      nivelRiesgo: parseNivel(json['nivel_riesgo'] ?? json['nivelRiesgo']),
      fecha: json['fecha'] as Timestamp?,
      ubicacionLat: (json['ubicacion'] is Map)
          ? ((json['ubicacion']['latitud'] ?? json['ubicacion']['lat']) as num?)
                ?.toDouble()
          : (json['latitud'] as num?)?.toDouble(),
      ubicacionLng: (json['ubicacion'] is Map)
          ? ((json['ubicacion']['longitud'] ?? json['ubicacion']['lng'])
                    as num?)
                ?.toDouble()
          : (json['longitud'] as num?)?.toDouble(),
    );
  }

  /// Convierte la entidad a un mapa listo para Firestore.
  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{'nivel_riesgo': nivelRiesgo};
    if (nivelRiesgoLabel != null) {
      m['nivel_riesgo_text'] = nivelRiesgoLabel;
    }
    if (userId != null) {
      m['userId'] = userId;
    }
    if (user != null) {
      m['user'] = user;
    }
    if (fecha != null) {
      m['fecha'] = fecha;
    }
    if (ubicacionLat != null) {
      m['latitud'] = ubicacionLat;
    }
    if (ubicacionLng != null) {
      m['longitud'] = ubicacionLng;
    }
    if (ubicacionLat != null && ubicacionLng != null) {
      m['ubicacion_geo'] = GeoPoint(ubicacionLat!, ubicacionLng!);
    }

    return m;
  }

  /// Crea una copia modificada de la instancia actual.
  RiskMeasurement copyWith({
    String? userId,
    Map<String, dynamic>? user,
    String? nivelRiesgoLabel,
    String? id,
    double? nivelRiesgo,
    Timestamp? fecha,
    double? ubicacionLat,
    double? ubicacionLng,
  }) {
    return RiskMeasurement(
      userId: userId ?? this.userId,
      user: user ?? this.user,
      nivelRiesgoLabel: nivelRiesgoLabel ?? this.nivelRiesgoLabel,
      id: id ?? this.id,
      nivelRiesgo: nivelRiesgo ?? this.nivelRiesgo,
      fecha: fecha ?? this.fecha,
      ubicacionLat: ubicacionLat ?? this.ubicacionLat,
      ubicacionLng: ubicacionLng ?? this.ubicacionLng,
    );
  }
}
