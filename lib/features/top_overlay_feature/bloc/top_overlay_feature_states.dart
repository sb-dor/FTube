import 'package:flutter/foundation.dart';
import 'state_model/top_overlay_feature_state_model.dart';

@immutable
sealed class TopOverlayFeatureStates {
  final TopOverlayFeatureStateModel topOverlayFeatureStateModel;

  const TopOverlayFeatureStates(this.topOverlayFeatureStateModel);
}

class LoadingOverlayFeatureState extends TopOverlayFeatureStates {
  const LoadingOverlayFeatureState(super.topOverlayFeatureStateModel);
}

class LoadedOverlayFeatureState extends TopOverlayFeatureStates {
  const LoadedOverlayFeatureState(super.topOverlayFeatureStateModel);
}
