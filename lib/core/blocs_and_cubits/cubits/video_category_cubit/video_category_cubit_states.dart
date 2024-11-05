import 'package:flutter/material.dart';
import 'package:youtube/core/models/video_category_models/video_category.dart';

@immutable
abstract final class VideoCategoryCubitStates {
  final List<VideoCategory> videoCategories;

  const VideoCategoryCubitStates(this.videoCategories);
}

final class LoadingVideoCategoryState extends VideoCategoryCubitStates {
  const LoadingVideoCategoryState(super.videoCategories);
}

final class ErrorVideoCategoryState extends VideoCategoryCubitStates {
  const ErrorVideoCategoryState(super.videoCategories);
}

final class LoadedVideoCategoryState extends VideoCategoryCubitStates {
  const LoadedVideoCategoryState(super.videoCategories);
}
