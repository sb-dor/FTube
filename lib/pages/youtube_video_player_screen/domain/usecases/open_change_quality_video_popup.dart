import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/video_information_cubit/video_information_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/presentation/popups/change_quality_video_popup_widget.dart';
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
