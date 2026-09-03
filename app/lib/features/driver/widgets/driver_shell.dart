import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/shift_providers.dart';

/// Bottom-nav destination.
class _Tab {
  const _Tab(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

/// Persistent driver layout: top bar + bottom NavigationBar. The Shift tab
/// only appears while a shift is open. Mobile-first; no sidebar.
class DriverShell extends ConsumerWidget {
  const DriverShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final hasShift = ref.watch(activeShiftProvider).valueOrNull != null;
    final user = ref.watch(currentUserProvider).valueOrNull;

    final tabs = <_Tab>[
      const _Tab('Jobs', Icons.receipt_long_outlined, '/driver/jobs'),
      const _Tab('Scan', Icons.qr_code_scanner, '/driver/scan'),
      if (hasShift)
        const _Tab('Shift', Icons.badge_outlined, '/driver/shift'),
      const _Tab('Account', Icons.person_outline, '/driver/account'),
    ];

    var selected = tabs.indexWhere((tab) =>
        location == tab.route || location.startsWith('${tab.route}/'));
    if (selected < 0) selected = 0;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Text(
          'StrongBox',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textSecondary),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Driver alerts arrive with FCM in Stage 7')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.go('/driver/account'),
              child: InitialsAvatar(name: user?.name, size: 36),
            ),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.amber,
        onDestinationSelected: (index) => context.go(tabs[index].route),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}
