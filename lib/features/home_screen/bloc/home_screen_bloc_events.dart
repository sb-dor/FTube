import 'package:flutter/material.dart';
import 'package:youtube/core/models/video_category_models/video_category.dart';

sealed class HomeScreenBlocEvents {}

final class RefreshHomeScreenEvent extends HomeScreenBlocEvents {
  final VideoCategory? videoCategory;
  final ScrollController? scrollController;
  final bool refresh;

  final VoidCallback showBottomNavbar;
  final VoidCallback loadingHomeScreenVideosState;
  final VoidCallback errorHomeScreenVideosState;
  final VoidCallback loadedHomeScreenVideosState;
  final VoidCallback loadVideoCategory;

  final bool isLoadedHomeScreenVideos;
  final bool isErrorVideoCategoryState;

  RefreshHomeScreenEvent({
    this.videoCategory,
    this.scrollController,
    this.refresh = false,
    required this.showBottomNavbar,
    required this.loadingHomeScreenVideosState,
    required this.errorHomeScreenVideosState,
    required this.loadedHomeScreenVideosState,
    required this.loadVideoCategory,
    required this.isLoadedHomeScreenVideos,
    required this.isErrorVideoCategoryState,
  });
}

final class PaginateHomeScreenEvent extends HomeScreenBlocEvents {}

final class SelectVideoCategoryEvent extends HomeScreenBlocEvents {
  final VideoCategory? videoCategory;
  final VoidCallback refresh;
  final ScrollController? scrollController;

  SelectVideoCategoryEvent({
    required this.videoCategory,
    required this.refresh,
    this.scrollController,
  });
}
