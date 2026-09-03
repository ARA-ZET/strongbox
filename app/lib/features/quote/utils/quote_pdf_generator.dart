import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/constants/quote_pricing.dart';
import '../../../core/models/quote.dart';
import '../../../core/utils/currency.dart';

/// Builds a one-page A4 quote the client can keep or forward, mirroring
/// the on-screen breakdown.
Future<Uint8List> generateQuotePdf(Quote quote) async {
  final doc = pw.Document();
  final vehicle = QuotePricing.vehicleTier(quote.vehicle);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(18 * PdfPageFormat.mm),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('StrongBox',
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Storage Quote',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text(quote.reference,
                      style: const pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey700)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 4 * PdfPageFormat.mm),
          pw.Divider(color: PdfColors.grey400),
          if (quote.contactName.isNotEmpty) ...[
            pw.SizedBox(height: 2 * PdfPageFormat.mm),
            pw.Text('Prepared for ${quote.contactName}',
                style: const pw.TextStyle(fontSize: 10)),
          ],
          pw.SizedBox(height: 6 * PdfPageFormat.mm),

          _sectionTitle('Monthly storage'),
          for (final line in quote.activeBoxes)
            _row(
              '${line.quantity} × ${QuotePricing.boxTier(line.size).name}',
              formatZarExact(line.monthlyZar),
            ),
          for (final item in quote.looseItems)
            _row(
              '${item.quantity} × ${item.name} (${item.dimensionsLabel})',
              formatZarExact(item.lineMonthlyZar),
            ),
          _row('Monthly total', formatZarExact(quote.monthlyTotalZar),
              bold: true),

          pw.SizedBox(height: 6 * PdfPageFormat.mm),
          _sectionTitle('Once-off services'),
          _row('${vehicle.name} collection',
              formatZarExact(quote.collectionFeeZar)),
          if (quote.packingRequired)
            _row(
              'Packing assistance '
              '(${quote.packers} packers × ${quote.packingHours}h)',
              formatZarExact(quote.packingFeeZar),
            ),

          pw.SizedBox(height: 6 * PdfPageFormat.mm),
          pw.Container(
            padding: const pw.EdgeInsets.all(4 * PdfPageFormat.mm),
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            child: pw.Column(
              children: [
                _row('Due today', formatZarExact(quote.dueTodayTotalZar),
                    bold: true),
                _row('Monthly from month 2',
                    formatZarExact(quote.monthlyTotalZar)),
              ],
            ),
          ),

          pw.SizedBox(height: 6 * PdfPageFormat.mm),
          pw.Text(
            'Estimated volume: ${quote.volumeM3.toStringAsFixed(1)} m³. '
            'Insurance cover up to '
            '${formatZar(QuotePricing.includedInsuranceZar)} is included. '
            'One free retrieval every '
            '${QuotePricing.freeRetrievalEveryMonths} months.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          pw.Text(
            'Final pricing is confirmed on collection once our team has '
            'seen the items.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    ),
  );

  return doc.save();
}

pw.Widget _sectionTitle(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2 * PdfPageFormat.mm),
      child: pw.Text(
        text.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey700,
        ),
      ),
    );

pw.Widget _row(String label, String value, {bool bold = false}) {
  final style = pw.TextStyle(
    fontSize: 11,
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
  );

  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1.2 * PdfPageFormat.mm),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(child: pw.Text(label, style: style)),
        pw.Text(value, style: style),
      ],
    ),
  );
}
