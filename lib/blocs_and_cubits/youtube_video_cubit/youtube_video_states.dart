import 'package:flutter/material.dart';

@immutable
abstract class YoutubeVideoStates {}

class InitialYoutubeVideoState extends YoutubeVideoStates {}

class ErrorYoutubeVideoState extends YoutubeVideoStates {}
