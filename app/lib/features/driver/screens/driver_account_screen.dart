import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/driver_jobs_providers.dart';
import '../providers/shift_providers.dart';

/// Driver profile & account hub. Design: driver_profile_stats/screen.png.
class DriverAccountScreen extends ConsumerWidget {
  const DriverAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final jobsDone = ref.watch(driverJobsCompletedTodayProvider);
    final boxesHandled = ref.watch(driverBoxesHandledTodayProvider);
    final hasShift = ref.watch(activeShiftProvider).valueOrNull != null;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        // Gradient header.
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFDECD3), AppColors.scaffold],
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.amber, width: 3),
                ),
                child: InitialsAvatar(name: user?.name, size: 96),
              ),
              const SizedBox(height: 16),
              Text(user?.name ?? 'Driver', style: tt.headlineSmall),
              if (user?.phone?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(user!.phone!,
                    style: tt.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
        Text("TODAY'S PERFORMANCE",
            style: tt.bodySmall
                ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard('Jobs Completed', '$jobsDone',
                  badge: '+12%', badgeGood: true),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard('Boxes Handled', '$boxesHandled',
                  badge: 'Target', badgeGood: false),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [AppTheme.cardShadow],
          ),
          child: Column(
            children: [
              _settingRow(
                context,
                Icons.badge_outlined,
                hasShift ? 'Shift & E-ID' : 'Start a Shift',
                onTap: () => context.go('/driver/shift'),
              ),
              const Divider(height: 1),
              _settingRow(
                context,
                Icons.report_problem_outlined,
                'Report an Issue',
                onTap: () => context.go('/driver/report-issue'),
              ),
              const Divider(height: 1),
              _settingRow(
                context,
                Icons.qr_code_scanner,
                'Quick Scan',
                onTap: () => context.go('/driver/scan'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
            ),
            onPressed: () =>
                ref.read(authNotifierProvider.notifier).signOut(),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Log Out'),
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value,
      {required String badge, required bool badgeGood}) {
    return Builder(builder: (context) {
      final tt = Theme.of(context).textTheme;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  badgeGood
                      ? Icons.check_circle_outline
                      : Icons.inventory_2_outlined,
                  color: AppColors.amberDark,
                  size: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeGood
                        ? AppColors.statusSuccessBg
                        : AppColors.statusWarningBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(badge,
                      style: tt.bodySmall?.copyWith(
                        color: badgeGood
                            ? AppColors.statusSuccess
                            : AppColors.amberDark,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: tt.displaySmall),
            Text(label, style: tt.bodySmall),
          ],
        ),
      );
    });
  }

  Widget _settingRow(BuildContext context, IconData icon, String label,
      {required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(label, style: Theme.of(context).textTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    );
  }
}
