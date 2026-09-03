import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/quote_pricing.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/models/quote.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadow.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/quote_draft_provider.dart';
import '../providers/quote_submission_provider.dart';
import '../widgets/quote_estimate_panel.dart';
import '../widgets/quote_shell.dart';
import '../widgets/volume_meter.dart';

/// Step 4 — review and accept.
///
/// This is the only place the flow needs an account: browsing and pricing
/// are open to anyone, but accepting writes a quote and opens a pickup job,
/// so an unauthenticated visitor is sent to register and returned here to
/// finish automatically.
///
/// Design: `designs/client_designs/quote_summary`.
class QuoteSummaryScreen extends ConsumerStatefulWidget {
  const QuoteSummaryScreen({super.key});

  @override
  ConsumerState<QuoteSummaryScreen> createState() => _QuoteSummaryScreenState();
}

class _QuoteSummaryScreenState extends ConsumerState<QuoteSummaryScreen> {
  /// Guards against the auto-accept firing twice while `users/{uid}` and
  /// its `clientId` land in two separate emissions.
  bool _accepting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _acceptIfReturningFromAuth());
  }

  /// True once the signed-in user is a client with a provisioned record —
  /// anything less and accepting would fail in the repository.
  bool get _canAccept {
    final user = ref.read(currentUserProvider).valueOrNull;
    return user != null &&
        user.role == UserRole.client &&
        (user.clientId ?? '').isNotEmpty;
  }

  /// Completes the acceptance the visitor started before registering.
  void _acceptIfReturningFromAuth() {
    if (_accepting) return;
    if (ref.read(quoteReturnPathProvider) == null) return;
    if (!_canAccept) return;
    ref.read(quoteReturnPathProvider.notifier).clear();
    _accept();
  }

  Future<void> _accept() async {
    if (_accepting) return;
    setState(() => _accepting = true);

    final accepted = await ref.read(quoteSubmissionProvider.notifier).accept();
    if (!mounted) return;

    if (accepted != null) {
      context.go('/quote/confirmation');
      return;
    }

    setState(() => _accepting = false);
    final error = ref.read(quoteSubmissionProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error is AppException
              ? error.message
              : 'Could not accept the quote. Please try again.'),
        ),
      );
    }
  }

  /// The auth gate: signed-in clients accept straight away, everyone else
  /// registers first and is brought back here.
  void _onAcceptPressed() {
    if (_canAccept) {
      _accept();
      return;
    }
    ref.read(quoteReturnPathProvider.notifier).arm('/quote/summary');
    context.go('/register');
  }

  void _saveForLater() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Quote saved on this device — reopen /quote to pick up where '
            'you left off.'),
      ),
    );
  }

  Future<void> _shareOnWhatsApp(Quote quote) async {
    final lines = <String>[
      'My StrongBox storage quote:',
      for (final line in quote.activeBoxes)
        '${line.quantity} × ${QuotePricing.boxTier(line.size).name} '
            '— ${formatZar(line.monthlyZar)}/mo',
      for (final item in quote.looseItems)
        '${item.quantity} × ${item.name} '
            '— ${formatZar(item.lineMonthlyZar)}/mo',
      'Monthly: ${formatZar(quote.monthlyTotalZar)}',
      'Due today: ${formatZar(quote.dueTodayTotalZar)}',
    ];
    final uri = Uri.https(
        'wa.me', '/', {'text': lines.join('\n')});

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final quote = ref.watch(quoteDraftProvider);

    // The clientId can arrive a beat after the user doc — retry then.
    ref.listen(currentUserProvider, (_, _) => _acceptIfReturningFromAuth());

    if (quote.isEmpty) {
      return QuoteShell(
        currentStep: 3,
        onBack: () => context.go('/quote/services'),
        child: EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'Nothing to quote yet',
          subtitle: 'Add a box or a loose item and your price appears here.',
          action: FilledButton(
            onPressed: () => context.go('/quote'),
            child: const Text('Start a quote'),
          ),
        ),
      );
    }

    final signedIn = _canAccept;

    return QuoteShell(
      currentStep: 3,
      onBack: () => context.go('/quote/services'),
      footerNote: 'DUE TODAY',
      footerAmountZar: quote.dueTodayTotalZar,
      footerSuffix: 'inc. VAT',
      child: LayoutBuilder(builder: (context, constraints) {
        final desktop = constraints.maxWidth > 900;

        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SummaryCard(
              icon: Icons.inventory_2_outlined,
              title: 'Storage',
              rows: [
                for (final line in quote.activeBoxes)
                  (
                    label: '${line.quantity} × '
                        '${QuotePricing.boxTier(line.size).name}',
                    value: formatZarExact(line.monthlyZar),
                    badge: null,
                  ),
                for (final item in quote.looseItems)
                  (
                    label: item.quantity > 1
                        ? '${item.quantity} × ${item.name}'
                        : item.name,
                    value: formatZarExact(item.lineMonthlyZar),
                    badge: null,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _SummaryCard(
              icon: Icons.local_shipping_outlined,
              title: 'Services',
              rows: [
                (
                  label: '${QuotePricing.vehicleTier(quote.vehicle).name} '
                      'collection',
                  value: formatZarExact(quote.collectionFeeZar),
                  badge: 'Once-off',
                ),
                if (quote.packingRequired)
                  (
                    label: 'Packing assistance '
                        '(${quote.packers} persons × ${quote.packingHours}hrs)',
                    value: formatZarExact(quote.packingFeeZar),
                    badge: 'Once-off',
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            VolumeMeter(
              title: 'Estimated volume',
              volumeM3: quote.volumeM3,
              capacityM3: QuotePricing.vehicleTier(quote.vehicle).capacityM3,
              caption: QuotePricing.volumeComparison(quote.volumeM3),
            ),
            const SizedBox(height: AppSpacing.md),
            _Assurances(desktop: desktop),
          ],
        );

        final panel = QuoteEstimatePanel(
          quote: quote,
          title: 'Quote Breakdown',
          showLineItems: false,
          showVolumeMeter: false,
          footnote: '* One free retrieval every '
              '${QuotePricing.freeRetrievalEveryMonths} months included.',
          actions: [
            PrimaryButton(
              label: signedIn ? 'Accept Quote' : 'Accept Quote & Sign Up',
              icon: null,
              loading: _accepting,
              onPressed: _onAcceptPressed,
            ),
            OutlinedButton(
              onPressed: _saveForLater,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              child: const Text('Save Quote'),
            ),
            TextButton.icon(
              onPressed: () => _shareOnWhatsApp(quote),
              icon: const Icon(Icons.chat_outlined, color: Colors.white70),
              label: const Text('Share via WhatsApp',
                  style: TextStyle(color: Colors.white70)),
            ),
            if (!signedIn)
              Text(
                'You can browse and price freely — an account is only needed '
                'to place the order.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
          ],
        );

        final header = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quote Summary', style: textTheme.displaySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Review your storage requirements and logistics plan before '
              'finalising.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        );

        if (!desktop) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              details,
              const SizedBox(height: AppSpacing.md),
              panel,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: details),
                const SizedBox(width: AppSpacing.lg),
                Expanded(flex: 2, child: panel),
              ],
            ),
          ],
        );
      }),
    );
  }
}

typedef _SummaryRow = ({String label, String value, String? badge});

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.rows,
  });

  final IconData icon;
  final String title;
  final List<_SummaryRow> rows;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        boxShadow: AppShadow.card,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.textPrimary),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: textTheme.titleLarge),
              ],
            ),
          ),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                      child: Text(rows[i].label, style: textTheme.bodyLarge)),
                  if (rows[i].badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 2),
                      decoration: const BoxDecoration(
                        color: AppColors.statusPendingBg,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(rows[i].badge!,
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Text(rows[i].value,
                      style: textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Assurances extends StatelessWidget {
  const _Assurances({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        icon: Icons.shield_outlined,
        title: 'Fully insured',
        body: 'Cover up to ${formatZar(QuotePricing.includedInsuranceZar)} '
            'included for all items stored.',
      ),
      (
        icon: Icons.schedule_outlined,
        title: 'Flexible access',
        body: 'Request returns 24/7 via the portal, with 48-hour delivery.',
      ),
      (
        icon: Icons.verified_outlined,
        title: 'Price lock',
        body: 'Your monthly rate is guaranteed for the first 12 months.',
      ),
    ];

    final widgets = [
      for (final card in cards)
        _AssuranceCard(icon: card.icon, title: card.title, body: card.body),
    ];

    if (!desktop) {
      return Column(
        children: [
          for (var i = 0; i < widgets.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            widgets[i],
          ],
        ],
      );
    }

    // IntrinsicHeight so the three cards align; a bare `stretch` would ask
    // for unbounded height inside the page's scroll view.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < widgets.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: widgets[i]),
          ],
        ],
      ),
    );
  }
}

class _AssuranceCard extends StatelessWidget {
  const _AssuranceCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textPrimary),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(body,
              style: textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
