import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/mini_player/models/mini_player_session.dart';
import 'package:youtube/src/feature/mini_player/widgets/controllers/mini_player_data_controller.dart';

final _session = MiniPlayerSession(
  video: const VideoItem(id: 'abcdefghijk', title: 'Song'),
  url: Uri.parse('https://example.com/video.mp4'),
  position: const Duration(seconds: 5),
);

/// Hands its video to the mini player when it is disposed, like the video screen.
class _Screen extends StatefulWidget {
  const _Screen({required this.controller});

  final MiniPlayerDataController controller;

  @override
  State<_Screen> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  @override
  void dispose() {
    widget.controller.show(_session);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Text('screen');
}

void main() {
  testWidgets('a screen disposed while the tree is locked brings up the mini player', (
    tester,
  ) async {
    final controller = MiniPlayerDataController();
    addTearDown(controller.dispose);
    final showScreen = ValueNotifier(true);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: showScreen,
              builder: (_, show, _) =>
                  show ? _Screen(controller: controller) : const SizedBox.shrink(),
            ),
            ListenableBuilder(
              listenable: controller,
              builder: (_, _) =>
                  Text(controller.session == null ? 'no mini player' : 'mini player'),
            ),
          ],
        ),
      ),
    );
    expect(find.text('no mini player'), findsOneWidget);

    showScreen.value = false;
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('mini player'), findsOneWidget);
  });

  test('show outside a frame notifies at once', () {
    final controller = MiniPlayerDataController();
    var notified = 0;
    controller
      ..addListener(() => notified++)
      ..show(_session);
    expect(notified, 1);
    expect(
      controller.close(position: const Duration(seconds: 9))?.position,
      const Duration(seconds: 9),
    );
    expect(controller.session, isNull);
    controller.dispose();
  });
}
