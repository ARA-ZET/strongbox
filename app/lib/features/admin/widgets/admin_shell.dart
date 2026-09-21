import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/initials_avatar.dart';
import '../../auth/providers/auth_provider.dart';
import 'quick_scan_drawer.dart';

/// Navigation entry shared between sidebar, bottom nav and the More drawer.
class _NavItem {
  const _NavItem(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

const _mainNav = [
  _NavItem('Dashboard', Icons.grid_view_outlined, '/admin/dashboard'),
  _NavItem('Inventory', Icons.inventory_2_outlined, '/admin/inventory'),
  _NavItem('Job Tracking', Icons.local_shipping_outlined, '/admin/jobs'),
  _NavItem('Fleet', Icons.directions_car_outlined, '/admin/fleet'),
  _NavItem('Clients', Icons.group_outlined, '/admin/clients'),
  _NavItem('Reports', Icons.bar_chart_outlined, '/admin/reports'),
];

const _secondaryNav = [
  _NavItem('QR Management', Icons.qr_code_2_outlined, '/admin/qr'),
  _NavItem('Notifications', Icons.notifications_outlined,
      '/admin/notifications'),
  _NavItem('Settings', Icons.settings_outlined, '/admin/settings'),
];

/// Persistent admin layout: navy sidebar + top bar on desktop (>900px),
/// bottom NavigationBar + More drawer on mobile.
class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String get _location => GoRouterState.of(context).matchedLocation;

  bool _isActive(String route) =>
      _location == route || _location.startsWith('$route/');

  void _openQuickScan() => _scaffoldKey.currentState?.openEndDrawer();

  Future<void> _logout() =>
      ref.read(authNotifierProvider.notifier).signOut();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final desktop = constraints.maxWidth > 900;
      return Scaffold(
        key: _scaffoldKey,
        endDrawer: const QuickScanDrawer(),
        drawer: desktop ? null : _MoreDrawer(onLogout: _logout),
        bottomNavigationBar: desktop ? null : _buildBottomNav(),
        body: desktop
            ? Row(
                children: [
                  _buildSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        _TopBar(onQuickScan: _openQuickScan),
                        Expanded(child: widget.child),
                      ],
                    ),
                  ),
                ],
              )
            : widget.child,
      );
    });
  }

  // ---------------------------------------------------------------- sidebar

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: AppColors.navyDeep,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.inventory_2,
                      color: AppColors.onAccent, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'StrongBox',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.sky,
                        ),
                      ),
                      Text(
                        'Logistics Control',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final item in _mainNav) _sidebarItem(item),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openQuickScan,
                    icon: const Icon(Icons.qr_code_scanner, size: 20),
                    label: const Text('Quick Scan'),
                  ),
                ),
                const SizedBox(height: 8),
                _sidebarItem(_secondaryNav[2]), // Settings
                _sidebarItem(
                  const _NavItem('Support', Icons.help_outline, ''),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Support: help@strongbox.example')),
                  ),
                ),
                _sidebarItem(
                  const _NavItem('Logout', Icons.logout, ''),
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(_NavItem item, {VoidCallback? onTap}) {
    final active = item.route.isNotEmpty && _isActive(item.route);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? AppColors.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap ?? () => context.go(item.route),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: active ? AppColors.onAccent : Colors.white70,
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: active ? AppColors.onAccent : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- bottom nav

  Widget _buildBottomNav() {
    final tabs = [..._mainNav.take(4)];
    var selected =
        tabs.indexWhere((item) => _isActive(item.route));
    // "More" tab hosts everything beyond the first four destinations.
    final moreActive = selected == -1;

    return NavigationBar(
      selectedIndex: moreActive ? 4 : selected,
      indicatorColor: AppColors.skyTint,
      backgroundColor: AppColors.surface,
      onDestinationSelected: (index) {
        if (index < 4) {
          context.go(tabs[index].route);
        } else {
          _scaffoldKey.currentState?.openDrawer();
        }
      },
      destinations: [
        for (final item in tabs)
          NavigationDestination(icon: Icon(item.icon), label: item.label),
        const NavigationDestination(
            icon: Icon(Icons.menu), label: 'More'),
      ],
    );
  }
}

/// Drawer with overflow destinations on mobile.
class _MoreDrawer extends StatelessWidget {
  const _MoreDrawer({required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final overflow = [_mainNav[4], _mainNav[5], ..._secondaryNav];

    return Drawer(
      backgroundColor: AppColors.navy,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (final item in overflow)
              ListTile(
                leading: Icon(item.icon, color: Colors.white70),
                title: Text(item.label,
                    style: GoogleFonts.inter(color: Colors.white70)),
                onTap: () {
                  Navigator.of(context).pop();
                  context.go(item.route);
                },
              ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: Text('Logout',
                  style: GoogleFonts.inter(color: Colors.white70)),
              onTap: onLogout,
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop top bar: title, global search, bell, gear, avatar.
class _TopBar extends ConsumerWidget {
  const _TopBar({required this.onQuickScan});

  final VoidCallback onQuickScan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text('StrongBox Logistics',
              style: textTheme.headlineSmall?.copyWith(fontSize: 20)),
          const Spacer(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search orders, boxes, or drivers...',
                prefixIcon: Icon(Icons.search,
                    color: AppColors.textSecondary, size: 20),
                isDense: true,
              ),
              onSubmitted: (query) => context
                  .go('/admin/jobs?q=${Uri.encodeQueryComponent(query)}'),
            ),
          ),
          const Spacer(),
          _BellButton(
              onPressed: () => context.go('/admin/notifications')),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textSecondary),
            onPressed: () => context.go('/admin/settings'),
          ),
          const SizedBox(width: 12),
          InitialsAvatar(name: user?.name, size: 40),
        ],
      ),
    );
  }
}

/// Notification bell with a red unread dot.
class _BellButton extends StatelessWidget {
  const _BellButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.textSecondary),
          onPressed: onPressed,
        ),
        Positioned(
          right: 10,
          top: 10,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.statusError,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
