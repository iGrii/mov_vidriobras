import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/reporte_model.dart';
import '../services/reportes_service.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final ReportesService _service = ReportesService();

  bool _cargando = true;
  bool _exportandoPdf = false;
  String? _error;

  List<ReporteProducto> _reportes = [];
  ResumenReportes? _resumen;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    if (!mounted) return;
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final reportesResp = await _service.obtenerReportes(limit: 200);
      final resumenResp = await _service.obtenerResumen();

      if (!mounted) return;
      setState(() {
        _reportes = reportesResp.reportes;
        _resumen = resumenResp;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los reportes';
        _cargando = false;
      });
    }
  }

  Future<void> _generarPdf() async {
    if (_exportandoPdf) return;

    setState(() => _exportandoPdf = true);
    try {
      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          build: (context) {
            return [
              pw.Text(
                'Reporte de productos',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Total de movimientos: ${_resumen?.total ?? 0}'),
              pw.Text('Crear: ${_resumen?.crear ?? 0}'),
              pw.Text('Editar: ${_resumen?.editar ?? 0}'),
              pw.Text('Eliminar: ${_resumen?.eliminar ?? 0}'),
              pw.SizedBox(height: 14),
              pw.Text(
                'Detalle',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              ..._reportes.map(
                (r) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${r.tipoEtiqueta} - ${r.productoNombre}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        if (r.productoCodigo != null &&
                            r.productoCodigo!.isNotEmpty)
                          pw.Text('Codigo: ${r.productoCodigo}'),
                        pw.Text('Fecha: ${r.fechaFormateada}'),
                        if (r.usuario != null && r.usuario!.isNotEmpty)
                          pw.Text('Usuario: ${r.usuario}'),
                        if (r.detalles != null && r.detalles!.isNotEmpty)
                          pw.Text('Detalle: ${r.detalles}'),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
        ),
      );

      final bytes = await doc.save();
      await Printing.layoutPdf(onLayout: (format) async => bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo generar el PDF')),
      );
    } finally {
      if (mounted) {
        setState(() => _exportandoPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9D2612),
        title: const Text('Reportes', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: _exportandoPdf ? null : _generarPdf,
            icon: _exportandoPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.picture_as_pdf, color: Colors.white),
            tooltip: 'Generar PDF',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? ListView(
                children: [
                  const SizedBox(height: 140),
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 12),
                  Center(child: Text(_error!)),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton(
                      onPressed: _cargarDatos,
                      child: const Text('Reintentar'),
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _ResumenCard(resumen: _resumen),
                  const SizedBox(height: 12),
                  const Text(
                    'Movimientos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (_reportes.isEmpty)
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.inbox_outlined),
                        title: Text('No hay movimientos para mostrar'),
                      ),
                    ),
                  ..._reportes.map((r) => _ReporteCard(reporte: r)),
                ],
              ),
      ),
    );
  }
}

class _ReporteCard extends StatelessWidget {
  final ReporteProducto reporte;

  const _ReporteCard({required this.reporte});

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'CREAR':
        return const Color(0xFF1B8A4C);
      case 'EDITAR':
        return const Color(0xFF1565C0);
      case 'ELIMINAR':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF5F6368);
    }
  }

  IconData _iconoTipo(String tipo) {
    switch (tipo) {
      case 'CREAR':
        return Icons.add_circle_outline;
      case 'EDITAR':
        return Icons.edit_outlined;
      case 'ELIMINAR':
        return Icons.delete_outline;
      default:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipo = reporte.tipoNormalizado;
    final color = _colorTipo(tipo);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconoTipo(tipo), color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reporte.productoNombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          reporte.tipoEtiqueta,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (reporte.productoCodigo != null &&
                      reporte.productoCodigo!.isNotEmpty)
                    Text('Codigo: ${reporte.productoCodigo}'),
                  Text('Fecha: ${reporte.fechaFormateada}'),
                  if (reporte.usuario != null && reporte.usuario!.isNotEmpty)
                    Text('Usuario: ${reporte.usuario}'),
                  if (reporte.detalles != null && reporte.detalles!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        reporte.detalles!,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final ResumenReportes? resumen;

  const _ResumenCard({required this.resumen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text('Total: ${resumen?.total ?? 0}'),
          Text('Crear: ${resumen?.crear ?? 0}'),
          Text('Editar: ${resumen?.editar ?? 0}'),
          Text('Eliminar: ${resumen?.eliminar ?? 0}'),
        ],
      ),
    );
  }
}
