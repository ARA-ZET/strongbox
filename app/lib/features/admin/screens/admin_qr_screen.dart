import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/models/storage_unit.dart';
import '../providers/clients_providers.dart';
import '../providers/inventory_providers.dart';
import '../providers/qr_providers.dart';
import '../utils/qr_pdf_generator.dart';
import '../widgets/unit_size_field.dart';

/// QR Codes Management: batch label generation and linking pre-printed
/// codes to boxes. Design: admin_qr_management/screen.png.
class AdminQrScreen extends ConsumerStatefulWidget {
  const AdminQrScreen({super.key, this.initialTab = 0});

  /// 0 = Generate Batch, 1 = Link QR to Box (deep-linked via ?tab=link).
  final int initialTab;

  @override
  ConsumerState<AdminQrScreen> createState() => _AdminQrScreenState();
}

class _AdminQrScreenState extends ConsumerState<AdminQrScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: 2,
    vsync: this,
    initialIndex: widget.initialTab.clamp(0, 1),
  );

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      return Padding(
        padding: EdgeInsets.all(desktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QR Codes Management', style: textTheme.displaySmall),
            const SizedBox(height: 4),
            Text(
              'Streamline asset tracking by generating batch labels or '
              'linking hardware to specific logistics containers.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.accentDeep,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.accentDeep,
              indicatorWeight: 3,
              labelStyle: textTheme.labelLarge,
              tabs: const [
                Tab(text: 'Generate Batch'),
                Tab(text: 'Link QR to Box'),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _GenerateBatchTab(desktop: desktop),
                  const _LinkQrTab(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ------------------------------------------------------ generate batch tab

class _GenerateBatchTab extends ConsumerStatefulWidget {
  const _GenerateBatchTab({required this.desktop});

  final bool desktop;

  @override
  ConsumerState<_GenerateBatchTab> createState() => _GenerateBatchTabState();
}

class _GenerateBatchTabState extends ConsumerState<_GenerateBatchTab> {
  String _resolution = 'high';
  bool _printing = false;

  Future<void> _generateAndPrint() async {
    final count = ref.read(batchPreviewProvider).length;
    setState(() => _printing = true);
    try {
      final codes = await ref
          .read(qrMutationsProvider.notifier)
          .createBatch(count, _resolution == 'high' ? '300dpi' : '150dpi');
      await printQrLabels(codes);
      // Fresh codes for the next batch so the same sheet can't be
      // committed twice.
      ref.read(batchPreviewProvider.notifier).regenerate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Batch of ${codes.length} labels saved')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate batch: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = _SettingsPanel(
      resolution: _resolution,
      printing: _printing,
      onResolutionChanged: (value) => setState(() => _resolution = value),
      onGenerate: _generateAndPrint,
    );
    const preview = _PreviewPanel();

    if (widget.desktop) {
      return SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 40, child: settings),
            const SizedBox(width: 24),
            const Expanded(flex: 60, child: preview),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [settings, const SizedBox(height: 24), preview],
      ),
    );
  }
}

class _SettingsPanel extends ConsumerWidget {
  const _SettingsPanel({
    required this.resolution,
    required this.printing,
    required this.onResolutionChanged,
    required this.onGenerate,
  });

  final String resolution;
  final bool printing;
  final ValueChanged<String> onResolutionChanged;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(batchPreviewProvider).length;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Batch Settings', style: textTheme.headlineSmall),
          const SizedBox(height: 20),
          Text('Number of Labels', style: textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              _StepperButton(
                icon: Icons.remove,
                onPressed: count > 1
                    ? () => ref
                        .read(batchPreviewProvider.notifier)
                        .setCount(count - 1)
                    : null,
              ),
              Expanded(
                child: Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('$count', style: textTheme.titleMedium),
                ),
              ),
              _StepperButton(
                icon: Icons.add,
                onPressed: count < 100
                    ? () => ref
                        .read(batchPreviewProvider.notifier)
                        .setCount(count + 1)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Print Resolution', style: textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: resolution,
            items: const [
              DropdownMenuItem(value: 'high', child: Text('High (300 DPI)')),
              DropdownMenuItem(
                  value: 'standard', child: Text('Standard (150 DPI)')),
            ],
            onChanged: (value) {
              if (value != null) onResolutionChanged(value);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
              ),
              onPressed: printing ? null : onGenerate,
              icon: printing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.print_outlined, size: 20),
              label: const Text('Generate & Print PDF'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: AppColors.border),
        ),
        onPressed: onPressed,
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _PreviewPanel extends ConsumerWidget {
  const _PreviewPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codes = ref.watch(batchPreviewProvider);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Preview Grid', style: textTheme.headlineSmall),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.statusSuccess,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Ready for Export',
                  style: textTheme.bodySmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            final columns = constraints.maxWidth > 560
                ? 4
                : constraints.maxWidth > 380
                    ? 3
                    : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 150,
              ),
              itemCount: codes.length,
              itemBuilder: (context, index) => Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: QrImageView(
                        data: codes[index],
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.navy,
                        ),
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      codes[index],
                      style: textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- link QR tab

class _LinkQrTab extends ConsumerStatefulWidget {
  const _LinkQrTab();

  @override
  ConsumerState<_LinkQrTab> createState() => _LinkQrTabState();
}

class _LinkQrTabState extends ConsumerState<_LinkQrTab> {
  final _codeController = TextEditingController();
  final _labelController = TextEditingController();

  QrLookupStatus? _lookup;
  String? _lookedUpCode;
  bool _busy = false;

  String? _clientId;
  bool _createNew = true;
  UnitType _newBoxType = UnitType.closed;
  String? _newPriceKey;
  String? _existingBoxId;

  @override
  void dispose() {
    _codeController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() {
      _busy = true;
      _lookup = null;
    });
    try {
      final status =
          await ref.read(qrMutationsProvider.notifier).lookupCode(code);
      setState(() {
        _lookup = status;
        _lookedUpCode = code;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmLink() async {
    final code = _lookedUpCode;
    final clientId = _clientId;
    if (code == null || clientId == null) return;
    if (!_createNew && _existingBoxId == null) return;
    final priceKey = _newPriceKey;
    if (_createNew && priceKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a size — it sets the price')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      if (_createNew) {
        final unitId = await ref.read(unitMutationsProvider.notifier).addUnit(
              clientId: clientId,
              type: _newBoxType,
              label: _labelController.text.trim(),
              priceKey: priceKey!,
              qrCodeId: code,
            );
        await ref.read(qrMutationsProvider.notifier).linkToUnit(code, unitId);
      } else {
        await ref
            .read(qrMutationsProvider.notifier)
            .linkToUnit(code, _existingBoxId!);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Code $code linked successfully')),
        );
        setState(() {
          _lookup = null;
          _lookedUpCode = null;
          _codeController.clear();
          _labelController.clear();
          _existingBoxId = null;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not link code: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camera scanning ships with the driver scanner in Stage 5;
            // manual entry covers the admin flow until then.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner,
                      color: AppColors.sky, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Enter a pre-printed QR code ID below to link it',
                    style:
                        textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('QR Code ID', style: textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration:
                        const InputDecoration(hintText: 'SBX-1115-B7'),
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => _check(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: _busy ? null : _check,
                  child: const Text('Check'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._buildLookupResult(textTheme),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLookupResult(TextTheme textTheme) {
    switch (_lookup) {
      case null:
        return [];
      case QrLookupStatus.alreadyLinked:
        return [
          _banner(
            'This code is already linked to a box.',
            AppColors.statusErrorBg,
            AppColors.statusError,
            textTheme,
          ),
        ];
      case QrLookupStatus.unknown:
        return [
          _banner(
            'Code not found in any printed batch — double-check the ID. '
            'You can still link it below.',
            AppColors.statusWarningBg,
            AppColors.statusWarning,
            textTheme,
          ),
          ..._linkForm(textTheme),
        ];
      case QrLookupStatus.available:
        return [
          _banner(
            'Code $_lookedUpCode is available to link.',
            AppColors.statusSuccessBg,
            AppColors.statusSuccess,
            textTheme,
          ),
          ..._linkForm(textTheme),
        ];
    }
  }

  Widget _banner(
      String message, Color bg, Color fg, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: textTheme.bodyMedium?.copyWith(color: fg)),
    );
  }

  List<Widget> _linkForm(TextTheme textTheme) {
    final clients = ref.watch(clientsProvider).valueOrNull ?? [];

    return [
      Text('Client', style: textTheme.labelLarge),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        initialValue: _clientId,
        hint: const Text('Select client'),
        items: [
          for (final client in clients)
            DropdownMenuItem(value: client.id, child: Text(client.displayName)),
        ],
        onChanged: (value) => setState(() {
          _clientId = value;
          _existingBoxId = null;
        }),
      ),
      const SizedBox(height: 16),
      Text('Assign to', style: textTheme.labelLarge),
      const SizedBox(height: 4),
      RadioGroup<bool>(
        groupValue: _createNew,
        onChanged: (value) => setState(() => _createNew = value ?? true),
        child: const Column(
          children: [
            RadioListTile<bool>(
              value: true,
              title: Text('New box'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            RadioListTile<bool>(
              value: false,
              title: Text('Existing box'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      if (_createNew) ...[
        UnitSizeField(
          value: _newPriceKey,
          onChanged: (value) => setState(() => _newPriceKey = value),
        ),
        const SizedBox(height: 12),
        SegmentedButton<UnitType>(
          segments: const [
            ButtonSegment(value: UnitType.closed, label: Text('Closed Box')),
            ButtonSegment(value: UnitType.open, label: Text('Open Box')),
          ],
          selected: {_newBoxType},
          onSelectionChanged: (selection) =>
              setState(() => _newBoxType = selection.first),
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: AppColors.skyTint,
            selectedForegroundColor: AppColors.accentDeep,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _labelController,
          decoration: const InputDecoration(hintText: 'Box label'),
        ),
      ] else
        _ExistingBoxDropdown(
          clientId: _clientId,
          value: _existingBoxId,
          onChanged: (value) => setState(() => _existingBoxId = value),
        ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _busy ? null : _confirmLink,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.accentDeep),
                )
              : const Text('Confirm Link'),
        ),
      ),
    ];
  }
}

/// Dropdown of the selected client's boxes (or all boxes when no client).
class _ExistingBoxDropdown extends ConsumerWidget {
  const _ExistingBoxDropdown({
    required this.clientId,
    required this.value,
    required this.onChanged,
  });

  final String? clientId;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boxes = ref.watch(allUnitsProvider).valueOrNull ?? <StorageUnit>[];
    final candidates = boxes
        .where((box) =>
            box.status != StorageStatus.archived &&
            (clientId == null || box.clientId == clientId))
        .toList();

    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: const Text('Select box'),
      items: [
        for (final box in candidates)
          DropdownMenuItem(
            value: box.id,
            child: Text(
              box.label.isEmpty ? box.qrCodeId : '${box.qrCodeId} — ${box.label}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
