import 'dart:async';
import 'package:flutter/material.dart';

class MainScreenOverlayStateModel {
  OverlayEntry? overlay;

  Timer? timerForShowingPopButton;

  bool showPopButton = false, canUserScroll = false;
}
