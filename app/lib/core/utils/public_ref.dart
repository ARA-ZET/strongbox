import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../enums/app_enums.dart';
import '../models/job.dart';

/// Crockford base32 — no I, L, O or U to misread.
const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

/// Public reference — what people see instead of a Firebase id, e.g.
/// `SB-7K3QX9`. Firebase ids (uids, client / job / unit ids) never go on
/// screen, in a label or on a document. A one-way fingerprint of the id:
/// stable and practically unique, but the id can't be read back from it.
/// Must match functions/src/references.js exactly.
String publicRef(String prefix, String id) {
  // First 30 bits of SHA-256(id) → 6 base32 characters.
  final bytes = sha256.convert(utf8.encode(id)).bytes;
  var bits =
      ((bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3]) >> 2;
  final out = StringBuffer();
  for (var i = 0; i < 6; i++) {
    out.write(_alphabet[bits & 31]);
    bits >>= 5;
  }
  return '$prefix-${out.toString().split('').reversed.join()}';
}

/// A client's account number, e.g. `SB-7K3QX9`.
String clientRef(String clientId) => publicRef('SB', clientId);

/// A job's reference: `PU-…` for pickups, `DL-…` for deliveries, `SD-…`
/// for supply drop-offs. Mirrored by `jobRef` in functions/src/references.js.
String jobRef(Job job) => publicRef(
    switch (job.type) {
      JobType.pickup => 'PU',
      JobType.delivery => 'DL',
      JobType.supplyDrop => 'SD',
    },
    job.id);

/// A staff member's E-ID, e.g. `DRV-Q2N7HC`.
String staffRef(String uid) => publicRef('DRV', uid);
