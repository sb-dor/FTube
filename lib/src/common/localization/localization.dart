import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meta/meta.dart';
import 'package:youtube/src/common/localization/generated/l10n.dart' as generated;

/// App localization (EN/RU). All visible text goes through `Localization.of(context)`.
final class Localization extends generated.GeneratedLocalization {
  Localization._(this.locale);

  /// The locale this instance was loaded for.
  final Locale locale;

  /// Localization delegate.
  static const LocalizationsDelegate<Localization> delegate = _LocalizationView(
    generated.AppLocalizationDelegate(),
  );

  /// All delegates the app needs: ours plus the Flutter framework ones.
  static const List<LocalizationsDelegate<Object?>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// Supported locales, in order of preference.
  static const List<Locale> supportedLocales = [Locale('en'), Locale('ru')];

  /// Get localization instance for the widgets structure.
  static Localization of(BuildContext context) =>
      switch (Localizations.of<Localization>(context, Localization)) {
        final Localization localization => localization,
        _ => throw ArgumentError(
          'Out of scope, not found inherited widgets a Localization of the exact type',
          'out_of_scope',
        ),
      };
}

@immutable
final class _LocalizationView extends LocalizationsDelegate<Localization> {
  @literal
  const _LocalizationView(LocalizationsDelegate<generated.GeneratedLocalization> delegate)
    : _delegate = delegate;

  final LocalizationsDelegate<generated.GeneratedLocalization> _delegate;

  @override
  bool isSupported(Locale locale) => _delegate.isSupported(locale);

  @override
  Future<Localization> load(Locale locale) =>
      generated.GeneratedLocalization.load(locale)
          .then<Localization>((_) => Localization._(locale));

  @override
  bool shouldReload(covariant _LocalizationView old) => _delegate.shouldReload(old._delegate);
}
