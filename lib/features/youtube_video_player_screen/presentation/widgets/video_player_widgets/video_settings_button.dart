import 'package:flutter/material.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/usecases/open_popups/open_change_quality_video_popup.dart';

class VideoSettingsButton extends StatelessWidget {
  final bool fromFullScreen;

  const VideoSettingsButton({Key? key, this.fromFullScreen = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 5,
      left: 5,
      top: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () => OpenChangeQualityVideoPopup.openChangeQualityPopUp(
              context,
              fromFullScreen: fromFullScreen,
            ),
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
