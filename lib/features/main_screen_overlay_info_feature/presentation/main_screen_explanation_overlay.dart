import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/animations/fade_animation.dart';
import 'package:youtube/features/main_screen_overlay_info_feature/cubit/main_screen_overlay_info_feature_cubit.dart';
import 'package:youtube/features/main_screen_overlay_info_feature/cubit/main_screenoverlay_info_feature_state.dart';
import 'package:youtube/core/widgets/text_widget.dart';
import 'package:youtube/features/main_screen_overlay_info_feature/cubit/state_model/main_screen_overlay_state_model.dart';

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
            color: Colors.black.withOpacity(0.3),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: kToolbarHeight + 90),
                  const _SquareWidget(),
                  _SquareInfoWidget(currentState: currentState),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SquareWidget extends StatelessWidget {
  const _SquareWidget();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<MainScreenOverlayInfoFeatureCubit>().removeOverlay(),
      onLongPressDown: (_) => context.read<MainScreenOverlayInfoFeatureCubit>().removeOverlay(),
      onVerticalDragDown: (_) => context.read<MainScreenOverlayInfoFeatureCubit>().removeOverlay(),
      child: Container(
        height: 180,
        width: (MediaQuery.of(context).size.width / 4.3) * 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.black.withOpacity(0.5),
          border: Border.all(
            color: Colors.red,
            width: 3.0,
          ),
        ),
      ),
    );
  }
}

class _SquareInfoWidget extends StatelessWidget {
  final MainScreenOverlayStateModel currentState;

  const _SquareInfoWidget({
    required this.currentState,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          children: [
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
                duration: const Duration(seconds: 1),
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<MainScreenOverlayInfoFeatureCubit>().removeOverlay(),
                  child: const Text("Close"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
