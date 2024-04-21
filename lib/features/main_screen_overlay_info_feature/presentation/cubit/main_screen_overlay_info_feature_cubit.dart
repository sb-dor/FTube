import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/main_screen_overlay_info_feature/presentation/main_screen_explanation_overlay/main_screen_explanation_overlay.dart';
import 'package:youtube/utils/hive_database_helper/hive_database_helper.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';
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
        return MainScreenExplanationOverlay();
      },
    );

    Overlay.of(context).insert(_currentState.overlay!);

    InitialMainScreenOverlayInfoFeatureState(_currentState);

    _currentState.timerForShowingPopButton = Timer(const Duration(seconds: 3), () {
      _currentState.showPopButton = true;
      emit(InitialMainScreenOverlayInfoFeatureState(_currentState));
    });
  }

  void removeOverlay() {
    _currentState.overlay?.remove();
    _currentState.overlay?.dispose();
    _currentState.overlay = null;
    InitialMainScreenOverlayInfoFeatureState(_currentState);
  }
}
