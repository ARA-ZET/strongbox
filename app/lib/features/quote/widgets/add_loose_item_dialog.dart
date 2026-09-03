import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/quote_pricing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../providers/quote_draft_provider.dart';

/// "Add Loose Item" modal: pick a pre-priced catalogue item, or measure
/// something yourself and have it priced by volume.
///
/// Adds straight to the draft quote and closes.
class AddLooseItemDialog extends ConsumerStatefulWidget {
  const AddLooseItemDialog({super.key});

  /// Opens the modal over [context].
  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        builder: (context) => const AddLooseItemDialog(),
      );

  @override
  ConsumerState<AddLooseItemDialog> createState() => _AddLooseItemDialogState();
}

class _AddLooseItemDialogState extends ConsumerState<AddLooseItemDialog> {
  final _searchController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lengthController = TextEditingController(text: '0.8');
  final _widthController = TextEditingController(text: '0.6');
  final _heightController = TextEditingController(text: '0.5');

  int _quantity = 1;
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    _descriptionController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  double get _length => double.tryParse(_lengthController.text) ?? 0;
  double get _width => double.tryParse(_widthController.text) ?? 0;
  double get _height => double.tryParse(_heightController.text) ?? 0;
  double get _volume => _length * _width * _height;

  bool get _customValid =>
      _descriptionController.text.trim().isNotEmpty && _volume > 0;

  List<LooseItemPreset> get _matches {
    final query = _search.trim().toLowerCase();
    final presets = QuotePricing.looseItemPresets;
    if (query.isEmpty) return presets.take(9).toList();
    return presets
        .where((preset) => preset.name.toLowerCase().contains(query))
        .toList();
  }

  void _addPreset(LooseItemPreset preset) {
    ref.read(quoteDraftProvider.notifier).addPreset(preset);
    Navigator.of(context).pop();
  }

  void _addCustom() {
    ref.read(quoteDraftProvider.notifier).addCustomItem(
          name: _descriptionController.text.trim(),
          description: 'Custom · ${(_volume).toStringAsFixed(2)} m³',
          lengthM: _length,
          widthM: _width,
          heightM: _height,
          quantity: _quantity,
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: AppColors.scaffold,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Add Loose Item',
                        style: textTheme.headlineSmall),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _search = value),
                decoration: const InputDecoration(
                  hintText: 'Search standard items…',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surfaceContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _search.isEmpty ? 'POPULAR ITEMS' : 'MATCHES',
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (_matches.isEmpty)
                        Text(
                          'No standard item matches "$_search" — measure it '
                          'below and we will price it by volume.',
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        )
                      else
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final preset in _matches)
                              ActionChip(
                                label: Text(
                                    '${preset.emoji}  ${preset.name}  ·  '
                                    '${formatZar(preset.monthlyZar)}'),
                                onPressed: () => _addPreset(preset),
                              ),
                          ],
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm),
                            child: Text('OR',
                                style: textTheme.labelMedium?.copyWith(
                                    color: AppColors.textSecondary)),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _CustomItemForm(
                        descriptionController: _descriptionController,
                        lengthController: _lengthController,
                        widthController: _widthController,
                        heightController: _heightController,
                        quantity: _quantity,
                        volume: _volume,
                        onQuantityChanged: (value) =>
                            setState(() => _quantity = value),
                        onDimensionsChanged: () => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: 'Add to Quote',
                icon: null,
                onPressed: _customValid ? _addCustom : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomItemForm extends StatelessWidget {
  const _CustomItemForm({
    required this.descriptionController,
    required this.lengthController,
    required this.widthController,
    required this.heightController,
    required this.quantity,
    required this.volume,
    required this.onQuantityChanged,
    required this.onDimensionsChanged,
  });

  final TextEditingController descriptionController;
  final TextEditingController lengthController;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final int quantity;
  final double volume;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onDimensionsChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.amberDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Description', style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: descriptionController,
            onChanged: (_) => onDimensionsChanged(),
            decoration: const InputDecoration(
                hintText: 'e.g. Large antique mirror'),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _DimensionField(
                  label: 'Length (m)',
                  controller: lengthController,
                  onChanged: onDimensionsChanged,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DimensionField(
                  label: 'Width (m)',
                  controller: widthController,
                  onChanged: onDimensionsChanged,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DimensionField(
                  label: 'Height (m)',
                  controller: heightController,
                  onChanged: onDimensionsChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quantity', style: textTheme.labelLarge),
                  const SizedBox(height: AppSpacing.xs),
                  QuantityStepper(
                    value: quantity,
                    min: 1,
                    dense: true,
                    onChanged: onQuantityChanged,
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Estimated volume',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                  Text('${volume.toStringAsFixed(2)} m³',
                      style: textTheme.titleMedium
                          ?.copyWith(color: AppColors.amberDark)),
                  Text('${formatZar(QuotePricing.looseItemMonthly(volume))}/mo',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DimensionField extends StatelessWidget {
  const _DimensionField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}
