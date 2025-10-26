import 'package:cloud_firestore/cloud_firestore.dart';

// Modelo simple de Usuario usado por el prototipo de autenticación solo con Firestore.
class User {
  final String? id;
  final String nombre;
  final String correo;
  final String rol;
  final String? passwordHash;
  final Timestamp? createdAt;

  User({
    this.id,
    required this.nombre,
    required this.correo,
    this.rol = 'Usuario',
    this.passwordHash,
    this.createdAt,
  });

  /// Crea una instancia a partir de un DocumentSnapshot de Firestore
  factory User.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return User(
      id: doc.id,
      nombre: (data['nombre'] as String?) ?? '',
      correo: (data['correo'] as String?) ?? '',
      rol: (data['rol'] as String?) ?? 'Usuario',
      passwordHash: data['passwordHash'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  /// Crea una instancia a partir de un Map JSON
  factory User.fromJson(Map<String, dynamic> json, {String? id}) => User(
    id: id,
    nombre: (json['nombre'] as String?) ?? '',
    correo: (json['correo'] as String?) ?? '',
    rol: (json['rol'] as String?) ?? 'Usuario',
    passwordHash: json['passwordHash'] as String?,
    createdAt: json['createdAt'] as Timestamp?,
  );

  /// Convierte la entidad a un mapa listo para Firestore.
  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{'nombre': nombre, 'correo': correo, 'rol': rol};
    if (passwordHash != null) m['passwordHash'] = passwordHash;
    if (createdAt != null) m['createdAt'] = createdAt;
    return m;
  }

  /// Crea una copia del usuario con campos opcionalmente modificados.
  User copyWith({
    String? id,
    String? nombre,
    String? correo,
    String? rol,
    String? passwordHash,
    Timestamp? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      rol: rol ?? this.rol,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
