import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// The two things a client orders: store more (book a pickup) or get items
/// back (request a delivery).
const _storeRoute = '/client/order';
const _returnRoute = '/client/requests/new';

/// "Get items back" + "Store more items" side by side — page headers.
class OrderActions extends StatelessWidget {
  const OrderActions({super.key, this.canReturn = true});

  /// False when nothing is in storage to send back.
  final bool canReturn;

  @override
  Widget build(BuildContext context) {
    const size = Size(0, 44);
    const padding = EdgeInsets.symmetric(horizontal: AppSpacing.md);
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(minimumSize: size, padding: padding),
          onPressed: canReturn ? () => context.go(_returnRoute) : null,
          icon: const Icon(Icons.local_shipping_outlined, size: 18),
          label: const Text('Get items back'),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(minimumSize: size, padding: padding),
          onPressed: () => context.go(_storeRoute),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Store more items'),
        ),
      ],
    );
  }
}

/// The shell's "New" button: a menu with both kinds of order. [compact]
/// shows just an icon (mobile app bar).
class NewOrderMenu extends StatelessWidget {
  const NewOrderMenu({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    Widget option(IconData icon, String title, String subtitle, String route) =>
        MenuItemButton(
          leadingIcon: Icon(icon, color: AppColors.accentDeep),
          onPressed: () => context.go(route),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: tt.titleSmall),
                Text(subtitle, style: tt.bodySmall),
              ],
            ),
          ),
        );

    return MenuAnchor(
      alignmentOffset: const Offset(0, AppSpacing.xs),
      menuChildren: [
        option(
          Icons.add_box_outlined,
          'Store more items',
          'Build a quote and book a pickup',
          _storeRoute,
        ),
        option(
          Icons.local_shipping_outlined,
          'Get items back',
          'Request a delivery from storage',
          _returnRoute,
        ),
      ],
      builder: (context, controller, _) {
        void toggle() =>
            controller.isOpen ? controller.close() : controller.open();
        if (compact) {
          return IconButton(
            tooltip: 'New order',
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.accentDeep,
            ),
            onPressed: toggle,
          );
        }
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          onPressed: toggle,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New order'),
        );
      },
    );
  }
}
