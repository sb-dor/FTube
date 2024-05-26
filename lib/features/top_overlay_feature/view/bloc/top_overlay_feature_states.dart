import 'package:flutter/foundation.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/state_model/top_overlay_feature_state_model.dart';

@immutable
class TopOverlayFeatureStates {
  final TopOverlayFeatureStateModel topOverlayFeatureStateModel;

  const TopOverlayFeatureStates(this.topOverlayFeatureStateModel);
}

class LoadingOverlayFeatureState extends TopOverlayFeatureStates {
  const LoadingOverlayFeatureState(super.topOverlayFeatureStateModel);
}

class LoadedOverlayFeatureState extends TopOverlayFeatureStates {
  const LoadedOverlayFeatureState(super.topOverlayFeatureStateModel);
}
