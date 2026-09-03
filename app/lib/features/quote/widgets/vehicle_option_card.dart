import 'package:flutter/material.dart';

import '../../../core/constants/quote_pricing.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';

/// The three collection vehicles as selectable cards, laid out side by side.
/// Used on the calculator, where space is tight.
class VehicleOptionGrid extends StatelessWidget {
  const VehicleOptionGrid({
    super.key,
    required this.selected,
    required this.recommended,
    required this.onSelected,
    this.wrap = false,
  });

  final VehicleSize selected;
  final VehicleSize recommended;
  final ValueChanged<VehicleSize> onSelected;

  /// Stacks the cards instead of sharing a row — used below 900px.
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final cards = [
      for (final tier in QuotePricing.vehicles)
        _VehicleCard(
          tier: tier,
          selected: tier.size == selected,
          recommended: tier.size == recommended,
          onTap: () => onSelected(tier.size),
        ),
    ];

    if (wrap) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            cards[i],
          ],
        ],
      );
    }

    // IntrinsicHeight so the cards match heights; a bare `stretch` would
    // ask for unbounded height inside the page's scroll view.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: cards[i]),
          ],
        ],
      ),
    );
  }
}

/// The same options as full-width rows with a leading radio, matching the
/// services step where the panel is taller than it is wide.
class VehicleOptionList extends StatelessWidget {
  const VehicleOptionList({
    super.key,
    required this.selected,
    required this.recommended,
    required this.onSelected,
  });

  final VehicleSize selected;
  final VehicleSize recommended;
  final ValueChanged<VehicleSize> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final tier in QuotePricing.vehicles)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _VehicleCard(
              tier: tier,
              selected: tier.size == selected,
              recommended: tier.size == recommended,
              horizontal: true,
              onTap: () => onSelected(tier.size),
            ),
          ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.tier,
    required this.selected,
    required this.recommended,
    required this.onTap,
    this.horizontal = false,
  });

  final VehicleTier tier;
  final bool selected;
  final bool recommended;
  final VoidCallback onTap;
  final bool horizontal;

  IconData get _icon => switch (tier.size) {
        VehicleSize.smallVan => Icons.airport_shuttle_outlined,
        VehicleSize.mediumVan => Icons.local_shipping_outlined,
        VehicleSize.largeTruck => Icons.fire_truck_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final body = horizontal
        ? Row(
            children: [
              _SelectionDot(selected: selected),
              const SizedBox(width: AppSpacing.md),
              Icon(_icon, size: 26, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tier.name, style: textTheme.titleMedium),
                    Text('Up to ${tier.capacityM3.toStringAsFixed(0)} m³',
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text(formatZar(tier.onceOffZar), style: textTheme.titleMedium),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_icon, size: 26, color: AppColors.textPrimary),
                  const Spacer(),
                  _SelectionDot(selected: selected),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(tier.name, style: textTheme.titleMedium),
              Text(formatZarOnceOff(tier.onceOffZar),
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
              Text('Capacity: ${tier.capacityM3.toStringAsFixed(0)} m³',
                  style: textTheme.bodySmall?.copyWith(
                    color: selected
                        ? AppColors.amberDark
                        : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  )),
            ],
          );

    final card = Material(
      color: selected ? AppColors.statusPastDueBg : AppColors.surface,
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.md,
            border: Border.all(
              color: selected ? AppColors.amberDark : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: body,
        ),
      ),
    );

    if (!recommended) return card;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          top: -8,
          right: AppSpacing.md,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 2),
            decoration: const BoxDecoration(
              color: AppColors.amber,
              borderRadius: AppRadius.sm,
            ),
            child: Text(
              'RECOMMENDED',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.amberDark,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.amberDark : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.amberDark : AppColors.border,
          width: 2,
        ),
      ),
    );
  }
}
