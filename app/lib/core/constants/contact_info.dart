/// Human contact channels — shown across the pre-signup flow and the
/// client portal so anyone can reach a person fast (doc: new-business
/// trust signal, not in the original spec docs).
abstract final class ContactInfo {
  ContactInfo._();

  /// Display text, kept exactly as given by the business.
  static const phoneDisplay = '+27 071 909 0839';

  /// `tel:` target — digits only, leading 0 dropped after the country code.
  static const phoneUri = 'tel:+27719090839';

  static const email = 'info@strongbox.co.za';
  static const emailUri = 'mailto:info@strongbox.co.za';
}
