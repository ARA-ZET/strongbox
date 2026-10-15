import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/push_repository.dart';
import '../../../repositories/repository_providers.dart';
import '../../../routing/app_router.dart';
import '../providers/notification_providers.dart';

/// Sits above every screen (MaterialApp.builder): keeps push registration
/// alive, shows pushes that arrive while the app is open as a snackbar, and
/// opens the route of a push the user tapped.
class PushListener extends ConsumerStatefulWidget {
  const PushListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushListener> createState() => _PushListenerState();
}

class _PushListenerState extends ConsumerState<PushListener> {
  final _subscriptions = <StreamSubscription<PushMessage>>[];

  @override
  void initState() {
    super.initState();
    final push = ref.read(pushRepositoryProvider);
    _subscriptions
      ..add(push.onForegroundMessage.listen(_show))
      ..add(push.onMessageOpened.listen(_open));
    push.initialMessage().then((message) {
      if (message != null) _open(message);
    });
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void _open(PushMessage message) {
    final route = message.route;
    if (!mounted || route == null || !route.startsWith('/')) return;
    ref.read(appRouterProvider).go(route);
  }

  void _show(PushMessage message) {
    if (!mounted || message.title.isEmpty) return;
    final tt = Theme.of(context).textTheme;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.title,
                style: tt.bodyMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            if (message.body.isNotEmpty)
              Text(message.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodySmall?.copyWith(color: Colors.white70)),
          ],
        ),
        action: message.route == null
            ? null
            : SnackBarAction(label: 'View', onPressed: () => _open(message)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Registers this device's token while someone is signed in.
    ref.watch(pushNotificationsProvider);
    return widget.child;
  }
}
