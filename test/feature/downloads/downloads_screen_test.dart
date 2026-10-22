import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/feature/downloads/widgets/downloads_config_widget.dart';
import 'package:youtube/src/feature/initialization/models/dependencies.dart';

void main() {
  late AppDatabase db;
  late Directory dir;

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    dir = Directory.systemTemp.createTempSync('ftube_downloads_screen');
  });

  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    final dependencies = Dependencies()..database = db;
    await tester.pumpWidget(
      dependencies.inject(
        child: MaterialApp(
          localizationsDelegates: Localization.localizationsDelegates,
          supportedLocales: Localization.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => DownloadsConfigWidget.open(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await settle(tester);
  }

  testWidgets('shows the empty state', (tester) async {
    await pumpScreen(tester);
    expect(find.text('In-App downloads'), findsOneWidget);
    expect(find.textContaining('No downloads yet'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('lists downloads, marks missing files and deletes after confirmation', (
    tester,
  ) async {
    final video = p.join(dir.path, 'video.mp4');
    File(video).writeAsStringSync('v');
    await tester.runAsync(() async {
      await db
          .into(db.fileDownloads)
          .insert(
            FileDownloadsCompanion.insert(
              name: const Value('Gone song'),
              downloadedPath: Value(p.join(dir.path, 'gone.m4a')),
              mediaType: const Value('audio'),
            ),
          );
      await db
          .into(db.fileDownloads)
          .insert(
            FileDownloadsCompanion.insert(
              name: const Value('My video'),
              downloadedPath: Value(video),
              channelName: const Value('Channel'),
              mediaType: const Value('video'),
            ),
          );
    });

    await pumpScreen(tester);

    expect(find.text('My video'), findsOneWidget);
    expect(find.text('MP4'), findsOneWidget);
    expect(find.byTooltip('Save in Gallery'), findsOneWidget);
    expect(find.text('Gone song'), findsOneWidget);
    expect(find.text('File not found'), findsOneWidget);
    expect(find.byTooltip('Save in Downloads'), findsNothing);

    await tester.tap(find.byTooltip('More').first);
    await settle(tester);
    await tester.tap(find.text('Delete'));
    await settle(tester);
    expect(find.text('Delete download?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await settle(tester);

    expect(find.text('Delete download?'), findsNothing);
    expect(find.text('My video'), findsNothing);
    expect(File(video).existsSync(), isFalse);
    expect(find.text('Gone song'), findsOneWidget);
    await unmount(tester);
  });
}

/// Lets the database and file system work in real time, then settles the frames.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

/// Disposes the screen and lets drift close its query streams before the test ends.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}
