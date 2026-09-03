/// A user-friendly error surfaced from the data layer.
///
/// Repositories catch raw [FirebaseException]s and rethrow these so the UI
/// can show a stable message and (optionally) branch on [code].
class AppException implements Exception {
  const AppException({
    required this.code,
    required this.message,
    this.original,
  });

  /// Stable, machine-readable code, e.g. `permission-denied`, `not-found`.
  final String code;

  /// Human-readable message safe to show in the UI.
  final String message;

  /// The underlying error, kept for logging.
  final Object? original;

  /// Wraps an arbitrary error, reusing a FirebaseException code when present.
  factory AppException.from(Object error, [String fallbackMessage = 'Something went wrong.']) {
    final code = _codeOf(error);
    return AppException(
      code: code,
      message: fallbackMessage,
      original: error,
    );
  }

  static String _codeOf(Object error) {
    try {
      // FirebaseException exposes a `.code`; read dynamically to avoid a
      // hard dependency here.
      final dynamic dynError = error;
      final code = dynError.code;
      if (code is String && code.isNotEmpty) return code;
    } catch (_) {
      // Not a coded error — fall through.
    }
    return 'unknown';
  }

  @override
  String toString() => 'AppException($code): $message';
}
