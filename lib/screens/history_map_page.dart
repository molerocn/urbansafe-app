import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:urbansafe/models/risk_measurement.dart';
import '../src/app_colors.dart';

class HistoryMapPage extends StatefulWidget {
  final List<RiskMeasurement> measurements;

  const HistoryMapPage({super.key, required this.measurements});

  @override
  State<HistoryMapPage> createState() => _HistoryMapPageState();
}

class _HistoryMapPageState extends State<HistoryMapPage> {
  final Set<Marker> _markers = {};

  // Coordenadas iniciales para centrar el mapa en callao
  static const LatLng _initialCenter = LatLng(-11.945792, -77.133064);

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _showDetails(BuildContext context, RiskMeasurement measurement) {
    final localDateTime = measurement.fecha?.toDate().toLocal();
    final formattedDate = localDateTime != null ? DateFormat('dd/MM/yyyy').format(localDateTime) : 'N/A';
    final formattedTime = localDateTime != null ? DateFormat('HH:mm').format(localDateTime) : 'N/A';

    showModalBottomSheet(context: context, builder: (builder) {
        return Container(
          height: 200.0,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Nivel de riesgo: ${measurement.nivelRiesgoLabel ?? 'Desconocido'}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('Fecha: $formattedDate', style: Theme.of(context).textTheme.titleMedium),
              Text('Hora: $formattedTime', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('Cerrar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
            ],
          ),
        );
      }, 
    );
  }

  void _createMarkers() {
    // Marcadores reales basados en el historial
    for (var measurement in widget.measurements) {
      if (measurement.ubicacionLat != null && measurement.ubicacionLng != null) {
        final hue = _hueForRisk(measurement);

        final marker = Marker(
          markerId: MarkerId(measurement.id ?? measurement.fecha.toString()),
          position: LatLng(measurement.ubicacionLat!, measurement.ubicacionLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          onTap: () {
            _showDetails(context, measurement);
          },
        );
        _markers.add(marker);
      }
    }

    /* DUMMY MARKERS - START (Para eliminar después de la demo)
    _markers.add(Marker(
      markerId: const MarkerId('dummy_1'),
      position: const LatLng(-11.972924, -77.120258),
      infoWindow: const InfoWindow(title: 'Muy peligroso - Demo_1'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('dummy_2'),
      position: const LatLng(-12.049941, -77.116538),
      infoWindow: const InfoWindow(title: 'Muy peligroso - Demo_2'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('dummy_3'),
      position: const LatLng(-12.061937, -77.141837),
      infoWindow: const InfoWindow(title: 'Muy peligroso - Demo_3'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('dummy_4'),
      position: const LatLng(-11.830446, -77.170525),
      infoWindow: const InfoWindow(title: 'Muy peligroso - Demo_4'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    // DUMMY MARKERS - END*/
  }

  double _hueForRisk(RiskMeasurement m) {
    final label = (m.nivelRiesgoLabel ?? '').toLowerCase();
    if (label.contains('muy') && label.contains('alta')) {
      return BitmapDescriptor.hueRed; // Error color
    }
    if (label.contains('alta')) {
      return BitmapDescriptor.hueRed; // Error color
    }
    if (label.contains('media')) {
      return BitmapDescriptor.hueYellow; // Secondary-like, but using yellow for gold
    }
    if (label.contains('baja')) {
      return BitmapDescriptor.hueBlue; // Primary color
    }
    // fallback based on numeric
    final v = m.nivelRiesgo;
    if (v >= 3.5) {
      return BitmapDescriptor.hueRed;
    }
    if (v >= 2.5) {
      return BitmapDescriptor.hueRed;
    }
    if (v >= 1.5) {
      return BitmapDescriptor.hueYellow;
    }
    return BitmapDescriptor.hueBlue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Historial', style: TextStyle(color: AppColors.secondary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _initialCenter,
          zoom: 11.0,
        ),
        markers: _markers,
      ),
    );
  }
}
