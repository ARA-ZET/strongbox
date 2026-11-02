import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/enums/app_enums.dart';
import 'package:strong_box/core/models/job.dart';
import 'package:strong_box/core/utils/public_ref.dart';

void main() {
  // Same vectors as functions/test/references.test.js — app and functions
  // must agree (invoice references are made server-side).
  test('matches the functions\' references', () {
    expect(publicRef('SB', 'abc123'), 'SB-DJGKTM');
    expect(publicRef('SB', 'client-1'), 'SB-AW2DW6');
    expect(publicRef('SB', 'xK9mQ2pL7vR4tY8wN3bZ'), 'SB-XKYNBG');
  });

  test('never contains the id', () {
    const id = 'xK9mQ2pL7vR4tY8wN3bZ';
    for (final ref in [clientRef(id), staffRef(id)]) {
      expect(
        ref.toLowerCase(),
        isNot(contains(id.substring(0, 4).toLowerCase())),
      );
    }
  });

  test('jobs read as pickup or delivery', () {
    const job = Job(id: 'job-1', tenantId: 't', clientId: 'c');
    expect(jobRef(job), 'PU-09NBCE');
    expect(jobRef(job.copyWith(type: JobType.delivery)), startsWith('DL-'));
  });
}
