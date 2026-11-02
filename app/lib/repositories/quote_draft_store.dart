import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/quote.dart';

/// What survives a page reload or the trip through sign-up: the quote, and
/// whether to open booking once the visitor is signed in.
typedef SavedQuote = ({QuoteDraft draft, bool bookAfterSignIn});

/// Keeps the quote on this device (browser local storage on web).
abstract class QuoteDraftStore {
  Future<SavedQuote?> load();
  Future<void> save(SavedQuote quote);
}

/// [QuoteDraftStore] on shared_preferences. Never throws — losing a saved
/// quote must not break the app (e.g. storage blocked in a private tab).
class PrefsQuoteDraftStore implements QuoteDraftStore {
  static const _key = 'quoteDraft.v1';

  @override
  Future<SavedQuote?> load() async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return (
        draft: QuoteDraft.fromJson(
            Map<String, dynamic>.from(json['draft'] as Map)),
        bookAfterSignIn: json['bookAfterSignIn'] == true,
      );
    } catch (error) {
      debugPrint('Saved quote unavailable: $error');
      return null;
    }
  }

  @override
  Future<void> save(SavedQuote quote) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (quote.draft.isEmpty && !quote.bookAfterSignIn) {
        await prefs.remove(_key);
        return;
      }
      await prefs.setString(
          _key,
          jsonEncode({
            'draft': quote.draft.toJson(),
            'bookAfterSignIn': quote.bookAfterSignIn,
          }));
    } catch (error) {
      debugPrint('Could not save the quote: $error');
    }
  }
}
