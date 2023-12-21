import 'package:flutter/material.dart';
import 'package:youtube/pages/youtube_video_player_screen/presentation/popups/downloading_video_popup_widget.dart';
import 'package:youtube/widgets/wrapped_popup_widget.dart';

abstract class OpenDownloadingVideoPopup {
  static openDownloadingVideoPopup({required BuildContext context}) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => const WrappedPopupWidget(
        child: DownloadingVideoPopupWidget(),
      ),
    );
  }
}
