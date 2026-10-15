import 'package:riverpod_annotation/riverpod_annotation.dart';

extension ThrowIfError<T> on AsyncValue<T> {
  /// Rethrows the held error, if any.
  ///
  /// Mutation notifiers publish `AsyncValue.guard` results to `state` for
  /// widgets that watch them, but guard *catches* — so without this, a
  /// caller's `try/catch` never fires and a failed write looks successful.
  void throwIfError() {
    if (this case AsyncError(:final error, :final stackTrace)) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
