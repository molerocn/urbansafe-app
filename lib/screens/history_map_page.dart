import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  void _createMarkers() {
    // Marcadores reales basados en el historial
    for (var measurement in widget.measurements) {
      if (measurement.ubicacionLat != null && measurement.ubicacionLng != null) {
        final hue = _hueForRisk(measurement);
        final marker = Marker(
          markerId: MarkerId(measurement.id ?? measurement.fecha.toString()),
          position: LatLng(measurement.ubicacionLat!, measurement.ubicacionLng!),
          infoWindow: InfoWindow(
            title: measurement.nivelRiesgoLabel,
            snippet: 'Fecha: ${measurement.fecha?.toDate().toLocal().toString() ?? 'N/A'}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        );
        _markers.add(marker);
      }
    }
  }

  double _hueForRisk(RiskMeasurement m) {
    final label = (m.nivelRiesgoLabel ?? '').toLowerCase();
    if (label.contains('alto')) {
      return BitmapDescriptor.hueRed;
    }
    if (label.contains('bajo')) {
      return BitmapDescriptor.hueGreen;
    }
    // fallback based on numeric
    final v = m.nivelRiesgo;
    if (v >= 2.5) {
      return BitmapDescriptor.hueRed;
    }
    return BitmapDescriptor.hueGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de Historial', style: TextStyle(color: AppColors.secondary)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialCenter,
              zoom: 11.0,
            ),
            markers: _markers,
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 20),
                      const SizedBox(width: 4),
                      const Text('Alto', style: TextStyle(fontSize: 14, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: Colors.green, size: 20),
                      const SizedBox(width: 4),
                      const Text('Bajo', style: TextStyle(fontSize: 14, color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
