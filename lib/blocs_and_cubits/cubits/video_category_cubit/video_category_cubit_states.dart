import 'package:flutter/material.dart';

@immutable
abstract class VideoCategoryCubitStates {}

class LoadingVideoCategoryState extends VideoCategoryCubitStates {}

class ErrorVideoCategoryState extends VideoCategoryCubitStates {}

class LoadedVideoCategoryState extends VideoCategoryCubitStates {}
