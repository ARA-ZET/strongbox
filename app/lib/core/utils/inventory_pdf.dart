import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../enums/app_enums.dart';
import '../models/business_settings.dart';
import '../models/client.dart';
import '../models/price_catalog.dart';
import '../models/storage_unit.dart';
import '../theme/app_colors.dart';
import 'currency.dart';
import 'public_ref.dart';

final _date = DateFormat('d MMM y');

PdfColor _pdf(Color color) => PdfColor.fromInt(color.toARGB32());

/// An A4 inventory report for a client: every box and item we hold or are
/// moving for them — QR code, description, status, bay and monthly rate —
/// with the monthly total. Delivered, cancelled and archived units are left
/// out.
Future<Uint8List> generateInventoryPdf(
  List<StorageUnit> units, {
  required Client client,
  required BusinessSettings business,
  required PriceCatalog prices,
  DateTime? now,
}) {
  final held = units.where((u) => u.status.isBillable ||
      u.status == StorageStatus.pendingPickup).toList()
    ..sort((a, b) => a.qrCodeId.compareTo(b.qrCodeId));
  final monthly = held
      .where((u) => u.status.isBillable)
      .fold(0, (total, u) => total + u.monthlyRateZar);
  final doc = pw.Document(title: 'StrongBox inventory', author: business.name);
  final muted = pw.TextStyle(fontSize: 9, color: _pdf(AppColors.textSecondary));
  final bold = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);

  pw.Widget cell(String text, {pw.TextStyle? style, bool right = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        child: pw.Text(text,
            style: style ?? const pw.TextStyle(fontSize: 10),
            textAlign: right ? pw.TextAlign.right : pw.TextAlign.left),
      );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(18 * PdfPageFormat.mm),
      build: (context) => [
        pw.Text(business.name,
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Inventory report · ${_date.format(now ?? DateTime.now())}',
            style: muted),
        pw.SizedBox(height: 16),
        pw.Text(client.displayName, style: bold),
        pw.Text('Account ${clientRef(client.id)}', style: muted),
        pw.SizedBox(height: 16),
        pw.Table(
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(4),
            2: pw.FlexColumnWidth(2),
            3: pw.FlexColumnWidth(1.4),
            4: pw.FlexColumnWidth(1.6),
          },
          border: pw.TableBorder(
            horizontalInside:
                pw.BorderSide(color: _pdf(AppColors.border), width: 0.5),
          ),
          children: [
            pw.TableRow(
              decoration:
                  pw.BoxDecoration(color: _pdf(AppColors.surfaceContainer)),
              children: [
                cell('QR CODE', style: bold),
                cell('DESCRIPTION', style: bold),
                cell('STATUS', style: bold),
                cell('BAY', style: bold),
                cell('PER MONTH', style: bold, right: true),
              ],
            ),
            for (final unit in held)
              pw.TableRow(children: [
                cell(unit.displayCode),
                cell([
                  if (unit.label.isNotEmpty) unit.label,
                  prices.labelFor(unit.priceKey) ?? '',
                  if (unit.condition == UnitCondition.damaged) 'damaged',
                ].where((s) => s.isNotEmpty).join(' · ')),
                cell(unit.status.label),
                cell(unit.warehouseLocationId ?? '—'),
                cell(formatZarExact(unit.monthlyRateZar), right: true),
              ]),
          ],
        ),
        pw.Divider(color: _pdf(AppColors.border)),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text('${held.length} items · monthly storage  ', style: bold),
            pw.Text(formatZarExact(monthly),
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
              'Awaiting-pickup items are listed but not charged yet. '
              'Prices include 15% VAT.',
              style: muted),
        ),
      ],
    ),
  );
  return doc.save();
}

/// Opens the platform print / save dialog for the client's inventory.
Future<void> printInventory(
  List<StorageUnit> units, {
  required Client client,
  required BusinessSettings business,
  required PriceCatalog prices,
}) =>
    Printing.layoutPdf(
      name: 'StrongBox inventory',
      onLayout: (_) => generateInventoryPdf(units,
          client: client, business: business, prices: prices),
    );
