import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../auth/providers/auth_provider.dart';

class _Tab {
  const _Tab(this.label, this.icon, this.route);
  final String label;
  final IconData icon;
  final String route;
}

const _tabs = [
  _Tab('Home', Icons.home_outlined, '/client/dashboard'),
  _Tab('My Storage', Icons.inventory_2_outlined, '/client/storage'),
  _Tab('Deliveries', Icons.local_shipping_outlined, '/client/deliveries'),
  _Tab('Billing', Icons.receipt_long_outlined, '/client/subscription'),
];

/// Persistent client layout (doc 15). Desktop: white top bar with logo,
/// nav links, bell and avatar. Mobile: bottom NavigationBar + slim top bar.
class ClientShell extends ConsumerWidget {
  const ClientShell({super.key, required this.child});

  final Widget child;

  bool _isActive(String location, String route) =>
      location == route || location.startsWith('$route/');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final user = ref.watch(currentUserProvider).valueOrNull;

    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;

      final logo = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.amber,
              borderRadius: AppRadius.sm,
            ),
            child: const Icon(Icons.inventory_2,
                color: AppColors.navy, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'StrongBox',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );

      final bell = IconButton(
        tooltip: 'Notification preferences',
        icon: const Icon(Icons.notifications_outlined,
            color: AppColors.textSecondary),
        onPressed: () => context.go('/client/notifications'),
      );
      final avatar = InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.go('/client/account'),
        child: InitialsAvatar(name: user?.name, size: 36),
      );

      if (desktop) {
        return Scaffold(
          backgroundColor: AppColors.scaffold,
          body: Column(
            children: [
              Container(
                height: 64,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border:
                      Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    logo,
                    const SizedBox(width: AppSpacing.xl),
                    for (final tab in _tabs)
                      _NavLink(
                        label: tab.label,
                        active: _isActive(location, tab.route),
                        onTap: () => context.go(tab.route),
                      ),
                    const Spacer(),
                    bell,
                    const SizedBox(width: AppSpacing.sm),
                    avatar,
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        );
      }

      var selected =
          _tabs.indexWhere((tab) => _isActive(location, tab.route));
      final onAccount = _isActive(location, '/client/account') ||
          _isActive(location, '/client/notifications');
      if (selected < 0) selected = 0;

      return Scaffold(
        backgroundColor: AppColors.scaffold,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: AppSpacing.md,
          title: logo,
          actions: [bell, const SizedBox(width: AppSpacing.sm)],
        ),
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: onAccount ? 4 : selected,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.amber,
          onDestinationSelected: (index) => index < 4
              ? context.go(_tabs[index].route)
              : context.go('/client/account'),
          destinations: [
            for (final tab in _tabs)
              NavigationDestination(icon: Icon(tab.icon), label: tab.label),
            const NavigationDestination(
                icon: Icon(Icons.person_outline), label: 'Account'),
          ],
        ),
      );
    });
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.sm,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.amberDark : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
