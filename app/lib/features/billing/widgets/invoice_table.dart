import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/app_enums.dart';
import '../../../core/models/client.dart';
import '../../../core/models/invoice.dart';
import '../../../core/providers/business_settings_provider.dart';
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/utils/invoice_pdf.dart';
import '../../../core/widgets/app_data_table.dart';
import '../../../core/widgets/error_retry.dart';
import '../../../core/widgets/status_chip.dart';
import '../providers/billing_providers.dart';

final _date = DateFormat('d MMM y');

/// A client's invoices: period, reference, amount, due date, status and a
/// PDF download. With [canSettle] (admin), open invoices also get
/// "Mark paid" and "Void".
class InvoiceTable extends ConsumerWidget {
  const InvoiceTable({
    super.key,
    required this.invoices,
    required this.client,
    this.canSettle = false,
    this.onRetry,
  });

  final AsyncValue<List<Invoice>> invoices;
  final Client client;
  final bool canSettle;
  final VoidCallback? onRetry;

  static const _columns = [
    TableColumnSpec('Period', flex: 3),
    TableColumnSpec('Reference', flex: 3),
    TableColumnSpec('Amount', flex: 2),
    TableColumnSpec('Due', flex: 2),
    TableColumnSpec('Status', flex: 2),
    TableColumnSpec('', flex: 2),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();

    return invoices.when(
      loading: () =>
          const AppDataTable(columns: _columns, rows: [], isLoading: true),
      error: (error, _) => ErrorRetry(error: error, onRetry: onRetry),
      data: (list) {
        if (list.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.md,
              boxShadow: AppShadow.card,
            ),
            child: Text(
              'No invoices yet — the first one is issued on the 1st of the '
              'month after we collect.',
              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          );
        }
        return AppDataTable(
          columns: _columns,
          minWidth: 760,
          rows: [
            for (final invoice in list)
              [
                Text(invoice.description ?? 'Storage',
                    style: tt.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SelectableText(invoice.reference, style: tt.bodyMedium),
                Text(formatZarExact(invoice.amount),
                    style:
                        tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  invoice.dueAt == null ? '—' : _date.format(invoice.dueAt!),
                  style: tt.bodyMedium?.copyWith(
                      color: invoice.isOverdue(now)
                          ? AppColors.statusError
                          : null),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: StatusChip(
                      status: invoice.isOverdue(now)
                          ? 'pastDue'
                          : invoice.status.name),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _InvoiceMenu(
                      invoice: invoice, client: client, canSettle: canSettle),
                ),
              ],
          ],
        );
      },
    );
  }
}

enum _Action { download, markPaid, voidInvoice }

class _InvoiceMenu extends ConsumerWidget {
  const _InvoiceMenu({
    required this.invoice,
    required this.client,
    required this.canSettle,
  });

  final Invoice invoice;
  final Client client;
  final bool canSettle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settle = canSettle && invoice.status == PaymentStatus.open;
    return PopupMenuButton<_Action>(
      tooltip: 'Invoice actions',
      icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
      onSelected: (action) => switch (action) {
        _Action.download => _download(context, ref),
        _Action.markPaid => showDialog<void>(
            context: context,
            builder: (_) => _SettleDialog(invoice: invoice, paid: true)),
        _Action.voidInvoice => showDialog<void>(
            context: context,
            builder: (_) => _SettleDialog(invoice: invoice, paid: false)),
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
            value: _Action.download, child: Text('Download PDF')),
        if (settle) ...[
          const PopupMenuItem(
              value: _Action.markPaid, child: Text('Mark paid…')),
          const PopupMenuItem(
              value: _Action.voidInvoice, child: Text('Void…')),
        ],
      ],
    );
  }

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    try {
      await printInvoice(
        invoice,
        client: client,
        business: ref.read(businessSettingsProvider),
        prices: ref.read(priceCatalogProvider),
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not create the PDF: $error')));
      }
    }
  }
}

/// Mark paid (optional note on how) or void (reason required).
class _SettleDialog extends ConsumerStatefulWidget {
  const _SettleDialog({required this.invoice, required this.paid});

  final Invoice invoice;
  final bool paid;

  @override
  ConsumerState<_SettleDialog> createState() => _SettleDialogState();
}

class _SettleDialogState extends ConsumerState<_SettleDialog> {
  final _text = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!widget.paid && _text.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final actions = ref.read(invoiceActionsProvider.notifier);
    try {
      if (widget.paid) {
        await actions.markPaid(widget.invoice, note: _text.text);
      } else {
        await actions.voidInvoice(widget.invoice, _text.text);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(
          content: Text(widget.paid
              ? '${widget.invoice.reference} marked paid'
              : '${widget.invoice.reference} voided')));
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
          SnackBar(content: Text('Could not update the invoice: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final tt = Theme.of(context).textTheme;
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(widget.paid ? 'Mark invoice paid' : 'Void invoice'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${invoice.reference} · ${formatZarExact(invoice.amount)}',
              style: tt.titleSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _text,
              autofocus: true,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: widget.paid
                    ? 'Payment note (optional)'
                    : 'Reason (required)',
                hintText: widget.paid
                    ? 'e.g. EFT received 12 Nov, FNB'
                    : 'e.g. Units returned in October',
              ),
            ),
            if (!widget.paid)
              Text('The client will no longer owe this invoice.',
                  style: tt.bodySmall),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: widget.paid
              ? null
              : ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusError,
                  foregroundColor: AppColors.onAccent),
          onPressed: _saving ? null : _submit,
          child: Text(widget.paid ? 'Mark paid' : 'Void invoice'),
        ),
      ],
    );
  }
}
