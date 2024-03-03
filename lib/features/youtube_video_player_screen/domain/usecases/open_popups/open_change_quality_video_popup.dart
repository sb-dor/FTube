import 'package:flutter/material.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/popups/change_quality_video_popup_widget.dart';
import 'package:youtube/widgets/wrapped_popup_widget.dart';

abstract class OpenChangeQualityVideoPopup {
  static void openChangeQualityPopUp(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      builder: (context) => const WrappedPopupWidget(
        backgroundColor: Colors.white,
        child: ChangeQualityVideoPopup(),
      ),
    );
  }
}
