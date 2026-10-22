import 'dart:ui';

/// Languages the app is translated into; anything else falls back to English.
const supportedLanguages = {'en', 'ru'};

/// The app language for the device [locale]: Russian on Russian devices, English otherwise.
String appLanguage([Locale? locale]) {
  final code = (locale ?? PlatformDispatcher.instance.locale).languageCode;
  return supportedLanguages.contains(code) ? code : 'en';
}
