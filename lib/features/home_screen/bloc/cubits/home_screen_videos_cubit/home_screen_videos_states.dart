import 'package:flutter/material.dart';

@immutable
sealed class HomeScreenVideosStates {}

final class LoadingHomeScreenVideosState extends HomeScreenVideosStates {}

final class ErrorHomeScreenVideosState extends HomeScreenVideosStates {}

final class LoadedHomeScreenVideosState extends HomeScreenVideosStates {}
