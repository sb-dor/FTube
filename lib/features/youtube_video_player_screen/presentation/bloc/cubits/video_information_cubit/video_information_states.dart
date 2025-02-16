import 'package:flutter/material.dart';

@immutable
sealed class VideoInformationStates {}

final class LoadingVideoInformationState extends VideoInformationStates {}

final class ErrorVideoInformationState extends VideoInformationStates {}

final class LoadedVideoInformationState extends VideoInformationStates {}
