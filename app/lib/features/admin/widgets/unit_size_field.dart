import 'package:flutter/material.dart';

import '../../../core/constants/pricing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency.dart';

/// Picks what a storage unit is on the shared price list — a box size or a
/// loose item — which sets its monthly rate. Boxes first, then loose items.
class UnitSizeField extends StatelessWidget {
  const UnitSizeField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// Selected price-list id, e.g. `medium` or `dining-table`.
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    DropdownMenuItem<String> option(String id, String label, int monthly) =>
        DropdownMenuItem(
          value: id,
          child: Row(
            children: [
              Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
              Text(formatZar(monthly),
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.accentDeep)),
              Text('/mo', style: textTheme.bodySmall),
            ],
          ),
        );

    DropdownMenuItem<String> heading(String label) => DropdownMenuItem(
          enabled: false,
          child: Text(label,
              style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary, letterSpacing: 0.8)),
        );

    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      hint: const Text('Select box size or item'),
      validator: (v) => v == null ? 'Choose a size — it sets the price' : null,
      items: [
        heading('BOXES'),
        for (final box in PriceList.boxes)
          option(box.id, box.label, box.monthlyZar),
        heading('LOOSE ITEMS'),
        for (final item in PriceList.looseItems)
          option(item.id, item.name, item.monthlyZar),
      ],
      onChanged: onChanged,
    );
  }
}
