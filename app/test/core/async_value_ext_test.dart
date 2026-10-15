import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:strong_box/core/utils/async_value_ext.dart';

void main() {
  test('a failed guarded write reaches the caller', () async {
    final result =
        await AsyncValue.guard<void>(() async => throw StateError('denied'));
    expect(result.throwIfError, throwsStateError);
  });

  test('a successful write does not throw', () async {
    final result = await AsyncValue.guard<void>(() async {});
    expect(result.throwIfError, returnsNormally);
  });
}
