import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/models/video_category_models/video_category.dart';
import 'package:youtube/core/utils/extensions.dart';
import 'package:youtube/features/home_screen/bloc/cubits/video_category_cubit/main_video_category_cubit.dart';
import 'package:youtube/features/home_screen/bloc/home_screen_bloc_events.dart';
import 'package:youtube/features/home_screen/bloc/main_home_screen_bloc.dart';
import 'package:youtube/core/widgets/text_widget.dart';

class HomeScreenSelectTypeContentLoadedWidget extends StatelessWidget {
  final ScrollController? scrollController;
  final ValueChanged<VideoCategory> refresh;

  const HomeScreenSelectTypeContentLoadedWidget({
    super.key,
    this.scrollController,
    required this.refresh,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final mainHomeScreenState = context.watch<MainHomeScreenBloc>().state;

        final videoCategoriesStateModel = context.watch<MainVideoCategoryCubit>();
        final mainHomeScreenStateModel = mainHomeScreenState.homeScreenStateModel;

        final listOfCategory =
            videoCategoriesStateModel.state.videoCategories.limit<VideoCategory>(limit: 5);
        return SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 10, right: 10),
            separatorBuilder: (context, index) => const SizedBox(width: 15),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: listOfCategory.length,
            itemBuilder: (context, index) {
              final category = listOfCategory[index];
              return InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => context.read<MainHomeScreenBloc>().add(
                      SelectVideoCategoryEvent(
                        videoCategory: category,
                        scrollController: scrollController,
                        refresh: () {
                          refresh(category);
                        },
                      ),
                    ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                    color: mainHomeScreenStateModel.videoCategory?.id == category.id
                        ? Colors.red
                        : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Center(
                    child: TextWidget(
                      text: category.videoCategorySnippet?.title ?? '-',
                      size: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.9,
                      color: mainHomeScreenStateModel.videoCategory?.id == category.id
                          ? Colors.white
                          : Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
