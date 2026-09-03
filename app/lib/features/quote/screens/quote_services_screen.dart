import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/quote_pricing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/quote_draft_provider.dart';
import '../widgets/packing_options.dart';
import '../widgets/quote_shell.dart';
import '../widgets/vehicle_option_card.dart';

/// Step 3 — packing assistance and the collection vehicle.
///
/// Design: `designs/client_designs/quote_packing_pickup`.
class QuoteServicesScreen extends ConsumerWidget {
  const QuoteServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(quoteDraftProvider);
    final draft = ref.read(quoteDraftProvider.notifier);

    return QuoteShell(
      currentStep: 2,
      onBack: () => context.go('/quote/items'),
      nextLabel: 'Next: Review',
      onNext: () => context.go('/quote/summary'),
      footerNote: 'ESTIMATED TOTAL',
      footerAmountZar: quote.dueTodayTotalZar,
      footerSuffix: 'inc. VAT',
      child: LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;

        final packing = _ServiceCard(
          icon: Icons.inventory_outlined,
          title: 'Packing Service',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PackingChoice(
                packingRequired: quote.packingRequired,
                onChanged: draft.setPackingRequired,
              ),
              if (quote.packingRequired) ...[
                const SizedBox(height: AppSpacing.sm),
                PackingCrewPicker(desktop: desktop),
              ],
              const SizedBox(height: AppSpacing.md),
              const _InfoNote(
                text: 'Packers arrive with boxes, tape and wrapping '
                    'material. Billed once-off on the collection day.',
              ),
            ],
          ),
        );

        final vehicleCard = _ServiceCard(
          icon: Icons.local_shipping_outlined,
          title: 'Pickup Vehicle',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VehicleOptionList(
                selected: quote.vehicle,
                recommended: quote.recommendedVehicle,
                onSelected: draft.setVehicle,
              ),
              const SizedBox(height: AppSpacing.sm),
              _InfoNote(
                text: quote.vehicleUndersized
                    ? 'Your ${quote.volumeM3.toStringAsFixed(1)} m³ load is '
                        'bigger than this vehicle. Choose a larger one, or we '
                        'will quote a second trip after the site check.'
                    : 'All vehicles include basic insurance cover up to '
                        'R${QuotePricing.includedInsuranceZar} for items in '
                        'transit. Our drivers assist with loading.',
                warning: quote.vehicleUndersized,
              ),
            ],
          ),
        );

        if (!desktop) {
          return Column(
            children: [
              packing,
              const SizedBox(height: AppSpacing.md),
              vehicleCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: packing),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: vehicleCard),
          ],
        );
      }),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textPrimary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(title,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineSmall),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text, this.warning = false});

  final String text;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final colour = warning ? AppColors.statusPastDue : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: warning
            ? AppColors.statusPastDueBg
            : AppColors.surfaceContainer,
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            warning ? Icons.warning_amber_rounded : Icons.info_outline,
            size: 18,
            color: colour,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colour),
            ),
          ),
        ],
      ),
    );
  }
}
