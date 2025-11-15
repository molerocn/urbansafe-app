import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/risk_measurement.dart';
import 'package:share_plus/share_plus.dart';

/// Servicio para exportar el historial de mediciones a CSV y PDF
class ExportService {
  /// Exporta una lista de mediciones a formato CSV
  /// Retorna la ruta del archivo generado
  static Future<String> exportToCSV(List<RiskMeasurement> measurements) async {
    try {
      // Preparar encabezados
      final List<List<dynamic>> csvData = [
        [
          'Nivel de Riesgo',
          'Etiqueta',
          'Fecha',
          'Hora',
          'Latitud',
          'Longitud',
          'Usuario'
        ]
      ];

      // Agregar datos de cada medición
      for (final measurement in measurements) {
        final fecha = measurement.fecha?.toDate();
        final fechaFormateada =
            fecha != null ? DateFormat('dd/MM/yyyy').format(fecha) : 'N/A';
        final horaFormateada =
            fecha != null ? DateFormat('HH:mm:ss').format(fecha) : 'N/A';
        final usuario = measurement.user?['nombre'] ?? 'Desconocido';

        csvData.add([
          measurement.nivelRiesgo.toStringAsFixed(2),
          measurement.nivelRiesgoLabel ?? 'N/A',
          fechaFormateada,
          horaFormateada,
          measurement.ubicacionLat?.toStringAsFixed(6) ?? 'N/A',
          measurement.ubicacionLng?.toStringAsFixed(6) ?? 'N/A',
          usuario,
        ]);
      }

      // Convertir a CSV
      final csv = const ListToCsvConverter().convert(csvData);

      // Obtener directorio para guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/historial_riesgos_$timestamp.csv';

      // Guardar archivo
      final file = File(filePath);
      await file.writeAsString(csv);

      return filePath;
    } catch (e) {
      throw Exception('Error al exportar a CSV: $e');
    }
  }

  /// Exporta una lista de mediciones a formato PDF
  /// Retorna la ruta del archivo generado
  static Future<String> exportToPDF(List<RiskMeasurement> measurements) async {
    try {
      final pdf = pw.Document();

      // Titulo y encabezado
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              pw.Center(
                child: pw.Text(
                  'Historial de Mediciones de Riesgo',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'Generado el ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Resumen',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Total de mediciones: ${measurements.length}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Detalles',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildMeasurementsTable(measurements),
            ];
          },
        ),
      );

      // Guardar archivo
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/historial_riesgos_$timestamp.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      return filePath;
    } catch (e) {
      throw Exception('Error al exportar a PDF: $e');
    }
  }

  /// Construye una tabla con los datos de las mediciones para el PDF
  static pw.Widget _buildMeasurementsTable(List<RiskMeasurement> measurements) {
    final tableData = <List<String>>[];

    // Encabezados
    tableData.add([
      'Nivel',
      'Etiqueta',
      'Fecha',
      'Hora',
      'Ubicación',
      'Usuario',
    ]);

    // Datos
    for (final measurement in measurements) {
      final fecha = measurement.fecha?.toDate();
      final fechaFormateada =
          fecha != null ? DateFormat('dd/MM/yyyy').format(fecha) : 'N/A';
      final horaFormateada =
          fecha != null ? DateFormat('HH:mm').format(fecha) : 'N/A';
      final usuario = measurement.user?['nombre'] ?? 'Desconocido';
      final ubicacion =
          '${measurement.ubicacionLat?.toStringAsFixed(2) ?? 'N/A'}, ${measurement.ubicacionLng?.toStringAsFixed(2) ?? 'N/A'}';

      tableData.add([
        measurement.nivelRiesgo.toStringAsFixed(2),
        measurement.nivelRiesgoLabel ?? 'N/A',
        fechaFormateada,
        horaFormateada,
        ubicacion,
        usuario,
      ]);
    }

    return pw.TableHelper.fromTextArray(
      data: tableData,
      border: pw.TableBorder.all(color: PdfColors.grey400),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellPadding: const pw.EdgeInsets.all(5),
      cellStyle: const pw.TextStyle(fontSize: 9),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(1.5),
      },
    );
  }

  /// Comparte un archivo exportado
  static Future<void> shareFile(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = file.path.split('/').last;
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Historial de Riesgos - $fileName',
      );
    } catch (e) {
      throw Exception('Error al compartir archivo: $e');
    }
  }
}
