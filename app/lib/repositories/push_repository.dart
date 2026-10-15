import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// A push notification as the app sees it. [route] is where tapping it
/// goes (set by the `onNotificationCreated` Cloud Function).
typedef PushMessage = ({String title, String body, String? route});

/// Whether this device can receive push, and whether the user allowed it.
enum PushPermission { unsupported, notDetermined, granted, denied }

/// Device push registration via FCM (doc 22). The `onNotificationCreated`
/// Cloud Function sends to every token on `users/{uid}.fcmTokens`.
abstract class PushRepository {
  /// Current permission, without prompting.
  Future<PushPermission> permission();

  /// Shows the system prompt (web: the browser's) and returns the outcome.
  Future<PushPermission> requestPermission();

  /// This device's FCM token, or null when push is unavailable.
  Future<String?> token();

  /// New tokens issued by FCM for this device.
  Stream<String> get onTokenRefresh;

  /// Pushes received while the app is open.
  Stream<PushMessage> get onForegroundMessage;

  /// Pushes the user tapped while the app was in the background.
  Stream<PushMessage> get onMessageOpened;

  /// The push that launched the app from terminated, if any.
  Future<PushMessage?> initialMessage();
}

/// [PushRepository] backed by firebase_messaging.
///
/// Every call degrades to "unsupported" instead of throwing — push is a
/// nice-to-have, and the app also runs without Firebase configured.
class FirebasePushRepository implements PushRepository {
  FirebasePushRepository({String? webVapidKey})
      : _vapidKey = webVapidKey ??
            const String.fromEnvironment('FCM_VAPID_KEY');

  /// Web push needs the project's Web Push certificate key pair (Firebase
  /// Console → Project settings → Cloud Messaging), passed at build time
  /// with `--dart-define=FCM_VAPID_KEY=…`.
  final String _vapidKey;

  // Resolved lazily: FirebaseMessaging.instance throws before
  // Firebase.initializeApp has succeeded.
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  Future<bool> _supported() async {
    if (kIsWeb && _vapidKey.isEmpty) return false;
    try {
      return await _messaging.isSupported();
    } catch (_) {
      return false;
    }
  }

  static PushPermission _map(AuthorizationStatus status) => switch (status) {
        AuthorizationStatus.authorized ||
        AuthorizationStatus.provisional =>
          PushPermission.granted,
        AuthorizationStatus.denied => PushPermission.denied,
        AuthorizationStatus.notDetermined => PushPermission.notDetermined,
      };

  static PushMessage _toPush(RemoteMessage message) => (
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        route: message.data['route'] as String?,
      );

  @override
  Future<PushPermission> permission() async {
    if (!await _supported()) return PushPermission.unsupported;
    try {
      final settings = await _messaging.getNotificationSettings();
      return _map(settings.authorizationStatus);
    } catch (error) {
      debugPrint('Push permission check failed: $error');
      return PushPermission.unsupported;
    }
  }

  @override
  Future<PushPermission> requestPermission() async {
    if (!await _supported()) return PushPermission.unsupported;
    try {
      final settings = await _messaging.requestPermission();
      return _map(settings.authorizationStatus);
    } catch (error) {
      debugPrint('Push permission request failed: $error');
      return PushPermission.unsupported;
    }
  }

  @override
  Future<String?> token() async {
    if (!await _supported()) return null;
    try {
      return await _messaging.getToken(
          vapidKey: kIsWeb ? _vapidKey : null);
    } catch (error) {
      // e.g. no service worker (web dev server) or APNs not configured.
      debugPrint('Push token unavailable: $error');
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh => _safe(() => _messaging.onTokenRefresh);

  @override
  Stream<PushMessage> get onForegroundMessage =>
      _safe(() => FirebaseMessaging.onMessage.map(_toPush));

  @override
  Stream<PushMessage> get onMessageOpened =>
      _safe(() => FirebaseMessaging.onMessageOpenedApp.map(_toPush));

  @override
  Future<PushMessage?> initialMessage() async {
    if (!await _supported()) return null;
    try {
      final message = await _messaging.getInitialMessage();
      return message == null ? null : _toPush(message);
    } catch (_) {
      return null;
    }
  }

  Stream<T> _safe<T>(Stream<T> Function() open) async* {
    if (!await _supported()) return;
    yield* open();
  }
}
