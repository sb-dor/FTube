import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:youtube/models/video_modes/video.dart';
import 'package:youtube/pages/search_screen/bloc/cubits/search_body_cubit/search_body_cubit.dart';
import 'package:youtube/pages/search_screen/bloc/cubits/search_body_cubit/search_body_states.dart';
import 'package:youtube/pages/search_screen/bloc/state_model/search_screen_state_model.dart';
import 'package:youtube/pages/search_screen/data/source/rest_api_get_video_search.dart';

import 'search_screen_events.dart';
import 'search_screen_states.dart';

class MainSearchScreenBloc extends Bloc<SearchScreenEvents, SearchScreenStates> {
  late SearchScreenStateModel _currentState;

  MainSearchScreenBloc() : super(InitialSearchScreenState(SearchScreenStateModel())) {
    _currentState = state.searchScreenStateModel;
    //
    //

    on<InitSearchScreenEvent>(_initSearchScreenEvent);

    on<RequestToTextField>(_requestToTextField);

    on<ClearTextField>(_clearTextField);

    on<StartListeningSpeechEvent>(_startListeningSpeechEvent);

    on<StopListeningSpeechEvent>(_stopListeningSpeechEvent);

    on<ClickSearchButtonEvent>(_clickSearchButtonEvent);

    on<ClickOnAlreadySearchedValueEvent>(_clickOnAlreadySearchedValueEvent);

    on<PaginateSearchScreenEvent>(_paginateSearchScreenEvent);
  }

  void _initSearchScreenEvent(InitSearchScreenEvent event, Emitter<SearchScreenStates> emit) async {
    var searchBodyCubit = BlocProvider.of<SearchBodyCubit>(event.context);
    searchBodyCubit.searchingBodyState();
    _currentState.searchData = await _currentState.hiveDatabaseHelper.getSearchData();
    await _currentState.speechToText.initialize();
    event.scrollController?.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
    emit(InitialSearchScreenState(_currentState));
  }

  void _requestToTextField(RequestToTextField event, Emitter<SearchScreenStates> emit) =>
      _currentState.focusNode.requestFocus();

  void _clearTextField(ClearTextField event, Emitter<SearchScreenStates> emit) {
    var searchBodyCubit = BlocProvider.of<SearchBodyCubit>(event.context);
    _currentState.searchController.clear();
    _currentState.focusNode.requestFocus();
    searchBodyCubit.searchingBodyState();
    event.scrollController?.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
    emit(InitialSearchScreenState(_currentState));
  }

  void _startListeningSpeechEvent(
      StartListeningSpeechEvent event, Emitter<SearchScreenStates> emit) async {
    await _currentState.speechToText.listen(onResult: (SpeechRecognitionResult result) async {
      if (_currentState.timerForAutoClosingSpeech?.isActive ?? false) {
        _currentState.timerForAutoClosingSpeech?.cancel();
      }
      _currentState.timerForAutoClosingSpeech = Timer(const Duration(seconds: 1), () {
        add(StopListeningSpeechEvent(popup: true, context: event.context));
      });
      _currentState.searchController.text = result.recognizedWords;
    });
    emit(InitialSearchScreenState(_currentState));
  }

  void _stopListeningSpeechEvent(
      StopListeningSpeechEvent event, Emitter<SearchScreenStates> emit) async {
    if (event.popup) {
      Navigator.pop(event.context);
    }
    await _currentState.speechToText.stop();

    emit(InitialSearchScreenState(_currentState));
  }

  void _clickSearchButtonEvent(
      ClickSearchButtonEvent event, Emitter<SearchScreenStates> emit) async {
    var searchBodyCubit = BlocProvider.of<SearchBodyCubit>(event.context);
    try {
      event.scrollController?.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
      searchBodyCubit.loadingSearchBodyState();
      if (!_currentState.searchData
          .any((el) => el.trim() == _currentState.searchController.text.trim())) {
        _currentState.searchData.insert(0, _currentState.searchController.text.trim());
      }
      if (_currentState.searchData.length >= 30) _currentState.searchData.removeLast();
      await _currentState.hiveDatabaseHelper.saveSearchData(listOfSearch: _currentState.searchData);

      searchBodyCubit.loadingSearchBodyState();

      _currentState.clearData();

      var data = await RestApiGetVideoSearch.getSearchVideo(
        page: _currentState.pageToken,
        q: _currentState.searchController.text,
      );

      if (data.containsKey("server_error")) {
        searchBodyCubit.errorSearchBodyState();
      } else if (data.containsKey("success")) {
        _currentState.pageToken = data['next_page_token'];
        List<Video> videos = data['videos'];
        _currentState.addAndPag(value: videos);
        searchBodyCubit.loadedSearchBodyState();
        for (var element in videos) {
          await element.snippet?.loadSnippetData();
          searchBodyCubit.emitState();
        }
      } else {
        searchBodyCubit.errorSearchBodyState();
      }

      emit(InitialSearchScreenState(_currentState));
    } catch (e) {
      debugPrint("_clickSearchButtonEvent error is : $e");
    }
  }

  void _clickOnAlreadySearchedValueEvent(
      ClickOnAlreadySearchedValueEvent event, Emitter<SearchScreenStates> emit) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _currentState.searchController.text = event.value.trim();
    add(ClickSearchButtonEvent(context: event.context));
  }

  void _paginateSearchScreenEvent(
      PaginateSearchScreenEvent event, Emitter<SearchScreenStates> emit) async {
    if (!_currentState.hasMore) return;
    var searchBodyCubit = BlocProvider.of<SearchBodyCubit>(event.context);
    if (searchBodyCubit.state is! LoadedSearchBodyState) return;
    try {
      var data = await RestApiGetVideoSearch.getSearchVideo(
        page: _currentState.pageToken,
        q: _currentState.searchController.text,
      );

      if (data.containsKey("server_error")) {
        searchBodyCubit.errorSearchBodyState();
      } else if (data.containsKey("success")) {
        _currentState.pageToken = data['next_page_token'];
        List<Video> videos = data['videos'];
        _currentState.addAndPag(value: videos, paginate: true);
        searchBodyCubit.loadedSearchBodyState();
        for (var element in videos) {
          await element.snippet?.loadSnippetData();
          searchBodyCubit.emitState();
        }
      } else {
        searchBodyCubit.errorSearchBodyState();
      }
    } catch (e) {
      searchBodyCubit.errorSearchBodyState();
      debugPrint("_paginateSearchScreenEvent error is $e");
    }
  }
}
