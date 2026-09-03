import 'package:flutter/material.dart';

import '../../../core/constants/quote_pricing.dart';
import '../../../core/models/quote.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import 'volume_meter.dart';

/// Navy price panel that tracks the quote as it is built. Used as the
/// calculator's sidebar and again on the summary as the breakdown card.
class QuoteEstimatePanel extends StatelessWidget {
  const QuoteEstimatePanel({
    super.key,
    required this.quote,
    required this.title,
    this.actions = const [],
    this.footnote,
    this.showVolumeMeter = true,
    this.showLineItems = true,
  });

  final Quote quote;
  final String title;

  /// Buttons stacked under the totals.
  final List<Widget> actions;
  final String? footnote;
  final bool showVolumeMeter;

  /// Off on the summary, where the line items already have their own cards.
  final bool showLineItems;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final vehicle = QuotePricing.vehicleTier(quote.vehicle);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: AppRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.amber, width: 2),
                ),
              ),
              child: Text(
                title,
                style: textTheme.titleLarge
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (showLineItems) ...[
            if (quote.isEmpty)
              _PanelHint(
                text: 'Add a box or a loose item to see your price.',
              )
            else ...[
              for (final line in quote.activeBoxes)
                _PanelRow(
                  label:
                      '${line.quantity} × ${QuotePricing.boxTier(line.size).name}',
                  value: '${formatZar(line.monthlyZar)}/mo',
                ),
              for (final item in quote.looseItems)
                _PanelRow(
                  label: item.quantity > 1
                      ? '${item.quantity} × ${item.name}'
                      : item.name,
                  value: '${formatZar(item.lineMonthlyZar)}/mo',
                ),
            ],
            const Divider(color: Colors.white24, height: AppSpacing.lg),
          ],

          _PanelRow(
            label: '${vehicle.name} collection',
            value: '${formatZar(vehicle.onceOffZar)} once',
          ),
          if (quote.packingRequired)
            _PanelRow(
              label: 'Packing service',
              value: '${formatZar(quote.packingFeeZar)} once',
            ),

          const Divider(color: Colors.white24, height: AppSpacing.lg),

          _PanelTotal(
            label: 'Monthly Storage',
            value: formatZar(quote.monthlyTotalZar),
            emphasis: false,
          ),
          const SizedBox(height: AppSpacing.md),
          _PanelTotal(
            label: 'Due Today',
            value: formatZar(quote.dueTodayTotalZar),
            emphasis: true,
          ),
          if (quote.monthlyTotalZar > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: AppRadius.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Monthly from month 2',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70)),
                  ),
                  Text(formatZarExact(quote.monthlyTotalZar),
                      style: textTheme.bodyMedium
                          ?.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ],

          if (showVolumeMeter) ...[
            const SizedBox(height: AppSpacing.lg),
            VolumeMeter(
              title: 'Capacity utilisation',
              volumeM3: quote.volumeM3,
              capacityM3: vehicle.capacityM3,
              onDark: true,
              blockRows: 2,
            ),
            if (quote.vehicleUndersized) ...[
              const SizedBox(height: AppSpacing.sm),
              _PanelHint(
                text: 'This load exceeds the ${vehicle.name}. '
                    'Pick a larger vehicle or we will send a second trip.',
                warning: true,
              ),
            ],
          ],

          if (actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              actions[i],
            ],
          ],

          if (footnote != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              footnote!,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
          ],
        ],
      ),
    );
  }
}

class _PanelRow extends StatelessWidget {
  const _PanelRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ),
          Text(value,
              style: textTheme.bodyMedium?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

class _PanelTotal extends StatelessWidget {
  const _PanelTotal({
    required this.label,
    required this.value,
    required this.emphasis,
  });

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(label,
              style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
        ),
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            color: emphasis ? AppColors.amber : Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PanelHint extends StatelessWidget {
  const _PanelHint({required this.text, this.warning = false});

  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: warning
            ? AppColors.amber.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.warning_amber_rounded : Icons.info_outline,
            size: 16,
            color: warning ? AppColors.amber : Colors.white70,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                color: warning ? AppColors.amber : Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
