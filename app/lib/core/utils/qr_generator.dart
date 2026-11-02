import 'dart:math';
import 'public_ref.dart';

final _random = Random();

String _suffix() {
  final letter = String.fromCharCode(65 + _random.nextInt(26));
  final digit = _random.nextInt(10);
  return '$letter$digit';
}

/// Storage-unit QR code, e.g. `SBX-9942-A1`.
String generateBoxQrCode() =>
    'SBX-${1000 + _random.nextInt(9000)}-${_suffix()}';

/// Item QR code, e.g. `ITM-1234-B2`.
String generateItemQrCode() =>
    'ITM-${1000 + _random.nextInt(9000)}-${_suffix()}';

/// Driver E-ID QR code, e.g. `DRV-Q2N7HC` — never the uid itself.
String generateDriverEId(String uid) => staffRef(uid);

/// [count] unique unit codes for a printed batch.
List<String> generateBoxQrBatch(int count) {
  final codes = <String>{};
  while (codes.length < count) {
    codes.add(generateBoxQrCode());
  }
  return codes.toList();
}
