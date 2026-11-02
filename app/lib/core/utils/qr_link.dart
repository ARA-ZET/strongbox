/// The app's public address (functions/src/constants.js `APP_URL`).
const appUrl = 'https://app.strongbox.co.za';

/// What a label's QR holds: a link to the item, e.g.
/// `https://app.strongbox.co.za/s/SBX-9942-A1`, so a phone's own camera
/// opens it in StrongBox (route `/s/:code`). Plain text would just sit
/// there — camera apps only act on links.
String qrPayload(String code) => '$appUrl/s/$code';

/// The code in a scan or typed entry. Takes a label link (any host, so
/// staging and localhost labels work too) or a bare code — labels printed
/// before links hold just the code. Upper-cased, as codes are stored.
String codeFromScan(String raw) {
  final value = raw.trim();
  final uri = Uri.tryParse(value);
  if (uri != null &&
      uri.hasScheme &&
      uri.pathSegments.length == 2 &&
      uri.pathSegments.first == 's') {
    return uri.pathSegments[1].trim().toUpperCase();
  }
  return value.toUpperCase();
}
