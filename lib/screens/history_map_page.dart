import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urbansafe/models/risk_measurement.dart';

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
        final marker = Marker(
          markerId: MarkerId(measurement.id ?? measurement.fecha.toString()),
          position: LatLng(measurement.ubicacionLat!, measurement.ubicacionLng!),
          infoWindow: InfoWindow(
            title: measurement.nivelRiesgoLabel,
            snippet: 'Fecha: ${measurement.fecha?.toDate().toLocal().toString() ?? 'N/A'}',
          ),
        );
        _markers.add(marker);
      }
    }

    // DUMMY MARKERS - START (Para eliminar después de la demo)
    _markers.add(Marker(
      markerId: const MarkerId('dummy_1'),
      position: const LatLng(-11.972924, -77.120258),
      infoWindow: const InfoWindow(title: 'Muy peligroso - Demo_1'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('dummy_2'),
      position: const LatLng(-12.049941, -77.116538),
      infoWindow: const InfoWindow(title: 'Muy peligroso - Demo_2'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('dummy_3'),
      position: const LatLng(-12.061937, -77.141837),
      infoWindow: const InfoWindow(title: 'Muy peligroso - Demo_3'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('dummy_4'),
      position: const LatLng(-11.830446, -77.170525),
      infoWindow: const InfoWindow(title: 'Muy peligroso - Demo_4'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ));
    // DUMMY MARKERS - END
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Historial'),
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
