import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'qr_link.dart';

const _mm = PdfPageFormat.mm;

// Standard A4 21-up sticker sheet (Avery L7160 and equivalents): 3 × 7
// labels of 63.5 × 38.1 mm, 2.5 mm between columns. Prints fine on plain
// paper too — the faint outline is the cutting guide.
const _columns = 3;
const _rows = 7;
const _perPage = _columns * _rows;
const _labelWidth = 63.5 * _mm;
const _labelHeight = 38.1 * _mm;
const _columnGap = 2.5 * _mm;
const _sideMargin = (210 - 3 * 63.5 - 2 * 2.5) / 2 * _mm;
const _topMargin = (297 - 7 * 38.1) / 2 * _mm;

/// 28 mm leaves ≥ 4 modules of blank quiet zone round the code inside the
/// label — scanners need it, and nothing else may print there.
const _qrSize = 28 * _mm;

/// Builds an A4 sheet of QR labels, 21 per page. Each QR links to its item
/// ([qrPayload]) so a phone's own camera opens it, with quartile error
/// correction so a label still scans when up to ~25% is scuffed or torn.
/// The code and the item's name ([labels]) sit beside it.
Future<Uint8List> generateQrLabelPdf(
  List<String> codes, {
  Map<String, String> labels = const {},
}) async {
  final doc = pw.Document(title: 'StrongBox QR labels');

  for (var start = 0; start < codes.length; start += _perPage) {
    final page = codes.skip(start).take(_perPage).toList();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        // No bottom margin: seven rows fill the page exactly, and rounding
        // would otherwise push the last row off it.
        margin: const pw.EdgeInsets.fromLTRB(
            _sideMargin, _topMargin, _sideMargin, 0),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (var row = 0; row * _columns < page.length; row++)
              pw.Row(
                children: [
                  for (var col = 0; col < _columns; col++) ...[
                    if (col > 0) pw.SizedBox(width: _columnGap),
                    if (row * _columns + col < page.length)
                      _label(page[row * _columns + col],
                          labels[page[row * _columns + col]])
                    else
                      pw.SizedBox(width: _labelWidth, height: _labelHeight),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  return doc.save();
}

pw.Widget _label(String code, String? label) {
  return pw.Container(
    width: _labelWidth,
    height: _labelHeight,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300, width: 0.3),
    ),
    child: pw.Row(
      children: [
        pw.SizedBox(width: 4 * _mm),
        pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(
              errorCorrectLevel: pw.BarcodeQRCorrectionLevel.quartile),
          data: qrPayload(code),
          width: _qrSize,
          height: _qrSize,
          drawText: false,
        ),
        pw.SizedBox(width: 4 * _mm),
        pw.Expanded(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('StrongBox',
                  style: pw.TextStyle(
                      fontSize: 7,
                      color: PdfColors.grey700,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 1.5 * _mm),
              pw.Text(code,
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
              if (label != null && label.isNotEmpty) ...[
                pw.SizedBox(height: 1 * _mm),
                pw.Text(label,
                    style: const pw.TextStyle(fontSize: 8),
                    maxLines: 2),
              ],
            ],
          ),
        ),
        pw.SizedBox(width: 2 * _mm),
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
    name: 'StrongBox QR labels',
    onLayout: (format) => generateQrLabelPdf(codes, labels: labels),
  );
}
