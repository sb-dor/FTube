import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube/src/feature/preview_hint/data/preview_hint_repository.dart';

void main() {
  test('is not shown on a fresh install', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = PreviewHintRepositoryImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
    );

    expect(repository.isShown(), isFalse);
  });

  test('markShown persists the preview_hint_shown flag', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repository = PreviewHintRepositoryImpl(sharedPreferences: prefs);

    await repository.markShown();

    expect(repository.isShown(), isTrue);
    expect(prefs.getBool('preview_hint_shown'), isTrue);
    expect(PreviewHintRepositoryImpl(sharedPreferences: prefs).isShown(), isTrue);
  });

  test('reads a flag saved on an earlier run', () async {
    SharedPreferences.setMockInitialValues({'preview_hint_shown': true});
    final repository = PreviewHintRepositoryImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
    );

    expect(repository.isShown(), isTrue);
  });
}
