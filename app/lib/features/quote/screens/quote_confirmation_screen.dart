import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../core/models/quote.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../providers/quote_submission_provider.dart';
import '../utils/quote_pdf_generator.dart';
import '../widgets/quote_shell.dart';

/// Landing page after a quote is accepted — shows the reference the client
/// quotes back to support, and the figures that were locked in.
///
/// Design: `designs/client_designs/quote_confirmation`.
class QuoteConfirmationScreen extends ConsumerWidget {
  const QuoteConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accepted = ref.watch(quoteSubmissionProvider).valueOrNull;

    return QuoteShell(
      maxContentWidth: 640,
      child: accepted == null
          ? EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No recent quote',
              subtitle: 'Accepted quotes appear here right after checkout. '
                  'Open your portal to see everything on file.',
              action: FilledButton(
                onPressed: () => context.go('/client/dashboard'),
                child: const Text('View dashboard'),
              ),
            )
          : _AcceptedCard(quote: accepted),
    );
  }
}

class _AcceptedCard extends StatelessWidget {
  const _AcceptedCard({required this.quote});

  final Quote quote;

  Future<void> _downloadPdf() async {
    final bytes = await generateQuotePdf(quote);
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${quote.reference}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lg,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.statusSuccessBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  size: 40, color: AppColors.statusSuccess),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Quote Accepted',
              textAlign: TextAlign.center, style: textTheme.displaySmall),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: const BoxDecoration(
                color: AppColors.amber,
                borderRadius: AppRadius.pill,
              ),
              child: Text(
                'Reference: ${quote.reference}',
                style: textTheme.labelLarge
                    ?.copyWith(color: AppColors.amberDark),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "We'll contact you within 24 hours to confirm collection.",
            textAlign: TextAlign.center,
            style:
                textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _FigureStrip(quote: quote),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'View Dashboard',
            icon: null,
            onPressed: () => context.go('/client/dashboard'),
          ),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: 'Download Quote PDF',
            icon: Icons.download_outlined,
            onPressed: _downloadPdf,
          ),
        ],
      ),
    );
  }
}

class _FigureStrip extends StatelessWidget {
  const _FigureStrip({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final figures = [
      (label: 'MONTHLY', value: formatZar(quote.monthlyStorageZar)),
      (label: 'DUE TODAY', value: formatZar(quote.dueTodayZar)),
      (label: 'COLLECTION', value: 'To be scheduled'),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.md,
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth > 480;
        final cells = [
          for (final figure in figures)
            _Figure(label: figure.label, value: figure.value),
        ];

        if (!desktop) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cells.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                cells[i],
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < cells.length; i++) ...[
              if (i > 0)
                const VerticalDivider(width: AppSpacing.md, thickness: 1),
              Expanded(child: cells[i]),
            ],
          ],
        );
      }),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.labelMedium
              ?.copyWith(color: AppColors.textSecondary, letterSpacing: 0.6),
        ),
        Text(value,
            style:
                textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
