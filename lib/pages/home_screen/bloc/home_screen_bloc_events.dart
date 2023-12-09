import 'package:flutter/material.dart';
import 'package:youtube/models/video_category_models/video_category.dart';

abstract class HomeScreenBlocEvents {}

class RefreshHomeScreenEvent extends HomeScreenBlocEvents {
  BuildContext context;
  VideoCategory? videoCategory;

  RefreshHomeScreenEvent({required this.context, this.videoCategory});
}

class PaginateHomeScreenEvent extends HomeScreenBlocEvents {}

class SelectVideoCategoryEvent extends HomeScreenBlocEvents {
  VideoCategory? videoCategory;
  BuildContext context;

  SelectVideoCategoryEvent({required this.videoCategory, required this.context});
}
