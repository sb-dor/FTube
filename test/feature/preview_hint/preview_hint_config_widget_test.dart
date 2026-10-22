import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/feature/initialization/models/dependencies.dart';
import 'package:youtube/src/feature/preview_hint/widgets/preview_hint_config_widget.dart';

const _target = Rect.fromLTWH(100, 150, 200, 180);

Future<SharedPreferences> _pumpApp(WidgetTester tester, Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  final dependencies = Dependencies()..sharedPreferences = prefs;
  await tester.pumpWidget(
    dependencies.inject(
      child: const MaterialApp(
        localizationsDelegates: Localization.localizationsDelegates,
        supportedLocales: Localization.supportedLocales,
        home: Scaffold(body: Text('feed')),
      ),
    ),
  );
  return prefs;
}

BuildContext _context(WidgetTester tester) => tester.element(find.text('feed'));

void main() {
  testWidgets('shows once, fades in Close after 2 s and persists the flag', (tester) async {
    final prefs = await _pumpApp(tester, {});
    var done = false;
    PreviewHintConfigWidget.showIfNeeded(
      _context(tester),
      target: _target,
    ).then((_) => done = true);
    await tester.pumpAndSettle();

    expect(find.text('Hold inside this square to start preview'), findsOneWidget);
    final closeOpacity = find.ancestor(
      of: find.text('Close'),
      matching: find.byType(AnimatedOpacity),
    );
    expect(tester.widget<AnimatedOpacity>(closeOpacity).opacity, 0);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedOpacity>(closeOpacity).opacity, 1);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Hold inside this square to start preview'), findsNothing);
    expect(prefs.getBool('preview_hint_shown'), isTrue);
    expect(done, isTrue);
    expect(find.text('feed'), findsOneWidget);
  });

  testWidgets('tapping the square dismisses it', (tester) async {
    final prefs = await _pumpApp(tester, {});
    PreviewHintConfigWidget.showIfNeeded(_context(tester), target: _target).ignore();
    await tester.pumpAndSettle();

    await tester.tapAt(_target.center);
    await tester.pumpAndSettle();

    expect(find.text('Hold inside this square to start preview'), findsNothing);
    expect(prefs.getBool('preview_hint_shown'), isTrue);
  });

  testWidgets('back button closes it and persists the flag', (tester) async {
    final prefs = await _pumpApp(tester, {});
    PreviewHintConfigWidget.showIfNeeded(_context(tester), target: _target).ignore();
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Hold inside this square to start preview'), findsNothing);
    expect(find.text('feed'), findsOneWidget);
    expect(prefs.getBool('preview_hint_shown'), isTrue);
  });

  testWidgets('does nothing when already shown', (tester) async {
    await _pumpApp(tester, {'preview_hint_shown': true});
    var done = false;
    PreviewHintConfigWidget.showIfNeeded(
      _context(tester),
      target: _target,
    ).then((_) => done = true);
    await tester.pumpAndSettle();

    expect(find.text('Hold inside this square to start preview'), findsNothing);
    expect(done, isTrue);
  });
}
