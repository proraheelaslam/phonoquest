import 'package:flutter/material.dart';

/// Supported app language codes.
class AppLocale {
  static const en = 'en';
  static const es = 'es';

  static const supportedCodes = <String>[en, es];

  static Locale toFlutterLocale(String code) {
    final normalized = normalize(code);
    return Locale(normalized);
  }

  static String normalize(String? value) {
    final raw = (value ?? en).trim().toLowerCase();
    const aliases = {
      'english': en,
      'en-us': en,
      'en_us': en,
      'spanish': es,
      'es-es': es,
      'es_es': es,
      'espanol': es,
      'español': es,
    };
    final code = aliases[raw] ?? raw;
    return supportedCodes.contains(code) ? code : en;
  }

  static String displayName(String code) {
    switch (normalize(code)) {
      case es:
        return 'Spanish';
      default:
        return 'English';
    }
  }

  static String displayNameLocalized(String code, String viewingLocale) {
    if (normalize(viewingLocale) == es) {
      return normalize(code) == es ? 'Español' : 'Inglés';
    }
    return displayName(code);
  }

  static String subtitle(String code) {
    switch (normalize(code)) {
      case es:
        return 'Usar la aplicación en español';
      default:
        return 'Use app in English language';
    }
  }
}
