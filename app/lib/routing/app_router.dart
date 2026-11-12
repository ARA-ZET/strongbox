import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ConsumerWidget, Ref, WidgetRef;
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/enums/app_enums.dart';
import '../core/errors/app_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/primary_button.dart';
import '../features/admin/screens/admin_box_detail_screen.dart';
import '../features/admin/screens/admin_client_detail_screen.dart';
import '../features/admin/screens/admin_clients_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/admin_driver_detail_screen.dart';
import '../features/admin/screens/admin_fleet_screen.dart';
import '../features/admin/screens/admin_inventory_screen.dart';
import '../features/admin/screens/admin_jobs_screen.dart';
import '../features/admin/screens/admin_new_job_screen.dart';
import '../features/admin/screens/admin_issues_screen.dart';
import '../features/admin/screens/admin_notifications_screen.dart';
import '../features/admin/screens/admin_pricing_screen.dart';
import '../features/admin/screens/admin_settings_screen.dart';
import '../features/admin/screens/admin_qr_screen.dart';
import '../features/admin/screens/admin_reports_screen.dart';
import '../features/driver/screens/driver_account_screen.dart';
import '../features/driver/screens/driver_job_detail_screen.dart';
import '../features/driver/screens/driver_jobs_screen.dart';
import '../features/driver/screens/driver_notifications_screen.dart';
import '../features/driver/screens/driver_photo_capture_screen.dart';
import '../features/driver/screens/driver_report_issue_screen.dart';
import '../features/driver/screens/driver_scanner_screen.dart';
import '../features/driver/screens/driver_shift_screen.dart';
import '../features/driver/screens/driver_signoff_screen.dart';
import '../features/driver/widgets/driver_shell.dart';
import '../features/admin/widgets/admin_shell.dart';
import '../features/client/screens/client_account_screen.dart';
import '../features/client/screens/client_dashboard_screen.dart';
import '../features/client/screens/client_order_detail_screen.dart';
import '../features/client/screens/client_orders_screen.dart';
import '../features/client/screens/client_delivery_request_screen.dart';
import '../features/client/screens/client_notifications_screen.dart';
import '../features/client/screens/client_storage_screen.dart';
import '../features/client/screens/client_subscription_screen.dart';
import '../features/client/screens/client_unit_detail_screen.dart';
import '../features/client/widgets/client_shell.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/quote/providers/quote_providers.dart';
import '../features/quote/screens/book_pickup_screen.dart';
import '../features/quote/screens/prices_screen.dart';
import '../features/quote/screens/quote_screen.dart';
import '../core/models/quote.dart';
import '../core/utils/qr_link.dart';
import '../features/scan/screens/scan_link_screen.dart';

part 'app_router.g.dart';

/// App router. Redirect rules:
/// - Signed-out visitors land on /login, which links out to the website
///   for anyone exploring. /quote and /prices stay open to everyone for
///   links that point at them. Signed-in clients build and book inside
///   their portal instead (/client/order, /client/order/book).
/// - A quote in the URL (the website's `?boxes=…&loose=…&vehicle=…`) is
///   loaded into the quote on any route; on /register or /login it also
///   opens booking once they're signed in.
/// - /book needs a client account — signed-out visitors sign up first;
///   clients are sent on to /client/order/book.
/// - Other routes need sign-in → /login; signed-in users go to their role
///   home (/admin/dashboard, /driver/jobs, /client/dashboard), or booking
///   when it was started before signing in. Portals are role-guarded.
/// - A label link (/s/:code, from a phone's own camera) is open to every
///   signed-in role; anyone else signs in first and lands on it after.
/// - Role means [currentUserProvider]'s, so an admin using "View as" is
///   routed exactly like the account they're viewing.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Re-run redirects whenever auth state or the user doc changes.
  final refresh = ValueNotifier(0);
  ref
    ..onDispose(refresh.dispose)
    ..listen(authStateProvider, (previous, next) => refresh.value++)
    ..listen(currentUserProvider, (previous, next) => refresh.value++)
    // A closed account's login is deleted, but its session can outlive
    // that by up to an hour — end it once its profile reads as closed.
    ..listen(signedInUserProvider, (previous, next) {
      if (next.valueOrNull?.isDeleted ?? false) {
        ref.read(authNotifierProvider.notifier).signOut();
      }
    })
    // A saved "book after sign-in" can load after the first redirect.
    ..listen(
      quoteControllerProvider.select((q) => q.bookAfterSignIn),
      (previous, next) => refresh.value++,
    );

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final authUser = authState.valueOrNull;
      final appUser = ref.read(currentUserProvider).valueOrNull;
      final location = state.matchedLocation;
      final onAuthPage = location == '/login' || location == '/register';
      final quote = ref.read(quoteControllerProvider.notifier);
      // A label link waits through the splash and sign-in, then opens.
      final onLabelLink = location.startsWith('/s/');
      final pendingLink = ref.read(pendingLabelLinkProvider.notifier);

      // A quote handed over in a link — before the loading hold below,
      // which would drop the query. Load it, then continue without it.
      final params = state.uri.queryParameters;
      if (QuoteDraft.inQuery(params)) {
        quote.importQuery(params, book: onAuthPage);
        return location;
      }

      // Open to everyone, signed in or not — clients get the quote builder
      // inside their portal.
      if (location == '/prices') return null;
      if (location == '/quote') {
        return (appUser?.isClient ?? false) ? '/client/order' : null;
      }

      // Firebase restores a session asynchronously. Hold at the splash
      // instead of flashing the sign-in form at a returning user.
      if (authState.isLoading) {
        if (location == '/book') quote.requestBooking();
        if (onLabelLink) pendingLink.set(location);
        return location == '/' ? null : '/';
      }

      if (authUser == null) {
        if (onLabelLink) {
          pendingLink.set(location);
          return '/login';
        }
        if (location == '/book') {
          quote.requestBooking();
          return '/register';
        }
        return onAuthPage ? null : '/login';
      }

      // Signed in but the users/{uid} doc hasn't loaded yet — hold at splash.
      if (appUser == null) {
        if (onLabelLink) pendingLink.set(location);
        return location == '/' ? null : '/';
      }

      final home = switch (appUser.role) {
        UserRole.admin => '/admin/dashboard',
        UserRole.driver => '/driver/jobs',
        UserRole.client => '/client/dashboard',
      };

      if (location == '/book') {
        return appUser.isClient ? '/client/order/book' : home;
      }

      if (onAuthPage || location == '/') {
        final pending = ref.read(quoteControllerProvider);
        if (appUser.isClient &&
            pending.bookAfterSignIn &&
            !pending.draft.isEmpty) {
          return '/client/order/book';
        }
        return pendingLink.take() ?? home;
      }

      if (onLabelLink) return null; // every role; the screen checks access

      // Role guards — bounce anyone visiting another portal to their own.
      if (location.startsWith('/admin') && !appUser.isAdmin) return home;
      if (location.startsWith('/driver') && !appUser.isDriver) return home;
      if (location.startsWith('/client') && !appUser.isClient) return home;

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Open to everyone: quote builder and price list.
      GoRoute(path: '/quote', builder: (context, state) => const QuoteScreen()),
      GoRoute(
        path: '/prices',
        builder: (context, state) => const PricesScreen(),
      ),
      // Clients only (signed-out visitors sign up first) — the redirect
      // above sends clients on to /client/order/book.
      GoRoute(
        path: '/book',
        redirect: (context, state) => '/client/order/book',
      ),
      // A label scanned with a phone's own camera.
      GoRoute(
        path: '/s/:code',
        builder: (context, state) =>
            ScanLinkScreen(code: codeFromScan(state.pathParameters['code']!)),
      ),

      // Admin portal — all screens share the AdminShell layout.
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/inventory',
            builder: (context, state) => const AdminInventoryScreen(),
          ),
          GoRoute(
            path: '/admin/inventory/:boxId',
            builder: (context, state) =>
                AdminBoxDetailScreen(boxId: state.pathParameters['boxId']!),
          ),
          GoRoute(
            path: '/admin/qr',
            builder: (context, state) => AdminQrScreen(
              initialTab: state.uri.queryParameters['tab'] == 'link' ? 1 : 0,
            ),
          ),
          GoRoute(
            path: '/admin/jobs',
            builder: (context, state) => AdminJobsScreen(
              initialQuery: state.uri.queryParameters['q'] ?? '',
            ),
          ),
          GoRoute(
            path: '/admin/jobs/new',
            builder: (context, state) => const AdminNewJobScreen(),
          ),
          GoRoute(
            path: '/admin/clients',
            builder: (context, state) => const AdminClientsScreen(),
          ),
          GoRoute(
            path: '/admin/clients/:clientId',
            builder: (context, state) => AdminClientDetailScreen(
              clientId: state.pathParameters['clientId']!,
            ),
          ),
          GoRoute(
            path: '/admin/fleet',
            builder: (context, state) => const AdminFleetScreen(),
          ),
          GoRoute(
            path: '/admin/fleet/:driverId',
            builder: (context, state) => AdminDriverDetailScreen(
              driverId: state.pathParameters['driverId']!,
            ),
          ),
          GoRoute(
            path: '/admin/reports',
            builder: (context, state) => const AdminReportsScreen(),
          ),
          GoRoute(
            path: '/admin/notifications',
            builder: (context, state) => const AdminNotificationsScreen(),
          ),
          GoRoute(
            path: '/admin/issues',
            builder: (context, state) => const AdminIssuesScreen(),
          ),
          GoRoute(
            path: '/admin/pricing',
            builder: (context, state) => const AdminPricingScreen(),
          ),
          GoRoute(
            path: '/admin/settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),

      // Driver portal — tab screens share DriverShell (top bar + bottom nav).
      ShellRoute(
        builder: (context, state, child) => DriverShell(child: child),
        routes: [
          GoRoute(
            path: '/driver/jobs',
            builder: (context, state) => const DriverJobsScreen(),
          ),
          GoRoute(
            path: '/driver/shift',
            builder: (context, state) => const DriverShiftScreen(),
          ),
          GoRoute(
            path: '/driver/account',
            builder: (context, state) => const DriverAccountScreen(),
          ),
        ],
      ),
      // Full-screen driver flows (own app bars, no bottom nav).
      GoRoute(
        path: '/driver/jobs/:jobId',
        builder: (context, state) =>
            DriverJobDetailScreen(jobId: state.pathParameters['jobId']!),
      ),
      GoRoute(
        path: '/driver/scan',
        builder: (context, state) =>
            DriverScannerScreen(jobId: state.uri.queryParameters['jobId']),
      ),
      GoRoute(
        path: '/driver/capture',
        builder: (context, state) => DriverPhotoCaptureScreen(
          jobId: state.uri.queryParameters['jobId']!,
          boxId: state.uri.queryParameters['boxId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/driver/signoff/:jobId',
        builder: (context, state) =>
            DriverSignOffScreen(jobId: state.pathParameters['jobId']!),
      ),
      GoRoute(
        path: '/driver/report-issue',
        builder: (context, state) => DriverReportIssueScreen(
            jobId: state.uri.queryParameters['jobId']),
      ),
      GoRoute(
        path: '/driver/notifications',
        builder: (context, state) => const DriverNotificationsScreen(),
      ),

      // Client portal — all screens share the ClientShell layout.
      ShellRoute(
        builder: (context, state, child) => ClientShell(child: child),
        routes: [
          GoRoute(
            path: '/client/dashboard',
            builder: (context, state) => const ClientDashboardScreen(),
          ),
          GoRoute(
            path: '/client/order',
            builder: (context, state) => const QuoteScreen(inPortal: true),
          ),
          GoRoute(
            path: '/client/order/book',
            builder: (context, state) => const BookPickupScreen(),
          ),
          GoRoute(
            path: '/client/storage',
            builder: (context, state) => ClientStorageScreen(
                status: state.uri.queryParameters['status'] ?? 'all'),
          ),
          GoRoute(
            path: '/client/storage/:unitId',
            builder: (context, state) =>
                ClientUnitDetailScreen(unitId: state.pathParameters['unitId']!),
          ),
          GoRoute(
            path: '/client/orders',
            builder: (context, state) => ClientOrdersScreen(
                past: state.uri.queryParameters['view'] == 'past'),
          ),
          GoRoute(
            path: '/client/orders/:jobId',
            builder: (context, state) =>
                ClientOrderDetailScreen(jobId: state.pathParameters['jobId']!),
          ),
          // Old name for Orders (links in emails / notifications sent
          // before the rename).
          GoRoute(
            path: '/client/deliveries',
            redirect: (context, state) => '/client/orders',
          ),
          GoRoute(
            path: '/client/requests/new',
            builder: (context, state) => const ClientDeliveryRequestScreen(),
          ),
          GoRoute(
            path: '/client/subscription',
            builder: (context, state) => const ClientSubscriptionScreen(),
          ),
          GoRoute(
            path: '/client/account',
            builder: (context, state) => const ClientAccountScreen(),
          ),
          GoRoute(
            path: '/client/notifications',
            builder: (context, state) => const ClientNotificationsScreen(),
          ),
        ],
      ),
    ],
  );
}

/// A label link (/s/:code) opened before sign-in finished, to open after.
@Riverpod(keepAlive: true)
class PendingLabelLink extends _$PendingLabelLink {
  @override
  String? build() => null;

  void set(String location) => state = location;

  /// The waiting link, once — then it's cleared.
  String? take() {
    final link = state;
    state = null;
    return link;
  }
}

/// Shown briefly while the signed-in user's role document loads.
///
/// Also surfaces errors from that load: [authNotifierProvider] (thrown
/// during post-sign-in provisioning) and [signedInUserProvider] (thrown by
/// the users/{uid} listener, e.g. a rules mismatch). Without this, the
/// login screen — the only other place listening for these errors — has
/// already been navigated away from by the time they land, leaving the
/// user stuck on a spinner with no way out.
class _SplashScreen extends ConsumerWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error =
        ref.watch(authNotifierProvider).error ??
        ref.watch(signedInUserProvider).error;

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: error == null
            ? const CircularProgressIndicator(color: AppColors.sky)
            : _SplashError(
                error: error,
                onRetry: () =>
                    ref.read(authNotifierProvider.notifier).signOut(),
              ),
      ),
    );
  }
}

class _SplashError extends StatelessWidget {
  const _SplashError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = error is AppException
        ? (error as AppException).message
        : 'Something went wrong loading your account.';
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.sky, size: 40),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 240,
            child: PrimaryButton(
              label: 'Sign Out and Try Again',
              icon: null,
              onPressed: onRetry,
            ),
          ),
        ],
      ),
    );
  }
}
