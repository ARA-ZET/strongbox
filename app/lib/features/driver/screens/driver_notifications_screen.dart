import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../notifications/widgets/notification_inbox.dart';
import '../../notifications/widgets/push_permission_banner.dart';

/// Driver alerts: job assignments, cancellations and messages from
/// dispatch (doc 22). Full-screen, opened from the shell's bell.
class DriverNotificationsScreen extends StatelessWidget {
  const DriverNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/driver/jobs'),
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(
              constraints.maxWidth > 900 ? AppSpacing.lg : AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PushPermissionBanner(),
                  NotificationInbox(),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
