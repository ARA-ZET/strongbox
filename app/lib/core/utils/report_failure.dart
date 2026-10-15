import 'package:flutter/material.dart';

/// Runs [action] and, if it throws, shows "[failure]: error" in a SnackBar —
/// for buttons that fire a write without a result to wait on.
Future<void> reportFailure(
  BuildContext context,
  String failure,
  Future<void> Function() action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
  } catch (error) {
    messenger.showSnackBar(SnackBar(content: Text('$failure: $error')));
  }
}
