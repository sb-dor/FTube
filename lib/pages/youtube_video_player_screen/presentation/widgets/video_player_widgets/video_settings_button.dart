import 'package:flutter/material.dart';
import 'package:youtube/pages/youtube_video_player_screen/domain/usecases/open_popups/open_change_quality_video_popup.dart';
import 'package:youtube/pages/youtube_video_player_screen/presentation/popups/change_quality_video_popup_widget.dart';

class VideoSettingsButton extends StatelessWidget {
  const VideoSettingsButton({Key? key}) : super(key: key);

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
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () => OpenChangeQualityVideoPopup.openChangeQualityPopUp(context),
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
