import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/contact_us_card.dart';
import '../../../core/widgets/step_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/quote_draft_provider.dart';

/// Ordered wizard steps and the route each one lives at. The calculator at
/// `/quote` sits outside the wizard, so it is not listed here.
const quoteSteps = <({String label, String path})>[
  (label: 'Boxes', path: '/quote/boxes'),
  (label: 'Loose Items', path: '/quote/items'),
  (label: 'Services', path: '/quote/services'),
  (label: 'Review', path: '/quote/summary'),
];

/// Chrome shared by every screen in the public quote flow: a marketing top
/// bar that works signed out, the step indicator, and a sticky footer
/// carrying the running total and the back/next actions.
///
/// The flow is deliberately reachable without an account — visitors only
/// hit the auth gate when they accept a quote.
class QuoteShell extends ConsumerWidget {
  const QuoteShell({
    super.key,
    required this.child,
    this.currentStep,
    this.onBack,
    this.nextLabel,
    this.onNext,
    this.nextEnabled = true,
    this.footerNote,
    this.footerAmountZar,
    this.footerSuffix = 'p/m',
    this.showFooterTotal = true,
    this.maxContentWidth = 1120,
  });

  final Widget child;

  /// Index into [quoteSteps]; null hides the indicator (calculator,
  /// confirmation).
  final int? currentStep;

  final VoidCallback? onBack;
  final String? nextLabel;
  final VoidCallback? onNext;
  final bool nextEnabled;

  /// Replaces the default "ESTIMATED MONTHLY TOTAL" caption above the
  /// figure — a step summary or a validation hint.
  final String? footerNote;

  /// Overrides the figure shown; defaults to the monthly storage total.
  final int? footerAmountZar;

  /// Unit shown after the figure, e.g. `p/m` or `inc. VAT`.
  final String footerSuffix;

  final bool showFooterTotal;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      return Scaffold(
        backgroundColor: AppColors.scaffold,
        body: Column(
          children: [
            _QuoteTopBar(desktop: desktop),
            if (currentStep != null)
              _QuoteStepBar(
                currentStep: currentStep!,
                desktop: desktop,
                maxContentWidth: maxContentWidth,
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: desktop ? AppSpacing.lg : AppSpacing.md,
                  vertical: desktop ? AppSpacing.lg : AppSpacing.md,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        child,
                        const SizedBox(height: AppSpacing.lg),
                        const ContactUsCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (onNext != null || onBack != null)
              _QuoteFooter(
                desktop: desktop,
                maxContentWidth: maxContentWidth,
                onBack: onBack,
                nextLabel: nextLabel,
                onNext: onNext,
                nextEnabled: nextEnabled,
                note: footerNote,
                amountZar: footerAmountZar,
                suffix: footerSuffix,
                showTotal: showFooterTotal,
              ),
          ],
        ),
      );
    });
  }
}

class _QuoteTopBar extends ConsumerWidget {
  const _QuoteTopBar({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final signedIn = ref.watch(currentUserProvider).valueOrNull != null;

    return Container(
      height: 68,
      padding: EdgeInsets.symmetric(
          horizontal: desktop ? AppSpacing.lg : AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Flexible(
            child: InkWell(
              onTap: () => context.go('/quote'),
              child: Text(
                'StrongBox',
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const Spacer(),
          if (desktop) ...[
            TextButton(
              onPressed: () => context.go('/quote'),
              child: const Text('Get a Quote'),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (signedIn)
            FilledButton(
              onPressed: () => context.go('/client/dashboard'),
              child: const Text('My Portal'),
            )
          // Below 900px there is only room for one action, so lead with
          // sign-in — registering is reachable from there and from the
          // quote's own accept button.
          else if (!desktop)
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Sign In'),
            )
          else ...[
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Sign In'),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(
              onPressed: () => context.go('/register'),
              child: const Text('Create Account'),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuoteStepBar extends StatelessWidget {
  const _QuoteStepBar({
    required this.currentStep,
    required this.desktop,
    required this.maxContentWidth,
  });

  final int currentStep;
  final bool desktop;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: desktop ? AppSpacing.lg : AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      color: AppColors.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth * 0.75),
          child: StepIndicator(
            steps: [for (final step in quoteSteps) step.label],
            currentStep: currentStep,
          ),
        ),
      ),
    );
  }
}

class _QuoteFooter extends ConsumerWidget {
  const _QuoteFooter({
    required this.desktop,
    required this.maxContentWidth,
    required this.onBack,
    required this.nextLabel,
    required this.onNext,
    required this.nextEnabled,
    required this.note,
    required this.amountZar,
    required this.suffix,
    required this.showTotal,
  });

  final bool desktop;
  final double maxContentWidth;
  final VoidCallback? onBack;
  final String? nextLabel;
  final VoidCallback? onNext;
  final bool nextEnabled;
  final String? note;
  final int? amountZar;
  final String suffix;
  final bool showTotal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final quote = ref.watch(quoteDraftProvider);

    final summary = Column(
      crossAxisAlignment:
          desktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          note ?? 'ESTIMATED MONTHLY TOTAL',
          textAlign: desktop ? TextAlign.start : TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium
              ?.copyWith(color: AppColors.textSecondary, letterSpacing: 0.6),
        ),
        if (showTotal)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  formatZarExact(amountZar ?? quote.monthlyTotalZar),
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(suffix,
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onBack != null)
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Back'),
          ),
        if (onBack != null && onNext != null)
          const SizedBox(width: AppSpacing.md),
        if (onNext != null)
          // Flexible so a long step label ("Next: Loose Items") ellipsises
          // on a phone instead of pushing the row past the screen edge.
          Flexible(
            child: FilledButton(
              onPressed: nextEnabled ? onNext : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(nextLabel ?? 'Next',
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: desktop ? AppSpacing.lg : AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadow.card,
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: desktop
                ? Row(
                    children: [
                      Flexible(child: summary),
                      const SizedBox(width: AppSpacing.md),
                      const Spacer(),
                      actions,
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      summary,
                      const SizedBox(height: AppSpacing.sm),
                      actions,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
