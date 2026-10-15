import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/widgets/push_listener.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    // Placeholder firebase_options.dart — UI still runs, backend calls fail.
    // Run `flutterfire configure` to connect a real Firebase project.
    debugPrint('Firebase initialization failed: $error');
  }

  runApp(const ProviderScope(child: StrongBoxApp()));
}

class StrongBoxApp extends ConsumerWidget {
  const StrongBoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'StrongBox Logistics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      builder: (context, child) =>
          PushListener(child: child ?? const SizedBox.shrink()),
    );
  }
}
