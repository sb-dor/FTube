import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/search_screen/bloc/cubits/search_body_cubit/search_body_cubit.dart';
import 'package:youtube/features/search_screen/bloc/cubits/search_body_cubit/search_body_states.dart';
import 'package:youtube/features/search_screen/bloc/main_search_screen_bloc.dart';
import 'package:youtube/features/search_screen/bloc/search_screen_events.dart';
import 'package:youtube/features/search_screen/presentation/pages/dialog_openers/open_search_screen_filter.dart';
import 'package:youtube/features/search_screen/presentation/pages/dialog_openers/voice_recording_popup.dart';

class AnimatedSearchBar extends StatelessWidget {
  final AnimationController searchBarAnimationController;
  final Animation<double> searchBarAnimation;
  final ScrollController scrollController;
  final SearchScreenEventFunctionsHolder functionsHolder;

  const AnimatedSearchBar({
    super.key,
    required this.searchBarAnimationController,
    required this.searchBarAnimation,
    required this.scrollController,
    required this.functionsHolder,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final currentState =
            context.watch<MainSearchScreenBloc>().state.searchScreenStateModel;
        final searchBodyCubit = context.watch<SearchBodyCubit>().state;
        return AnimatedBuilder(
          animation: searchBarAnimationController,
          builder: (context, child) {
            return Builder(
              builder:
                  (context) => Container(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    // color: Colors.red,
                    width: MediaQuery.of(context).size.width,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width:
                            MediaQuery.of(context).size.width *
                            searchBarAnimation.value,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5,
                              color: Colors.grey.shade300,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.130,
                                  height:
                                      MediaQuery.of(context).size.width * 0.130,
                                  decoration: BoxDecoration(
                                    // color: Colors.amber,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 60),
                                      child: TextField(
                                        style: const TextStyle(fontSize: 14),
                                        focusNode: currentState.focusNode,
                                        controller:
                                            currentState.searchController,
                                        onSubmitted:
                                            (v) => context
                                                .read<MainSearchScreenBloc>()
                                                .add(
                                                  ClickSearchButtonEvent(
                                                    functionsHolder:
                                                        functionsHolder,
                                                    scrollController:
                                                        scrollController,
                                                  ),
                                                ),
                                        onTap:
                                            () => context
                                                .read<MainSearchScreenBloc>()
                                                .add(
                                                  InitSearchScreenEvent(
                                                    scrollController:
                                                        scrollController,
                                                    searchingBodyStateFunc: () {
                                                      context
                                                          .read<
                                                            SearchBodyCubit
                                                          >()
                                                          .searchingBodyState();
                                                    },
                                                  ),
                                                ),
                                        onChanged:
                                            (v) => context
                                                .read<MainSearchScreenBloc>()
                                                .add(
                                                  GetSuggestionRequestEvent(
                                                    functionsHolder:
                                                        functionsHolder,
                                                  ),
                                                ),
                                        textInputAction: TextInputAction.search,
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                          hintText: "Search",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (searchBarAnimationController.isCompleted)
                              if (searchBodyCubit is LoadedSearchBodyState ||
                                  searchBodyCubit is LoadingSearchBodyState)
                                Positioned(
                                  top: 0,
                                  right: 10,
                                  bottom: 0,
                                  child: _EndButton(
                                    voidCallback:
                                        () async =>
                                            await OpenSearchScreenFilter.openSearchScreenFilter(
                                              context,
                                              functionsHolder,
                                            ),
                                    icon: Icons.filter_list,
                                  ),
                                )
                              else if (currentState
                                  .searchController
                                  .text
                                  .isNotEmpty)
                                Positioned(
                                  top: 0,
                                  right: 10,
                                  bottom: 0,
                                  child: _EndButton(
                                    voidCallback:
                                        () => context
                                            .read<MainSearchScreenBloc>()
                                            .add(
                                              ClearTextField(
                                                scrollController:
                                                    scrollController,
                                                searchingBodyStateFunc: () {
                                                  context
                                                      .read<SearchBodyCubit>()
                                                      .searchingBodyState();
                                                },
                                              ),
                                            ),
                                    icon: Icons.close,
                                  ),
                                )
                              else
                                Positioned(
                                  top: 0,
                                  right: 10,
                                  bottom: 0,
                                  child: Material(
                                    child: _EndButton(
                                      voidCallback: () async {
                                        context
                                            .read<MainSearchScreenBloc>()
                                            .add(
                                              StartListeningSpeechEvent(
                                                functionsHolder:
                                                    functionsHolder,
                                                popupFunc: () {
                                                  if (!context.mounted) return;
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            );
                                        await VoiceRecordingPopup.voiceRecordingPopup(
                                          context,
                                        );
                                      },
                                      icon: Icons.keyboard_voice,
                                    ),
                                  ),
                                ),
                            Positioned(
                              left: 0,
                              bottom: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Center(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.130,
                                    height:
                                        MediaQuery.of(context).size.width *
                                        0.130,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            );
          },
        );
      },
    );
  }
}

class _EndButton extends StatelessWidget {
  final VoidCallback voidCallback;
  final IconData icon;

  const _EndButton({required this.voidCallback, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: voidCallback,
      child: Center(
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(child: Icon(icon, size: 18)),
        ),
      ),
    );
  }
}
