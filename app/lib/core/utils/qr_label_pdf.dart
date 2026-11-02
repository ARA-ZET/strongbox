import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Builds an A4 sheet of QR labels: 4 columns × 3 rows (12 per page),
/// each cell 52mm × 35mm with the StrongBox wordmark, QR code and ID.
Future<Uint8List> generateQrLabelPdf(
  List<String> codes, {
  Map<String, String> labels = const {},
}) async {
  final doc = pw.Document();
  const perPage = 12;

  for (var start = 0; start < codes.length; start += perPage) {
    final page = codes.skip(start).take(perPage).toList();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(12 * PdfPageFormat.mm),
        build: (context) => pw.Wrap(
          spacing: 4 * PdfPageFormat.mm,
          runSpacing: 4 * PdfPageFormat.mm,
          children: [for (final code in page) _labelCell(code, labels[code])],
        ),
      ),
    );
  }

  return doc.save();
}

pw.Widget _labelCell(String code, String? label) {
  return pw.Container(
    width: 42 * PdfPageFormat.mm,
    height: 35 * PdfPageFormat.mm,
    padding: const pw.EdgeInsets.all(2 * PdfPageFormat.mm),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
    ),
    child: pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          'StrongBox',
          style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 1.5 * PdfPageFormat.mm),
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: code,
          width: 20 * PdfPageFormat.mm,
          height: 20 * PdfPageFormat.mm,
          drawText: false,
        ),
        pw.SizedBox(height: 1.5 * PdfPageFormat.mm),
        pw.Text(
          code,
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        ),
        if (label != null && label.isNotEmpty)
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            maxLines: 1,
          ),
      ],
    ),
  );
}

/// Opens the platform print dialog for the given codes.
Future<void> printQrLabels(
  List<String> codes, {
  Map<String, String> labels = const {},
}) {
  return Printing.layoutPdf(
    onLayout: (format) => generateQrLabelPdf(codes, labels: labels),
  );
}
