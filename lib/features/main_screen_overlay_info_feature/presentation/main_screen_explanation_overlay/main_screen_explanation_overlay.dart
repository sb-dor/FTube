import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/animations/fade_animation.dart';
import 'package:youtube/features/main_screen_overlay_info_feature/presentation/cubit/main_screen_overlay_info_feature_cubit.dart';
import 'package:youtube/features/main_screen_overlay_info_feature/presentation/cubit/main_screenoverlay_info_feature_state.dart';
import 'package:youtube/widgets/text_widget.dart';

class MainScreenExplanationOverlay extends StatelessWidget {
  const MainScreenExplanationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainScreenOverlayInfoFeatureCubit, MainScreenOverlayInfoFeatureState>(
        builder: (context, state) {
      final currentState = state.mainScreenOverlayStateModel;
      return DefaultTextStyle(
        style: const TextStyle(
          color: Colors.black,
        ),
        child: Container(
          color: Colors.black.withOpacity(0.8),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: kToolbarHeight + 90,
                ),
                GestureDetector(
                  onTap: () => context.read<MainScreenOverlayInfoFeatureCubit>().removeOverlay(),
                  onLongPressDown: (_) =>
                      context.read<MainScreenOverlayInfoFeatureCubit>().removeOverlay(),
                  onVerticalDragDown: (_) =>
                      context.read<MainScreenOverlayInfoFeatureCubit>().removeOverlay(),
                  child: Container(
                    height: 180,
                    width: (MediaQuery.of(context).size.width / 4.3) * 2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      // color: Colors.black.withOpacity(0.3),
                      border: Border.all(
                        color: Colors.white,
                        width: 3.0,
                      ),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: const TextWidget(
                    text: "Hold inside this square to start preview",
                    textAlign: TextAlign.center,
                    size: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (currentState.showPopButton)
                  FadeAnimation(
                    child: ElevatedButton(
                      onPressed: () =>
                          context.read<MainScreenOverlayInfoFeatureCubit>().removeOverlay(),
                      child: const Text("Close"),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
