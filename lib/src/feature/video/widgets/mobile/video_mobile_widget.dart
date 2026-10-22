import 'package:flutter/material.dart';
import 'package:youtube/src/feature/video/widgets/mobile/related_videos_sliver.dart';
import 'package:youtube/src/feature/video/widgets/mobile/video_actions_widget.dart';
import 'package:youtube/src/feature/video/widgets/mobile/video_info_widget.dart';
import 'package:youtube/src/feature/video/widgets/mobile/video_player_widget.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';

/// Layout of the video screen inside its draggable sheet.
class VideoMobileWidget extends StatefulWidget {
  const VideoMobileWidget({super.key});

  @override
  State<VideoMobileWidget> createState() => _VideoMobileWidgetState();
}

class _VideoMobileWidgetState extends State<VideoMobileWidget> {
  late final _scope = VideoConfigInhWidget.of(context);
  ScrollController? _scrollController;

  void _attach(ScrollController controller) {
    if (identical(_scrollController, controller)) return;
    _scrollController?.removeListener(_onScroll);
    _scrollController = controller..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final controller = _scrollController;
    if (controller == null || !controller.hasClients) return;
    final position = controller.position;
    if (position.pixels < position.maxScrollExtent - 600) return;
    final related = _scope.relatedVideosController;
    if (related.isProcessing || !related.state.hasMore) return;
    related.paginate();
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 1,
    minChildSize: 0.4,
    snap: true,
    snapSizes: const [1],
    expand: false,
    builder: (context, scrollController) {
      _attach(scrollController);
      return Column(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.315,
            child: const VideoPlayerWidget(),
          ),
          Expanded(
            child: CustomScrollView(
              controller: scrollController,
              slivers: const [
                SliverToBoxAdapter(child: VideoInfoWidget()),
                SliverToBoxAdapter(child: VideoActionsWidget()),
                RelatedVideosSliver(),
                SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ],
      );
    },
  );
}
