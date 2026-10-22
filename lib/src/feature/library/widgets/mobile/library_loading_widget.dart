import 'package:flutter/material.dart';
import 'package:youtube/src/common/widget/shimmer_box.dart';
import 'package:youtube/src/feature/library/widgets/mobile/library_history_card_widget.dart';
import 'package:youtube/src/feature/playlists/widgets/playlist_card_widget.dart';

/// Shimmering placeholders for the history and playlists rows.
class LibraryLoadingWidget extends StatelessWidget {
  const LibraryLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: 100, height: 24, borderRadius: BorderRadius.circular(10)),
        const SizedBox(height: 15),
        _row(LibraryHistoryCardWidget.width, LibraryHistoryCardWidget.height),
        const SizedBox(height: 30),
        ShimmerBox(width: 100, height: 24, borderRadius: BorderRadius.circular(10)),
        const SizedBox(height: 15),
        _row(PlaylistCardWidget.width, PlaylistCardWidget.coverHeight),
      ],
    ),
  );

  Widget _row(double width, double height) => SizedBox(
    height: height,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (_, _) =>
          ShimmerBox(width: width, height: height, borderRadius: BorderRadius.circular(10)),
    ),
  );
}
