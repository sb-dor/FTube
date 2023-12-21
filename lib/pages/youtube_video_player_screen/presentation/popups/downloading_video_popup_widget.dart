import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_states.dart';
import 'package:youtube/pages/youtube_video_player_screen/domain/entities/dowloading_type.dart';
import 'package:youtube/widgets/text_widget.dart';

class DownloadingVideoPopupWidget extends StatelessWidget {
  const DownloadingVideoPopupWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(builder: (context, state) {
      var currentState = state.youtubeVideoStateModel;
      return AnimatedSize(
        duration: const Duration(milliseconds: 1),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                  children: DownloadingType.types
                      .map((e) => Expanded(
                            child: Center(
                              child: GestureDetector(
                                onTap: () => context
                                    .read<YoutubeVideoCubit>()
                                    .clickTypeOfDownloadingVideo(e),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 175),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: currentState.downloadingType?.id == e.id
                                          ? Border.all(color: Colors.red)
                                          : null,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: currentState.downloadingType?.id == e.id
                                          ? []
                                          : const [
                                              BoxShadow(
                                                color: Colors.grey,
                                                blurRadius: 5,
                                              ),
                                            ]),
                                  child: const Column(
                                    children: [
                                      Icon(Icons.music_note),
                                      SizedBox(height: 5),
                                      TextWidget(
                                        text: "Download sound",
                                        textAlign: TextAlign.center,
                                        size: 15,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.9,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList()),
            ),
            Positioned.fill(child: _SoundDownloadingData())
          ],
        ),
      );
    });
  }
}

class _SoundDownloadingData extends StatelessWidget {
  const _SoundDownloadingData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
