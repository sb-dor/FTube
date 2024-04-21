import 'package:flutter/material.dart';
import 'package:youtube/features/main_screen_overlay_info_feature/presentation/cubit/state_model/main_screen_overlay_state_model.dart';

abstract class MainScreenOverlayInfoFeatureState {
  MainScreenOverlayStateModel mainScreenOverlayStateModel;

  MainScreenOverlayInfoFeatureState(this.mainScreenOverlayStateModel);
}

class InitialMainScreenOverlayInfoFeatureState extends MainScreenOverlayInfoFeatureState {
  InitialMainScreenOverlayInfoFeatureState(super.overlay);
}
