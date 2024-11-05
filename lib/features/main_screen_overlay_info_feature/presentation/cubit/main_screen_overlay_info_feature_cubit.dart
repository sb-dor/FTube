import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/utils/hive_database_helper/hive_database_helper.dart';
import 'package:youtube/features/main_screen_overlay_info_feature/presentation/main_screen_explanation_overlay/main_screen_explanation_overlay.dart';
import 'main_screenoverlay_info_feature_state.dart';
import 'state_model/main_screen_overlay_state_model.dart';

class MainScreenOverlayInfoFeatureCubit extends Cubit<MainScreenOverlayInfoFeatureState> {
  late HiveDatabaseHelper _hiveDatabaseHelper;
  late MainScreenOverlayStateModel _currentState;

  MainScreenOverlayInfoFeatureCubit()
      : super(InitialMainScreenOverlayInfoFeatureState(MainScreenOverlayStateModel())) {
    _hiveDatabaseHelper = locator<HiveDatabaseHelper>();
    _currentState = state.mainScreenOverlayStateModel;
  }

  void checkCanUserScroll() async {
    _currentState.canUserScroll = await _hiveDatabaseHelper.isOverlayShowedForMainScreen();
  }

  void showOverlay(BuildContext context) async {
    final valueForCheckingOverlay = await _hiveDatabaseHelper.isOverlayShowedForMainScreen();

    if (valueForCheckingOverlay) return;

    if (!context.mounted) return;

    removeOverlay();

    if ((_currentState.timerForShowingPopButton?.isActive ?? false)) {
      _currentState.timerForShowingPopButton?.cancel();
    }

    _currentState.overlay = OverlayEntry(
      builder: (context) {
        return const MainScreenExplanationOverlay();
      },
    );

    Overlay.of(context).insert(_currentState.overlay!);

    _currentState.showPopButton = false;

    InitialMainScreenOverlayInfoFeatureState(_currentState);

    _currentState.timerForShowingPopButton = Timer(const Duration(seconds: 2), () {
      _currentState.showPopButton = true;
      emit(InitialMainScreenOverlayInfoFeatureState(_currentState));
    });
  }

  void removeOverlay() async {
    _currentState.overlay?.remove();
    _currentState.overlay?.dispose();
    _currentState.overlay = null;
    await _hiveDatabaseHelper.overlayShowedForMainScreen();
    _currentState.canUserScroll = true;
    InitialMainScreenOverlayInfoFeatureState(_currentState);
  }
}
