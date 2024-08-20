import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:youtube/core/api/api_get_data/rest_api_get_video_data.dart';
import 'package:youtube/features/search_screen/data/source/rest_api_get_suggestion_text.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube/utils/regex_helper/regex_helper.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';
import 'package:youtube/youtube_data_api/models/video.dart' as ytv;
import 'package:youtube/youtube_data_api/models/video_data.dart' as ytvdata;
import 'cubits/search_body_cubit/search_body_cubit.dart';
import 'cubits/search_body_cubit/search_body_states.dart';
import 'search_screen_events.dart';
import 'search_screen_states.dart';
import 'state_model/search_screen_state_model.dart';

class MainSearchScreenBloc extends Bloc<SearchScreenEvents, SearchScreenStates> with RegexHelper {
  late SearchScreenStateModel _currentState;

  MainSearchScreenBloc() : super(InitialSearchScreenState(SearchScreenStateModel())) {
    _currentState = state.searchScreenStateModel;
    //
    //
    on<StartCheckingPaginatingTimer>(_startCheckingPaginatingTimer);
    //

    on<InitSearchScreenEvent>(_initSearchScreenEvent);

    on<RequestToTextField>(_requestToTextField);

    on<ClearTextField>(_clearTextField);

    on<StartListeningSpeechEvent>(_startListeningSpeechEvent);

    on<StopListeningSpeechEvent>(_stopListeningSpeechEvent);

    on<ClickSearchButtonEvent>(_clickSearchButtonEvent);

    on<ClickOnAlreadySearchedValueEvent>(_clickOnAlreadySearchedValueEvent);

    on<PaginateSearchScreenEvent>(_paginateSearchScreenEvent);

    on<GetSuggestionRequestEvent>(_getSuggestionRequestEvent);

    //
    on<SelectOrderByTimeEvent>(_selectOrderByTimeEvent);

    on<SelectOrderByTypeEvent>(_selectOrderByTypeEvent);
  }

  //

  void _startCheckingPaginatingTimer(
    StartCheckingPaginatingTimer event,
    Emitter<SearchScreenStates> emit,
  ) async {
    _currentState.timerForCheckingPaginating?.cancel();

    if (event.close) return;

    _currentState.timerForCheckingPaginating = Timer.periodic(const Duration(seconds: 20), (timer) {
      var searchBodyCubit = BlocProvider.of<SearchBodyCubit>(
          _currentState.globalContext.globalNavigatorContext.currentContext!);
      if (_currentState.paginating && searchBodyCubit.state is LoadedSearchBodyState) {
        _currentState.paginating = false;
      }
      debugPrint("working here buddy for timer: ${_currentState.paginating}");
    });
  }

  //

  void _initSearchScreenEvent(InitSearchScreenEvent event, Emitter<SearchScreenStates> emit) async {
    var searchBodyCubit = BlocProvider.of<SearchBodyCubit>(event.context);
    _currentState.suggestData.clear();
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
    _currentState.suggestData.clear();
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
        add(GetSuggestionRequestEvent(context: event.context));
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
    ClickSearchButtonEvent event,
    Emitter<SearchScreenStates> emit,
  ) async {
    var searchBodyCubit = BlocProvider.of<SearchBodyCubit>(event.context);
    try {
      if (_currentState.searchController.text.trim().isEmpty) return;

      event.scrollController?.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
      searchBodyCubit.loadingSearchBodyState();

      _currentState.searchData.removeWhere(
        (el) => el.trim().toLowerCase() == _currentState.searchController.text.trim().toLowerCase(),
      );

      _currentState.searchData.insert(0, _currentState.searchController.text.trim());

      if (_currentState.searchData.length >= 30) _currentState.searchData.removeLast();

      await _currentState.hiveDatabaseHelper.saveSearchData(listOfSearch: _currentState.searchData);

      searchBodyCubit.loadingSearchBodyState();

      _currentState.clearData();

      if (_currentState.searchController.text.trim().contains("https")) {
        final extractIdFromUrl = videoId(_currentState.searchController.text.trim());
        if (extractIdFromUrl.isNotEmpty) {
          final searchById = await RestApiGetVideoData.getVideoInfo(
            videoContent: TypeContent.snippet,
            videoId: extractIdFromUrl,
          );
          if (searchById.containsKey("server_error")) {
            searchBodyCubit.errorSearchBodyState();
          } else if (searchById.containsKey("success") && searchById["success"] == true) {
            ytvdata.VideoData videoData = searchById['item'] as ytvdata.VideoData;
            // videoData.video.;
            ytv.Video videoFromVideoData = ytv.Video(
              videoId: videoData.video?.videoId,
              title: videoData.video?.title,
              videoData: videoData,
              views: videoData.video?.viewCount,
              channelName: videoData.video?.channelName,
              channelThumbnailUrl: videoData.video?.channelThumb,

            );

            videoData.videosList.insert(0, videoFromVideoData);

            _currentState.addAndPag(value: videoData.videosList);

            searchBodyCubit.loadedSearchBodyState();
          } else {
            searchBodyCubit.errorSearchBodyState();
          }
        }
        //
      } else {
        var data = await RestApiGetVideoData.getSearchVideo(
          q: _currentState.searchController.text,
          refresh: true,
          orderBy: _currentState.orderBy?.id,
        );

        if (data.containsKey("server_error")) {
          searchBodyCubit.errorSearchBodyState();
        } else if (data.containsKey("success")) {
          List<ytv.Video> videos = data['videos'];

          _currentState.addAndPag(value: videos);

          searchBodyCubit.loadedSearchBodyState();

          // _getVideoDataInAnotherIsolate(videos, searchBodyCubit);
        } else {
          searchBodyCubit.errorSearchBodyState();
        }
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
    if (_currentState.paginating) return;
    _currentState.paginating = true;
    var searchBodyCubit = BlocProvider.of<SearchBodyCubit>(event.context);
    if (searchBodyCubit.state is! LoadedSearchBodyState) return;
    try {
      var data = await RestApiGetVideoData.getSearchVideo(
        q: _currentState.searchController.text,
      );

      _currentState.paginating = false;

      if (data.containsKey("server_error")) {
        searchBodyCubit.errorSearchBodyState();
      } else if (data.containsKey("success")) {
        // _currentState.pageToken = data['next_page_token'];
        List<ytv.Video> videos = data['videos'];
        _currentState.addAndPag(value: videos, paginate: true);
        searchBodyCubit.loadedSearchBodyState();
        // _getVideoDataInAnotherIsolate(videos, searchBodyCubit);
      } else {
        searchBodyCubit.errorSearchBodyState();
      }
    } catch (e) {
      searchBodyCubit.errorSearchBodyState();
      debugPrint("_paginateSearchScreenEvent error is $e");
    }
  }

  void _getSuggestionRequestEvent(
      GetSuggestionRequestEvent event, Emitter<SearchScreenStates> emit) async {
    var searchBodyCubit = BlocProvider.of<SearchBodyCubit>(event.context);

    if (_currentState.searchController.text.isEmpty) {
      _currentState.suggestData.clear();
      searchBodyCubit.searchingBodyState();
    } else {
      // if (_currentState.timerForMakingSuggestionRequest?.isActive ?? false) {
      //   _currentState.timerForMakingSuggestionRequest?.cancel();
      // }

      // _currentState.timerForMakingSuggestionRequest = Timer(const Duration(seconds: 1), () async {
      var data =
          await RestApiGetSuggestionText.getSuggestionSearch(_currentState.searchController.text);
      if (data.containsKey('server_error')) {
        searchBodyCubit.errorSearchBodyState();
      } else if (data.containsKey('success')) {
        _currentState.suggestData = data['data'];
        searchBodyCubit.emitState();
      } else {
        searchBodyCubit.errorSearchBodyState();
      }
      // });
    }
    emit(InitialSearchScreenState(_currentState));
  }

  void _selectOrderByTimeEvent(SelectOrderByTimeEvent event, Emitter<SearchScreenStates> emit) {
    _currentState.setOrderBy(time: event.orderByTime);
    emit(InitialSearchScreenState(_currentState));
  }

  void _selectOrderByTypeEvent(SelectOrderByTypeEvent event, Emitter<SearchScreenStates> emit) {
    _currentState.setOrderBy(type: event.orderByType);
    emit(InitialSearchScreenState(_currentState));
  }

  ///
  ///
  ///
  /// [run isolate here]
  static void _getVideoDataInAnotherIsolate(
    List<ytv.Video> list,
    SearchBodyCubit searchBodyCubit,
  ) async {
    //
    Map<String, dynamic> sendingList = {
      "list": list.map((e) => e.toJson()).toList(),
    };

    var toStringing = jsonEncode(sendingList);

    final rp = ReceivePort();

    Isolate.spawn(_isolate, rp.sendPort);

    final broadcastRp = rp.asBroadcastStream();

    final SendPort communicatorSendPort = await broadcastRp.first;

    communicatorSendPort.send(toStringing);

    broadcastRp.listen((message) {
      ytvdata.VideoData? videoData;
      if (message != null) videoData = ytvdata.VideoData.fromJson(message);
      for (var each in list) {
        if (each.videoId == videoData?.video?.videoId) {
          each.loadingVideoData = false;
          each.videoData = videoData?.clone();
        }
      }
      searchBodyCubit.emitState();
      // rp.close();
    });
  }

  static void _isolate(SendPort sendPort) async {
    final rp = ReceivePort();
    sendPort.send(rp.sendPort);

    final messages = rp.takeWhile((element) => element is String).cast<String>();

    initYoutubeDataApi();

    await for (var each in messages) {
      Map<String, dynamic> json = jsonDecode(each);

      List<dynamic> comingList = [];
      if (json['list'] != null) {
        comingList = json['list'];
      }

      List<ytv.Video> videos = comingList.map((e) => ytv.Video.fromIsolate(e)).toList();

      await Future.wait(videos
          .map((e) => e.getVideoData().then((_) {
                sendPort.send(e.videoData?.toJson());
              }))
          .toList());
    }

    // rp.close();
  }
}
