import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/features/auth/providers/auth_provider.dart';

void main() {
  test('a rejected password gets an actionable message, not Firebase text',
      () {
    final error =
        friendlyAuthError(FirebaseAuthException(code: 'invalid-credential'));
    expect(error.message, isNot(contains('firebase_auth')));
    expect(error.message, contains('Forgot password?'));
    expect(error.message, contains('Continue with Google'));
  });

  test('unknown codes still name the code for support', () {
    final error = friendlyAuthError(FirebaseAuthException(code: 'odd-thing'));
    expect(error.message, contains('odd-thing'));
  });
}
