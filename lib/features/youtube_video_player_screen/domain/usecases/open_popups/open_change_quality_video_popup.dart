import 'package:flutter/material.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/popups/change_quality_video_popup_widget.dart';
import 'package:youtube/core/widgets/side_modal_sheet.dart';
import 'package:youtube/core/widgets/wrapped_popup_widget.dart';

abstract class OpenChangeQualityVideoPopup {
  static void openChangeQualityPopUp(BuildContext context, {bool fromFullScreen = false}) async {
    if (fromFullScreen) {
      await SideSheet.left(
        width: MediaQuery.of(context).size.width / 2.5,
        body: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: const RotatedBox(quarterTurns: 1, child: ChangeQualityVideoPopup()),
        ),
        context: context,
      );
    } else {
      return showModalBottomSheet(
        context: context,
        builder:
            (context) => const WrappedPopupWidget(
              backgroundColor: Colors.white,
              child: ChangeQualityVideoPopup(),
            ),
      );
    }
  }
}
