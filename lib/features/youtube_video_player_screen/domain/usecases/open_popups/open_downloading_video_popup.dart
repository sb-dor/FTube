import 'package:flutter/material.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/popups/downloading_video_popup_widget.dart';

abstract class OpenDownloadingVideoPopup {
  static openDownloadingVideoPopup({required BuildContext context}) async {
    showDialog(
      context: context,
      // isScrollControlled: true,
      builder: (context) => DownloadingVideoPopupWidget(),
    );
  }
}
