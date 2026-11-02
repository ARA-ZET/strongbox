import 'package:flutter/material.dart';

import '../enums/app_enums.dart';
import '../models/storage_unit.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/qr_label_pdf.dart';
import 'dialog_actions.dart';

/// Pick boxes and items, then print their QR labels — an A4 sheet, 12
/// per page, each label naming its box or item. Units without a code yet
/// and archived units aren't listed.
///
/// With [groupNames] (client id → name) the list is grouped by client,
/// each group with its own tick-all — the admin view.
class LabelPrintDialog extends StatefulWidget {
  const LabelPrintDialog({
    super.key,
    required this.units,
    this.preselected = const {},
    this.groupNames,
  });

  final List<StorageUnit> units;

  /// Unit ids ticked when the dialog opens.
  final Set<String> preselected;
  final Map<String, String>? groupNames;

  static Future<void> show(
    BuildContext context, {
    required List<StorageUnit> units,
    Set<String> preselected = const {},
    Map<String, String>? groupNames,
  }) => showDialog<void>(
    context: context,
    builder: (_) => LabelPrintDialog(
      units: units,
      preselected: preselected,
      groupNames: groupNames,
    ),
  );

  @override
  State<LabelPrintDialog> createState() => _LabelPrintDialogState();
}

class _LabelPrintDialogState extends State<LabelPrintDialog> {
  late final List<StorageUnit> _printable = widget.units
      .where((u) => u.qrCodeId.isNotEmpty && u.status != StorageStatus.archived)
      .toList();
  late final Set<String> _selected = {
    for (final u in _printable)
      if (widget.preselected.contains(u.id)) u.id,
  };
  String _query = '';
  bool _printing = false;

  List<StorageUnit> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _printable;
    return _printable.where((u) {
      final client = widget.groupNames?[u.clientId] ?? '';
      return u.label.toLowerCase().contains(q) ||
          u.qrCodeId.toLowerCase().contains(q) ||
          client.toLowerCase().contains(q);
    }).toList();
  }

  void _toggleAll(Iterable<StorageUnit> units, bool on) => setState(() {
    for (final u in units) {
      on ? _selected.add(u.id) : _selected.remove(u.id);
    }
  });

  Future<void> _print() async {
    final chosen = _printable.where((u) => _selected.contains(u.id)).toList();
    if (chosen.isEmpty) return;
    setState(() => _printing = true);
    final navigator = Navigator.of(context);
    try {
      await printQrLabels(
        [for (final u in chosen) u.qrCodeId],
        labels: {for (final u in chosen) u.qrCodeId: u.label},
      );
      navigator.pop();
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  Widget _tile(StorageUnit unit, TextTheme tt) => CheckboxListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    controlAffinity: ListTileControlAffinity.leading,
    value: _selected.contains(unit.id),
    onChanged: (on) => _toggleAll([unit], on ?? false),
    title: Text(
      unit.label.isEmpty ? 'Storage unit' : unit.label,
      style: tt.bodyMedium,
    ),
    subtitle: Text(
      '${unit.qrCodeId} · ${unit.status.label}',
      style: tt.bodySmall,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final visible = _visible;
    final names = widget.groupNames;
    final count = _selected.length;

    final List<Widget> rows;
    if (names == null) {
      rows = [for (final u in visible) _tile(u, tt)];
    } else {
      final groups = <String, List<StorageUnit>>{};
      for (final u in visible) {
        groups.putIfAbsent(u.clientId, () => []).add(u);
      }
      final ids = groups.keys.toList()
        ..sort(
          (a, b) => (names[a] ?? '~').toLowerCase().compareTo(
            (names[b] ?? '~').toLowerCase(),
          ),
        );
      rows = [
        for (final id in ids) ...[
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            tristate: true,
            value: _groupValue(groups[id]!),
            onChanged: (_) =>
                _toggleAll(groups[id]!, _groupValue(groups[id]!) != true),
            title: Text(names[id] ?? 'Unknown client', style: tt.titleSmall),
          ),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.lg),
            child: Column(
              children: [for (final u in groups[id]!) _tile(u, tt)],
            ),
          ),
        ],
      ];
    }

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Print QR labels', style: tt.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tick the boxes and items to label. Each label shows which '
                'one it belongs to — stick it somewhere easy to scan.',
                style: tt.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              if (_printable.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    'Nothing has a QR code yet.',
                    style: tt.bodyMedium,
                  ),
                )
              else ...[
                if (_printable.length > 8) ...[
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search by name, code or client',
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$count selected',
                        style: tt.labelLarge?.copyWith(
                          color: AppColors.accentDeep,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _toggleAll(visible, true),
                      child: const Text('Select all'),
                    ),
                    TextButton(
                      onPressed: count == 0
                          ? null
                          : () => setState(_selected.clear),
                      child: const Text('None'),
                    ),
                  ],
                ),
                const Divider(height: 1),
                Flexible(child: ListView(shrinkWrap: true, children: rows)),
                const Divider(height: 1),
              ],
              const SizedBox(height: AppSpacing.md),
              DialogActions(
                saveLabel: count == 0
                    ? 'Print'
                    : 'Print $count ${count == 1 ? 'label' : 'labels'}',
                saving: _printing,
                onSave: count == 0 ? null : _print,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// true = all ticked, false = none, null = some.
  bool? _groupValue(List<StorageUnit> units) {
    final ticked = units.where((u) => _selected.contains(u.id)).length;
    if (ticked == 0) return false;
    return ticked == units.length ? true : null;
  }
}
