import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../providers/scan_link_providers.dart';

/// A label scanned with a phone's own camera (route `/s/:code`): sends the
/// user on to the unit or job, or says why it can't.
class ScanLinkScreen extends ConsumerWidget {
  const ScanLinkScreen({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(scanLinkTargetProvider(code));
    final tt = Theme.of(context).textTheme;
    final route = target.valueOrNull?.route;
    if (route != null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => context.mounted ? context.go(route) : null);
    }

    Widget home() => ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text('Go to my home'),
        );

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: target.when(
            loading: () => _opening(tt),
            error: (error, _) => EmptyState(
              icon: Icons.qr_code_2,
              title: code,
              subtitle: 'Could not open this label. Check your connection '
                  'and try again.',
              action: home(),
            ),
            data: (target) => target.route != null
                ? _opening(tt)
                : EmptyState(
                    icon: Icons.qr_code_2,
                    title: code,
                    subtitle: target.message,
                    action: home(),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _opening(TextTheme tt) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text('Opening $code…', style: tt.bodyMedium),
        ],
      );
}
