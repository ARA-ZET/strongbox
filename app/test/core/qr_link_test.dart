import 'package:flutter_test/flutter_test.dart';
import 'package:strong_box/core/utils/qr_link.dart';

void main() {
  test('labels hold a link to the item', () {
    expect(qrPayload('SBX-9942-A1'),
        'https://app.strongbox.co.za/s/SBX-9942-A1');
  });

  test('scans read the code from a link or a bare code', () {
    expect(codeFromScan('https://app.strongbox.co.za/s/SBX-9942-A1'),
        'SBX-9942-A1');
    // Staging / local labels, and stray whitespace or case.
    expect(codeFromScan(' http://localhost:5000/s/sbx-9942-a1 '),
        'SBX-9942-A1');
    // Labels printed before links.
    expect(codeFromScan('sbx-9942-a1'), 'SBX-9942-A1');
    // Not one of ours — passed through, so lookup says "not linked".
    expect(codeFromScan('https://example.com/a/b/c'),
        'HTTPS://EXAMPLE.COM/A/B/C');
  });
}
