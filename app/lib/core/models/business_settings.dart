// ignore_for_file: invalid_annotation_target
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../constants/contact_info.dart';
import '../enums/app_enums.dart';
import '../utils/timestamp_converter.dart';
import 'value_objects.dart';

part 'business_settings.freezed.dart';
part 'business_settings.g.dart';

/// Opening and closing time of a job [TimeWindow], as `HH:mm` (24h).
@freezed
class WindowHours with _$WindowHours {
  const factory WindowHours({required String start, required String end}) =
      _WindowHours;

  factory WindowHours.fromJson(Map<String, dynamic> json) =>
      _$WindowHoursFromJson(json);
}

/// Business details and operations defaults, edited in Admin → Settings and
/// stored on `tenants/{tenantId}`. Readable without signing in (the login
/// screen shows the contact details), so only public information lives here.
/// Until an admin first saves, everyone uses [BusinessSettings.defaults].
@freezed
class BusinessSettings with _$BusinessSettings {
  const BusinessSettings._();

  const factory BusinessSettings({
    @Default('StrongBox Logistics') String name,
    @Default(ContactInfo.phoneDisplay) String contactPhone,
    @Default(ContactInfo.email) String contactEmail,
    @Default(Address()) Address address,

    /// Where pickups and deliveries are offered, e.g. "Cape Town and
    /// surrounds" — shown when booking.
    @Default('Cape Town and surrounds') String serviceArea,
    @Default(WindowHours(start: '08:00', end: '12:00')) WindowHours morning,
    @Default(WindowHours(start: '12:00', end: '16:00')) WindowHours afternoon,
    @Default(WindowHours(start: '16:00', end: '20:00')) WindowHours evening,

    /// How clients pay their monthly invoice — bank, account number, branch
    /// code. Shown on the client billing page with each invoice's EFT
    /// reference. Public like the rest of this doc, so banking details
    /// only, never logins.
    @Default('') String paymentInstructions,
    @NullableTimestampConverter() DateTime? updatedAt,
    String? updatedBy,
  }) = _BusinessSettings;

  static const defaults = BusinessSettings();

  factory BusinessSettings.fromJson(Map<String, dynamic> json) =>
      _$BusinessSettingsFromJson(json);

  factory BusinessSettings.fromFirestore(DocumentSnapshot doc) =>
      BusinessSettings.fromJson(doc.data()! as Map<String, dynamic>);

  WindowHours hoursFor(TimeWindow window) => switch (window) {
    TimeWindow.morning => morning,
    TimeWindow.afternoon => afternoon,
    TimeWindow.evening => evening,
  };

  /// "Morning (08:00–12:00)".
  String windowLabel(TimeWindow window) {
    final hours = hoursFor(window);
    return '${window.title} (${hours.start}–${hours.end})';
  }

  /// "08:00–12:00".
  String windowRange(TimeWindow window) {
    final hours = hoursFor(window);
    return '${hours.start}–${hours.end}';
  }

  /// `tel:` target for [contactPhone]: digits only, with a South African
  /// trunk 0 folded into +27 (`+27 071 …` and `071 …` both → `+2771…`).
  String get phoneUri {
    var digits = contactPhone.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.startsWith('+270')) digits = '+27${digits.substring(4)}';
    if (digits.startsWith('0')) digits = '+27${digits.substring(1)}';
    return 'tel:$digits';
  }

  String get emailUri => 'mailto:$contactEmail';
}

final _hhmm = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

/// Everything that would make [settings] unsafe to save, worst first.
List<String> validateBusinessSettings(BusinessSettings settings) {
  final problems = <String>[];
  if (settings.name.trim().isEmpty) problems.add('Business name is required.');
  if (settings.contactPhone.replaceAll(RegExp(r'\D'), '').length < 9) {
    problems.add('Enter a contact phone number.');
  }
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(settings.contactEmail)) {
    problems.add('Enter a valid contact email.');
  }
  if (settings.serviceArea.trim().isEmpty) {
    problems.add('Service area is required.');
  }
  for (final window in TimeWindow.values) {
    final hours = settings.hoursFor(window);
    if (!_hhmm.hasMatch(hours.start) || !_hhmm.hasMatch(hours.end)) {
      problems.add('${window.title} hours must be HH:mm, e.g. 08:00.');
    } else if (hours.start.compareTo(hours.end) >= 0) {
      problems.add('${window.title} must end after it starts.');
    }
  }
  return problems;
}
