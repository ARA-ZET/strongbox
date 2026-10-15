import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/pricing.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/price_catalog_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/section_header.dart';
import '../providers/pricing_providers.dart';

/// Admin price list: box sizes, loose items and pickup vehicles. Saving an
/// entry writes it straight to the shared price list — the app updates at
/// once and the website within about five minutes. Units already in storage
/// keep the rate they were registered at.
class AdminPricingScreen extends ConsumerWidget {
  const AdminPricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final catalog = ref.watch(priceCatalogProvider);
    final live = ref.watch(livePriceCatalogProvider);
    final updatedAt = catalog.updatedAt;

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;
        return SingleChildScrollView(
          padding: EdgeInsets.all(desktop ? AppSpacing.lg : AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pricing', style: textTheme.displaySmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                updatedAt == null
                    ? 'Showing the default price list. Your first save makes it '
                          'yours. The website and the app both use these prices.'
                    : 'Shared by the app and the website (updates within about '
                          '5 minutes). Last saved '
                          '${DateFormat('d MMM y, HH:mm').format(updatedAt)}.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (live.hasError)
                _LoadErrorBanner(
                  message: _errorText(live.error!),
                  onRetry: () => ref.invalidate(livePriceCatalogProvider),
                ),
              _Section(
                title: 'Storage boxes · per box, per month',
                onAdd: () => _BoxDialog.show(context, ref, null),
                rows: [
                  for (final box in catalog.boxes)
                    _PriceRow(
                      icon: Icons.inventory_2_outlined,
                      title: box.label,
                      detail: box.description,
                      price: '${formatZar(box.monthlyZar)}/mo',
                      active: box.active,
                      onTap: () => _BoxDialog.show(context, ref, box),
                    ),
                ],
              ),
              _Section(
                title: 'Loose items · per item, per month',
                onAdd: () => _LooseItemDialog.show(context, ref, null),
                rows: [
                  for (final item in catalog.looseItems)
                    _PriceRow(
                      icon: iconForSymbol(item.icon),
                      title: item.name,
                      detail: item.category,
                      price: '${formatZar(item.monthlyZar)}/mo',
                      active: item.active,
                      onTap: () => _LooseItemDialog.show(context, ref, item),
                    ),
                ],
              ),
              _Section(
                title: 'Pickup vehicles · once-off per collection',
                onAdd: () => _VehicleDialog.show(context, ref, null),
                rows: [
                  for (final vehicle in catalog.vehicles)
                    _PriceRow(
                      icon: Icons.local_shipping_outlined,
                      title: vehicle.recommended
                          ? '${vehicle.label} · recommended'
                          : vehicle.label,
                      detail: vehicle.description,
                      price: formatZar(vehicle.onceOffZar),
                      active: vehicle.active,
                      onTap: () => _VehicleDialog.show(context, ref, vehicle),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A save or load failure as one readable line — the validation reason,
/// or the data layer's message plus its code so it can be looked up.
String _errorText(Object error) => switch (error) {
  StateError(:final message) => message,
  AppException(:final message, :final code) => '$message ($code)',
  _ => '$error',
};

// ------------------------------------------------------------------ layout

/// Shown when the live list can't be read: the rows below are the packaged
/// defaults, so saving now would overwrite what is stored.
class _LoadErrorBanner extends StatelessWidget {
  const _LoadErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.statusErrorBg,
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Could not load the live price list — showing the defaults. '
              '$message',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.statusError,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.onAdd,
    required this.rows,
  });

  final String title;
  final VoidCallback onAdd;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        children: [
          SectionHeader(
            title: title,
            action: TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...rows,
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.price,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String price;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = active ? null : AppColors.textHint;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.sm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: const BoxDecoration(
                color: AppColors.skyTint,
                borderRadius: AppRadius.sm,
              ),
              child: Icon(icon, size: 20, color: muted ?? AppColors.accentDeep),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(color: muted),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (detail.isNotEmpty)
                    Text(
                      detail,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (!active)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Text(
                  'Retired',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
            Text(
              price,
              style: textTheme.titleSmall?.copyWith(
                color: muted ?? AppColors.accentDeep,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------- dialogs

/// Shared editor chrome: fields and the on-sale switch. [onSave] writes to
/// Firestore; the dialog stays open with the reason if that fails. Saved
/// entries are retired (switched off sale) rather than removed, because
/// storage units keep pointing at them by id.
Future<void> _showEditor(
  BuildContext context, {
  required String title,
  required List<Widget> Function(StateSetter setState) fields,
  required bool isNew,
  required bool active,
  required ValueChanged<bool> onActive,
  required Future<void> Function() onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final messenger = ScaffoldMessenger.of(context);
  var isActive = active;
  var saving = false;
  String? error;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        Future<void> save() async {
          if (!formKey.currentState!.validate()) return;
          setState(() {
            saving = true;
            error = null;
          });
          try {
            await onSave();
            if (!dialogContext.mounted) return;
            Navigator.of(dialogContext).pop();
            messenger.showSnackBar(
              const SnackBar(
                content: Text(
                  'Saved. The website updates within about 5 minutes.',
                ),
              ),
            );
          } catch (e) {
            if (!dialogContext.mounted) return;
            setState(() {
              saving = false;
              error = _errorText(e);
            });
          }
        }

        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          title: Text(title),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...fields(setState),
                    if (!isNew)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('On sale'),
                        subtitle: const Text(
                          'Off retires it: hidden on the website and for '
                          'new units. Units already stored keep it.',
                        ),
                        value: isActive,
                        onChanged: (value) {
                          setState(() => isActive = value);
                          onActive(value);
                        },
                      ),
                    if (error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          'Not saved: $error',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.statusError),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: saving ? null : save,
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isNew ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    ),
  );
}

String? _required(String? value) =>
    (value ?? '').trim().isEmpty ? 'Required' : null;

String? _price(String? value) {
  final n = int.tryParse(value ?? '');
  if (n == null || n <= 0 || n > maxPriceZar) {
    return 'Whole Rand, 1 – $maxPriceZar';
  }
  return null;
}

Widget _textField(
  TextEditingController controller,
  String label, {
  String? Function(String?)? validator,
}) => Padding(
  padding: const EdgeInsets.only(bottom: AppSpacing.md),
  child: TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    validator: validator,
  ),
);

Widget _priceField(TextEditingController controller, String label) => Padding(
  padding: const EdgeInsets.only(bottom: AppSpacing.md),
  child: TextFormField(
    controller: controller,
    decoration: InputDecoration(labelText: label, prefixText: 'R '),
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: _price,
  ),
);

/// Every id in the live list, so a new entry's id stays unique across lists.
Set<String> _takenIds(WidgetRef ref) => ref.read(savedPriceIdsProvider);

class _BoxDialog {
  static Future<void> show(BuildContext context, WidgetRef ref, BoxPrice? box) {
    final label = TextEditingController(text: box?.label);
    final desc = TextEditingController(text: box?.description);
    final price = TextEditingController(text: box?.monthlyZar.toString());
    var active = box?.active ?? true;
    final edits = ref.read(pricingEditorProvider.notifier);
    return _showEditor(
      context,
      title: box == null ? 'New box size' : 'Edit box size',
      isNew: box == null,
      active: active,
      onActive: (v) => active = v,
      fields: (_) => [
        _textField(label, 'Name, e.g. Medium Box (80L)', validator: _required),
        _textField(desc, 'What fits, e.g. Clothing, kitchenware'),
        _priceField(price, 'Price per month'),
      ],
      onSave: () => edits.upsertBox(
        BoxPrice(
          id: box?.id ?? priceIdFor(label.text, _takenIds(ref)),
          label: label.text.trim(),
          description: desc.text.trim(),
          monthlyZar: int.parse(price.text),
          active: active,
        ),
      ),
    );
  }
}

class _LooseItemDialog {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    LooseItemPrice? item,
  ) {
    final catalog = ref.read(priceCatalogProvider);
    final categories = catalog.looseItemCategories
        .where((c) => c != 'All')
        .toList();
    final name = TextEditingController(text: item?.name);
    final price = TextEditingController(text: item?.monthlyZar.toString());
    var category =
        item?.category ??
        (categories.contains('Other') ? 'Other' : categories.first);
    var icon = item?.icon ?? 'inventory_2';
    var active = item?.active ?? true;
    final edits = ref.read(pricingEditorProvider.notifier);
    return _showEditor(
      context,
      title: item == null ? 'New loose item' : 'Edit loose item',
      isNew: item == null,
      active: active,
      onActive: (v) => active = v,
      fields: (setState) => [
        _textField(name, 'Name, e.g. Bunk Bed', validator: _required),
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: DropdownButtonFormField<String>(
            initialValue: category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final c in categories)
                DropdownMenuItem(value: c, child: Text(c)),
            ],
            onChanged: (v) => category = v ?? category,
          ),
        ),
        _priceField(price, 'Price per month'),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Icon', style: Theme.of(context).textTheme.labelMedium),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final symbol in catalog.itemIcons)
              ChoiceChip(
                label: Icon(iconForSymbol(symbol), size: 20),
                tooltip: symbol,
                selected: icon == symbol,
                showCheckmark: false,
                onSelected: (_) => setState(() => icon = symbol),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
      ],
      onSave: () => edits.upsertLooseItem(
        LooseItemPrice(
          id: item?.id ?? priceIdFor(name.text, _takenIds(ref)),
          name: name.text.trim(),
          category: category,
          icon: icon,
          monthlyZar: int.parse(price.text),
          active: active,
        ),
      ),
    );
  }
}

class _VehicleDialog {
  static Future<void> show(
    BuildContext context,
    WidgetRef ref,
    VehiclePrice? vehicle,
  ) {
    final label = TextEditingController(text: vehicle?.label);
    final desc = TextEditingController(text: vehicle?.description);
    final capacity = TextEditingController(
      text: vehicle == null ? '' : _trimZero(vehicle.capacityM3),
    );
    final price = TextEditingController(text: vehicle?.onceOffZar.toString());
    var recommended = vehicle?.recommended ?? false;
    var active = vehicle?.active ?? true;
    final edits = ref.read(pricingEditorProvider.notifier);
    return _showEditor(
      context,
      title: vehicle == null ? 'New pickup vehicle' : 'Edit pickup vehicle',
      isNew: vehicle == null,
      active: active,
      onActive: (v) => active = v,
      fields: (setState) => [
        _textField(label, 'Name, e.g. Medium Truck', validator: _required),
        _textField(desc, 'Short description, e.g. Up to 3 m³'),
        _textField(
          capacity,
          'Capacity (m³)',
          validator: (v) =>
              (double.tryParse(v ?? '') ?? 0) > 0 ? null : 'A number above 0',
        ),
        _priceField(price, 'Once-off pickup fee'),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Recommended'),
          subtitle: const Text('Highlighted on the website calculator.'),
          value: recommended,
          onChanged: (v) => setState(() => recommended = v),
        ),
      ],
      onSave: () => edits.upsertVehicle(
        VehiclePrice(
          id: vehicle?.id ?? priceIdFor(label.text, _takenIds(ref)),
          label: label.text.trim(),
          description: desc.text.trim(),
          capacityM3: double.parse(capacity.text),
          onceOffZar: int.parse(price.text),
          recommended: recommended,
          active: active,
        ),
      ),
    );
  }

  static String _trimZero(double n) =>
      n == n.roundToDouble() ? n.toInt().toString() : n.toString();
}

/// Flutter's twin of a Material Symbols name from [PriceCatalog.itemIcons].
/// The website renders the symbol itself; names Flutter lacks fall back.
IconData iconForSymbol(String symbol) => switch (symbol) {
  'table_restaurant' => Icons.table_restaurant,
  'table_bar' => Icons.table_bar,
  'desk' => Icons.desk,
  'tv' => Icons.tv,
  'chair' => Icons.chair,
  'chair_alt' => Icons.chair_alt,
  'shelves' => Icons.shelves,
  'single_bed' => Icons.single_bed,
  'bed' => Icons.bed,
  'king_bed' => Icons.king_bed,
  'crib' => Icons.crib,
  'weekend' => Icons.weekend,
  'pedal_bike' => Icons.pedal_bike,
  'electric_scooter' => Icons.electric_scooter,
  'moped' => Icons.moped,
  'surfing' => Icons.surfing,
  'kayaking' => Icons.kayaking,
  'sports_golf' => Icons.sports_golf,
  'sports_tennis' => Icons.sports_tennis,
  'fitness_center' => Icons.fitness_center,
  'kitchen' => Icons.kitchen,
  'microwave' => Icons.microwave,
  'local_laundry_service' => Icons.local_laundry_service,
  'piano' => Icons.piano,
  'stroller' => Icons.stroller,
  'luggage' => Icons.luggage,
  'checkroom' => Icons.checkroom,
  'wall_art' => Icons.image_outlined,
  'light' => Icons.light,
  'yard' => Icons.yard,
  _ => Icons.inventory_2_outlined,
};
