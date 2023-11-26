import 'package:flutter/material.dart';

@immutable
abstract class HomeScreenVideosStates {}

class LoadingHomeScreenVideosState extends HomeScreenVideosStates {}

class ErrorHomeScreenVideosState extends HomeScreenVideosStates {}

class LoadedHomeScreenVideosState extends HomeScreenVideosStates {}
