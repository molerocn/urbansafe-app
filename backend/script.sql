CREATE TABLE `Usuario` (
  `id_usuario` int PRIMARY KEY AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `correo` varchar(255) UNIQUE NOT NULL,
  `contraseÃ±a` varchar(255) NOT NULL,
  `foto` varchar(255),
  `idioma` varchar(255) DEFAULT 'es',
  `tema` varchar(255) DEFAULT 'claro'
);

CREATE TABLE `Sesion` (
  `id_sesion` int PRIMARY KEY AUTO_INCREMENT,
  `fecha_inicio` datetime NOT NULL,
  `fecha_fin` datetime,
  `id_usuario` int NOT NULL
);

CREATE TABLE `Historial` (
  `id_historial` int PRIMARY KEY AUTO_INCREMENT,
  `fecha` datetime NOT NULL,
  `id_usuario` int NOT NULL
);

CREATE TABLE `Ubicacion` (
  `id_ubicacion` int PRIMARY KEY AUTO_INCREMENT,
  `latitud` decimal NOT NULL,
  `longitud` decimal NOT NULL
);

CREATE TABLE `MedicionRiesgo` (
  `id_medicion` int PRIMARY KEY AUTO_INCREMENT,
  `nivel_riesgo` enum("baja", "media", "alta") NOT NULL,
  `fecha` datetime NOT NULL,
  `id_historial` int NOT NULL,
  `id_ubicacion` int NOT NULL
);

ALTER TABLE `Sesion` ADD FOREIGN KEY (`id_usuario`) REFERENCES `Usuario` (`id_usuario`);

ALTER TABLE `Historial` ADD FOREIGN KEY (`id_usuario`) REFERENCES `Usuario` (`id_usuario`);

ALTER TABLE `MedicionRiesgo` ADD FOREIGN KEY (`id_historial`) REFERENCES `Historial` (`id_historial`);

ALTER TABLE `MedicionRiesgo` ADD FOREIGN KEY (`id_ubicacion`) REFERENCES `Ubicacion` (`id_ubicacion`);
