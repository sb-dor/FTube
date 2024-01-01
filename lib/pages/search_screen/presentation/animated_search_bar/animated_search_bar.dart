import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/search_screen/bloc/main_search_screen_bloc.dart';
import 'package:youtube/pages/search_screen/bloc/search_screen_events.dart';
import 'package:youtube/pages/search_screen/bloc/search_screen_states.dart';
import 'package:youtube/pages/search_screen/presentation/popups/voice_recording_popup.dart';
import 'package:youtube/utils/reusable_global_functions.dart';

class AnimatedSearchBar extends StatelessWidget {
  final AnimationController searchBarAnimationController;
  final Animation<double> searchBarAnimation;
  final ScrollController scrollController;

  const AnimatedSearchBar({
    Key? key,
    required this.searchBarAnimationController,
    required this.searchBarAnimation,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainSearchScreenBloc, SearchScreenStates>(builder: (context, state) {
      var currentState = state.searchScreenStateModel;
      return AnimatedBuilder(
          animation: searchBarAnimationController,
          builder: (context, child) {
            return Builder(
              builder: (context) => Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                // color: Colors.red,
                width: MediaQuery.of(context).size.width,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: MediaQuery.of(context).size.width * searchBarAnimation.value,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5,
                            color: Colors.grey.shade300,
                          )
                        ]),
                    child: Stack(
                      children: [
                        Row(children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.130,
                            height: MediaQuery.of(context).size.width * 0.130,
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
                                  controller: currentState.searchController,
                                  onSubmitted: (v) => context
                                      .read<MainSearchScreenBloc>()
                                      .add(ClickSearchButtonEvent(
                                        context: context,
                                        scrollController: scrollController,
                                      )),
                                  onTap: () => context
                                      .read<MainSearchScreenBloc>()
                                      .add(InitSearchScreenEvent(
                                        context: context,
                                        scrollController: scrollController,
                                      )),
                                  onChanged: (v) => context
                                      .read<MainSearchScreenBloc>()
                                      .add(GetSuggestionRequestEvent(context: context)),
                                  textInputAction: TextInputAction.search,
                                  decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: InputBorder.none,
                                      hintText: "Search"),
                                ),
                              ),
                            ),
                          ),
                        ]),
                        if (searchBarAnimationController.isCompleted)
                          if (currentState.searchController.text.isNotEmpty)
                            Positioned(
                                top: 0,
                                right: 10,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () =>
                                      context.read<MainSearchScreenBloc>().add(ClearTextField(
                                            context: context,
                                            scrollController: scrollController,
                                          )),
                                  child: Center(
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.close,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                          else
                            Positioned(
                                top: 0,
                                right: 10,
                                bottom: 0,
                                child: Material(
                                  child: GestureDetector(
                                    onTap: () {
                                      context
                                          .read<MainSearchScreenBloc>()
                                          .add(StartListeningSpeechEvent(context: context));
                                      VoiceRecordingPopup.voiceRecordingPopup(context);
                                    },
                                    child: Center(
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.keyboard_voice,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                        Positioned(
                            left: 0,
                            bottom: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.130,
                                  height: MediaQuery.of(context).size.width * 0.130,
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
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
    });
  }
}
