import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/core/utils/hive_database_helper/hive_database_helper.dart';
import 'package:youtube/core/utils/regex_helper/regex_helper.dart';
import 'package:youtube/core/youtube_data_api/models/thumbnail.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart' as ytv;
import 'package:youtube/core/youtube_data_api/models/video_data.dart' as ytvdata;
import 'package:youtube/features/search_screen/domain/repo/search_screen_repo.dart';
import 'cubits/search_body_cubit/search_body_cubit.dart';
import 'cubits/search_body_cubit/search_body_states.dart';
import 'search_screen_events.dart';
import 'search_screen_states.dart';
import 'state_model/search_screen_state_model.dart';

class MainSearchScreenBloc extends Bloc<SearchScreenEvents, SearchScreenStates> with RegexHelper {
  final HiveDatabaseHelper _hiveDatabaseHelper;
  final SearchScreenRepo _screenRepo;

  late final SearchScreenStateModel _currentState;

  MainSearchScreenBloc({
    required SearchScreenRepo screenRepo,
    required HiveDatabaseHelper hiveDatabaseHelper,
  }) : _screenRepo = screenRepo,
       _hiveDatabaseHelper = hiveDatabaseHelper,
       super(InitialSearchScreenState(SearchScreenStateModel())) {
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

    //
    on<DeleteSearchedItemEvent>(_deleteSearchedItemEvent);
  }

  //

  void _startCheckingPaginatingTimer(
    StartCheckingPaginatingTimer event,
    Emitter<SearchScreenStates> emit,
  ) async {
    _currentState.timerForCheckingPaginating?.cancel();

    if (event.close) return;

    _currentState.timerForCheckingPaginating = Timer.periodic(const Duration(seconds: 20), (timer) {
      final searchBodyCubit = BlocProvider.of<SearchBodyCubit>(
        _currentState.globalContext.globalNavigatorContext.currentContext!,
      );
      if (_currentState.paginating && searchBodyCubit.state is LoadedSearchBodyState) {
        _currentState.paginating = false;
      }
      // debugPrint"working here buddy for timer: ${_currentState.paginating}");
    });
  }

  //

  void _initSearchScreenEvent(InitSearchScreenEvent event, Emitter<SearchScreenStates> emit) async {
    _currentState.suggestData.clear();
    event.searchingBodyStateFunc();
    _currentState.searchData = await _hiveDatabaseHelper.getSearchData();
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
    _currentState.suggestData.clear();
    _currentState.searchController.clear();
    _currentState.focusNode.requestFocus();
    event.searchingBodyStateFunc();
    event.scrollController?.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
    );
    emit(InitialSearchScreenState(_currentState));
  }

  void _startListeningSpeechEvent(
    StartListeningSpeechEvent event,
    Emitter<SearchScreenStates> emit,
  ) async {
    await _currentState.speechToText.listen(
      onResult: (SpeechRecognitionResult result) async {
        if (_currentState.timerForAutoClosingSpeech?.isActive ?? false) {
          _currentState.timerForAutoClosingSpeech?.cancel();
        }
        _currentState.timerForAutoClosingSpeech = Timer(const Duration(seconds: 1), () {
          add(
            GetSuggestionRequestEvent(
              functionsHolder: SearchScreenEventFunctionsHolder(
                searchingBodyStateFunc: () {
                  event.functionsHolder.searchingBodyStateFunc();
                },
                errorSearchBodyStateFunc: () {
                  event.functionsHolder.errorSearchBodyStateFunc();
                },
                emitStateFunc: () {
                  event.functionsHolder.emitStateFunc();
                },
                loadedSearchBodyStateFunc: () {},
                loadingSearchBodyStateFunc: () {},
              ),
            ),
          );
          add(StopListeningSpeechEvent(popup: true, popupFunc: event.popupFunc));
        });
        _currentState.searchController.text = result.recognizedWords;
      },
    );
    emit(InitialSearchScreenState(_currentState));
  }

  void _stopListeningSpeechEvent(
    StopListeningSpeechEvent event,
    Emitter<SearchScreenStates> emit,
  ) async {
    if (event.popup) {
      event.popupFunc();
    }
    await _currentState.speechToText.stop();

    emit(InitialSearchScreenState(_currentState));
  }

  void _clickSearchButtonEvent(
    ClickSearchButtonEvent event,
    Emitter<SearchScreenStates> emit,
  ) async {
    // var searchBodyCubit = BlocProvider.of<SearchBodyCubit>(event.context);
    // debugPrint"calling here again");
    try {
      if (_currentState.searchController.text.trim().isEmpty) return;

      if (_currentState.lastSavedQuery?.trim() == _currentState.searchController.text.trim()) {
        event.functionsHolder.loadedSearchBodyStateFunc();
        return;
      }

      _currentState.lastSavedQuery = _currentState.searchController.text.trim();

      event.scrollController?.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
      event.functionsHolder.loadingSearchBodyStateFunc();

      _currentState.searchData.removeWhere(
        (el) => el.trim().toLowerCase() == _currentState.searchController.text.trim().toLowerCase(),
      );

      _currentState.searchData.insert(0, _currentState.searchController.text.trim());

      if (_currentState.searchData.length >= 30) {
        _currentState.searchData.removeLast();
      }

      await _hiveDatabaseHelper.saveSearchData(listOfSearch: _currentState.searchData);

      event.functionsHolder.loadingSearchBodyStateFunc();

      _currentState.clearData();

      if (_currentState.searchController.text.trim().contains("https")) {
        final extractIdFromUrl = videoId(_currentState.searchController.text.trim());
        if (extractIdFromUrl.isNotEmpty) {
          final searchById = await _screenRepo.getVideoInfo(
            videoContent: TypeContent.snippet,
            videoId: extractIdFromUrl,
          );
          if (searchById.containsKey("server_error")) {
            event.functionsHolder.errorSearchBodyStateFunc();
          } else if (searchById.containsKey("success") && searchById["success"] == true) {
            final ytvdata.VideoData videoData = searchById['item'] as ytvdata.VideoData;
            // videoData.video.;
            final ytv.Video videoFromVideoData = ytv.Video(
              videoId: videoData.video?.videoId,
              title: videoData.video?.title,
              videoData: videoData,
              views: videoData.video?.viewCount,
              channelName: videoData.video?.channelName,
              channelThumbnailUrl: videoData.video?.channelThumb,
              // duration: videoData.video.,
              thumbnails: [Thumbnail(url: videoData.video?.videoThumb)],
              publishedDateTime: videoData.video?.date,
              duration: videoData.video?.videoDuration,
            );

            // debugPrint"image of video is: ${videoFromVideoData.duration}");

            videoData.videosList.insert(0, videoFromVideoData);

            _currentState.addAndPag(value: videoData.videosList);

            event.functionsHolder.loadedSearchBodyStateFunc();
          } else {
            event.functionsHolder.errorSearchBodyStateFunc();
          }
        }
        //
      } else {
        final data = await _screenRepo.getSearchVideo(
          q: _currentState.searchController.text,
          refresh: true,
          orderBy: _currentState.orderBy?.id,
        );

        if (data.containsKey("server_error")) {
          event.functionsHolder.errorSearchBodyStateFunc();
        } else if (data.containsKey("success")) {
          final List<ytv.Video> videos = data['videos'];

          _currentState.addAndPag(value: videos);

          event.functionsHolder.loadedSearchBodyStateFunc();

          // _getVideoDataInAnotherIsolate(videos, searchBodyCubit);
        } else {
          event.functionsHolder.errorSearchBodyStateFunc();
        }
      }

      emit(InitialSearchScreenState(_currentState));
    } catch (e) {
      // debugPrint"_clickSearchButtonEvent error is : $e");
    }
  }

  void _clickOnAlreadySearchedValueEvent(
    ClickOnAlreadySearchedValueEvent event,
    Emitter<SearchScreenStates> emit,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _currentState.searchController.text = event.value.trim();
    add(ClickSearchButtonEvent(functionsHolder: event.functionsHolder));
  }

  void _paginateSearchScreenEvent(
    PaginateSearchScreenEvent event,
    Emitter<SearchScreenStates> emit,
  ) async {
    if (!_currentState.hasMore) return;
    if (_currentState.paginating) return;
    _currentState.paginating = true;
    // var searchBodyCubit = BlocProvider.of<SearchBodyCubit>(event.context);
    if (event.isLoadedSearchBodyState) return;
    try {
      final data = await _screenRepo.getSearchVideo(q: _currentState.searchController.text);

      _currentState.paginating = false;

      if (data.containsKey("server_error")) {
        event.functionsHolder.errorSearchBodyStateFunc();
      } else if (data.containsKey("success")) {
        // _currentState.pageToken = data['next_page_token'];
        final List<ytv.Video> videos = data['videos'];
        _currentState.addAndPag(value: videos, paginate: true);
        event.functionsHolder.loadedSearchBodyStateFunc();
        // _getVideoDataInAnotherIsolate(videos, searchBodyCubit);
      } else {
        event.functionsHolder.errorSearchBodyStateFunc();
      }
    } catch (e) {
      event.functionsHolder.errorSearchBodyStateFunc();
      // debugPrint"_paginateSearchScreenEvent error is $e");
    }
  }

  void _getSuggestionRequestEvent(
    GetSuggestionRequestEvent event,
    Emitter<SearchScreenStates> emit,
  ) async {
    // var searchBodyCubit = BlocProvider.of<SearchBodyCubit>(event.context);

    if (_currentState.searchController.text.isEmpty) {
      _currentState.suggestData.clear();
      event.functionsHolder.searchingBodyStateFunc();
    } else {
      // if (_currentState.timerForMakingSuggestionRequest?.isActive ?? false) {
      //   _currentState.timerForMakingSuggestionRequest?.cancel();
      // }

      // _currentState.timerForMakingSuggestionRequest = Timer(const Duration(seconds: 1), () async {
      final data = await _screenRepo.getSuggestionSearch(_currentState.searchController.text);
      if (data.containsKey('server_error')) {
        event.functionsHolder.errorSearchBodyStateFunc();
      } else if (data.containsKey('success')) {
        _currentState.suggestData = data['data'];
        event.functionsHolder.emitStateFunc();
      } else {
        event.functionsHolder.errorSearchBodyStateFunc();
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

  //
  void _deleteSearchedItemEvent(
    DeleteSearchedItemEvent event,
    Emitter<SearchScreenStates> emit,
  ) async {
    _currentState.searchData.removeWhere((e) => e.trim() == event.item.trim());
    await _hiveDatabaseHelper.saveSearchData(listOfSearch: _currentState.searchData);
    emit(InitialSearchScreenState(_currentState));
  }

  ///
  ///
  ///
  /// [run isolate here]
  // static void _getVideoDataInAnotherIsolate(
  //   List<ytv.Video> list,
  //   SearchBodyCubit searchBodyCubit,
  // ) async {
  //   //
  //   Map<String, dynamic> sendingList = {
  //     "list": list.map((e) => e.toJson()).toList(),
  //   };
  //
  //   var toStringing = jsonEncode(sendingList);
  //
  //   final rp = ReceivePort();
  //
  //   Isolate.spawn(_isolate, rp.sendPort);
  //
  //   final broadcastRp = rp.asBroadcastStream();
  //
  //   final SendPort communicatorSendPort = await broadcastRp.first;
  //
  //   communicatorSendPort.send(toStringing);
  //
  //   broadcastRp.listen((message) {
  //     ytvdata.VideoData? videoData;
  //     if (message != null) videoData = ytvdata.VideoData.fromJson(message);
  //     for (var each in list) {
  //       if (each.videoId == videoData?.video?.videoId) {
  //         each.loadingVideoData = false;
  //         each.videoData = videoData?.clone();
  //       }
  //     }
  //     searchBodyCubit._emitState();
  //     // rp.close();
  //   });
  // }
  //
  // static void _isolate(SendPort sendPort) async {
  //   final rp = ReceivePort();
  //   sendPort.send(rp.sendPort);
  //
  //   final messages = rp.takeWhile((element) => element is String).cast<String>();
  //
  //   initYoutubeDataApi();
  //
  //   await for (var each in messages) {
  //     Map<String, dynamic> json = jsonDecode(each);
  //
  //     List<dynamic> comingList = [];
  //     if (json['list'] != null) {
  //       comingList = json['list'];
  //     }
  //
  //     List<ytv.Video> videos = comingList.map((e) => ytv.Video.fromIsolate(e)).toList();
  //
  //     await Future.wait(videos
  //         .map((e) => e.getVideoData().then((_) {
  //               sendPort.send(e.videoData?.toJson());
  //             }))
  //         .toList());
  //   }
  //
  //   // rp.close();
  // }
}
