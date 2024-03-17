import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/widgets/error_button_widget/error_button_widget.dart';
import 'package:youtube/widgets/text_widget.dart';

class VideosErrorWidget extends StatelessWidget {
  final VoidCallback onTap;

  const VideosErrorWidget({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorButtonWidget(
      onTap: onTap,
    );
  }
}
