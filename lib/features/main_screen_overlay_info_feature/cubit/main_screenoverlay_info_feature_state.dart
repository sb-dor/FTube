import 'state_model/main_screen_overlay_state_model.dart';

abstract class MainScreenOverlayInfoFeatureState {
  MainScreenOverlayStateModel mainScreenOverlayStateModel;

  MainScreenOverlayInfoFeatureState(this.mainScreenOverlayStateModel);
}

class InitialMainScreenOverlayInfoFeatureState extends MainScreenOverlayInfoFeatureState {
  InitialMainScreenOverlayInfoFeatureState(super.overlay);
}
