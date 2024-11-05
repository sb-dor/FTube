import 'package:flutter/material.dart';

@immutable
abstract class VideoInformationStates {}

class LoadingVideoInformationState extends VideoInformationStates {}

class ErrorVideoInformationState extends VideoInformationStates {}

class LoadedVideoInformationState extends VideoInformationStates {}
