import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../enums/app_enums.dart';
import '../models/business_settings.dart';
import '../models/client.dart';
import '../models/invoice.dart';
import '../models/price_catalog.dart';
import '../theme/app_colors.dart';
import 'currency.dart';

final _date = DateFormat('d MMM y');

PdfColor _pdf(Color color) => PdfColor.fromInt(color.toARGB32());

/// An A4 invoice: business header, billed-to, one row per unit, total and
/// how to pay by EFT with the invoice's reference.
Future<Uint8List> generateInvoicePdf(
  Invoice invoice, {
  required Client client,
  required BusinessSettings business,
  required PriceCatalog prices,
}) {
  final doc = pw.Document(title: invoice.reference, author: business.name);
  final muted = pw.TextStyle(fontSize: 9, color: _pdf(AppColors.textSecondary));
  final bold = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
  final address = business.address;
  final clientAddress = client.address;

  pw.Widget cell(String text, {pw.TextStyle? style, bool right = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        child: pw.Text(text,
            style: style ?? const pw.TextStyle(fontSize: 10),
            textAlign: right ? pw.TextAlign.right : pw.TextAlign.left),
      );

  final status = switch (invoice.status) {
    PaymentStatus.paid => 'PAID',
    PaymentStatus.voided => 'VOID',
    PaymentStatus.uncollectible => 'UNCOLLECTIBLE',
    PaymentStatus.open => 'DUE',
  };

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(18 * PdfPageFormat.mm),
      build: (context) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(business.name,
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: _pdf(AppColors.navyDeep))),
                pw.SizedBox(height: 4),
                for (final line in [
                  address.line1,
                  address.line2 ?? '',
                  [address.city, address.postCode]
                      .where((s) => s.isNotEmpty)
                      .join(' '),
                  business.contactPhone,
                  business.contactEmail,
                ].where((line) => line.isNotEmpty))
                  pw.Text(line, style: muted),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('INVOICE',
                    style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: _pdf(AppColors.accentDeep))),
                pw.SizedBox(height: 4),
                pw.Text(invoice.reference, style: bold),
                pw.Text(status, style: bold),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 24),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('BILLED TO', style: muted),
                  pw.SizedBox(height: 2),
                  pw.Text(client.displayName, style: bold),
                  for (final line in [
                    clientAddress.line1,
                    clientAddress.line2 ?? '',
                    clientAddress.city,
                    client.email,
                  ].where((line) => line.isNotEmpty))
                    pw.Text(line, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (invoice.createdAt != null)
                  pw.Text('Issued ${_date.format(invoice.createdAt!)}',
                      style: const pw.TextStyle(fontSize: 10)),
                if (invoice.dueAt != null)
                  pw.Text('Due ${_date.format(invoice.dueAt!)}', style: bold),
                if (invoice.paidAt != null)
                  pw.Text('Paid ${_date.format(invoice.paidAt!)}',
                      style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Text(invoice.description ?? 'Storage', style: bold),
        pw.SizedBox(height: 6),
        pw.Table(
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(4),
            2: pw.FlexColumnWidth(2),
          },
          border: pw.TableBorder(
            horizontalInside: pw.BorderSide(
                color: _pdf(AppColors.border), width: 0.5),
          ),
          children: [
            pw.TableRow(
              decoration:
                  pw.BoxDecoration(color: _pdf(AppColors.surfaceContainer)),
              children: [
                cell('UNIT', style: bold),
                cell('DESCRIPTION', style: bold),
                cell('PER MONTH', style: bold, right: true),
              ],
            ),
            for (final line in invoice.lines)
              pw.TableRow(children: [
                cell(line.qrCodeId),
                cell([
                  if (line.label.isNotEmpty) line.label,
                  prices.labelFor(line.priceKey) ?? '',
                ].where((s) => s.isNotEmpty).join(' · ')),
                cell(formatZarExact(line.rateZar), right: true),
              ]),
          ],
        ),
        pw.Divider(color: _pdf(AppColors.border)),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text('Total  ', style: bold),
            pw.Text(formatZarExact(invoice.amount),
                style: pw.TextStyle(
                    fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Prices include 15% VAT.', style: muted),
        ),
        pw.SizedBox(height: 28),
        if (invoice.isOpen) ...[
          pw.Text('HOW TO PAY', style: muted),
          pw.SizedBox(height: 4),
          pw.Text('EFT, quoting reference ${invoice.reference}.',
              style: bold),
          if (business.paymentInstructions.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(business.paymentInstructions,
                style: const pw.TextStyle(fontSize: 10)),
          ],
        ],
        if (invoice.status == PaymentStatus.voided &&
            (invoice.voidReason ?? '').isNotEmpty)
          pw.Text('Voided: ${invoice.voidReason}', style: muted),
      ],
    ),
  );
  return doc.save();
}

/// Opens the platform print / save-as-PDF dialog for [invoice].
Future<void> printInvoice(
  Invoice invoice, {
  required Client client,
  required BusinessSettings business,
  required PriceCatalog prices,
}) =>
    Printing.layoutPdf(
      name: invoice.reference.isEmpty ? 'invoice' : invoice.reference,
      onLayout: (_) => generateInvoicePdf(invoice,
          client: client, business: business, prices: prices),
    );
