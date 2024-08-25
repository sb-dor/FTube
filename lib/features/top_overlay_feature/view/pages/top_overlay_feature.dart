import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/top_overlay_feature_bloc.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/top_overlay_feature_events.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/top_overlay_feature_states.dart';

class TopOverlayFeature extends StatefulWidget {
  const TopOverlayFeature({super.key});

  @override
  State<TopOverlayFeature> createState() => _TopOverlayFeatureState();
}

class _TopOverlayFeatureState extends State<TopOverlayFeature> {
  late StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _subscription = FlutterOverlayWindow.overlayListener.listen((event) {
      context.read<TopOverlayFeatureBloc>().add(ConvertToLoadingState());
      debugPrint("Current Event: $event | type: ${event.runtimeType}");
      if (event is! String) return;
      Map<String, dynamic> convertToJson = jsonDecode(event);
      if (!convertToJson.containsKey("url_for_run") || convertToJson['url_for_run'] == null) return;
      final String videoUrl = convertToJson['url_for_run'];
      context.read<TopOverlayFeatureBloc>().add(InitOverlayVideoController(videoUrl));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopOverlayFeatureBloc, TopOverlayFeatureStates>(
      builder: (context, state) {
        final currentState = state.topOverlayFeatureStateModel;
        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: state is LoadedOverlayFeatureState
                          ? GestureDetector(
                              onTap: () {},
                              child: SizedBox.expand(
                                child: FittedBox(
                                  fit: currentState.playerController!.value.size.width >=
                                          currentState.playerController!.value.size.height
                                      ? BoxFit.cover
                                      : BoxFit.scaleDown,
                                  child: SizedBox(
                                    width: currentState.playerController!.value.size.width,
                                    height: currentState.playerController!.value.size.height,
                                    child: VideoPlayer(
                                      currentState.playerController!,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const Text(
                              "Video is not loaded",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
