import 'package:flutter/material.dart';
import 'package:youtube/core/youtube_data_api/models/order_by/order_by_details/order_by_time.dart';
import 'package:youtube/core/youtube_data_api/models/order_by/order_by_details/order_by_type.dart';

sealed class SearchScreenEvents {}

final class InitSearchScreenEvent extends SearchScreenEvents {
  final ScrollController? scrollController;
  final VoidCallback searchingBodyStateFunc;

  InitSearchScreenEvent({
    this.scrollController,
    required this.searchingBodyStateFunc,
  });
}

final class RequestToTextField extends SearchScreenEvents {}

final class ClearTextField extends SearchScreenEvents {
  final ScrollController? scrollController;
  final VoidCallback searchingBodyStateFunc;

  ClearTextField({this.scrollController, required this.searchingBodyStateFunc});
}

final class StartListeningSpeechEvent extends SearchScreenEvents {
  final VoidCallback popupFunc;
  final SearchScreenEventFunctionsHolder functionsHolder;

  StartListeningSpeechEvent({
    required this.popupFunc,
    required this.functionsHolder,
  });
}

final class StopListeningSpeechEvent extends SearchScreenEvents {
  final bool popup;
  final VoidCallback popupFunc;

  StopListeningSpeechEvent({required this.popup, required this.popupFunc});
}

final class ClickSearchButtonEvent extends SearchScreenEvents {
  final ScrollController? scrollController;
  final SearchScreenEventFunctionsHolder functionsHolder;

  ClickSearchButtonEvent({
    this.scrollController,
    required this.functionsHolder,
  });
}

final class ClickOnAlreadySearchedValueEvent extends SearchScreenEvents {
  final String value;
  final SearchScreenEventFunctionsHolder functionsHolder;

  ClickOnAlreadySearchedValueEvent({
    required this.value,
    required this.functionsHolder,
  });
}

final class PaginateSearchScreenEvent extends SearchScreenEvents {
  final SearchScreenEventFunctionsHolder functionsHolder;
  final bool isLoadedSearchBodyState;

  PaginateSearchScreenEvent({
    required this.functionsHolder,
    required this.isLoadedSearchBodyState,
  });
}

final class GetSuggestionRequestEvent extends SearchScreenEvents {
  final SearchScreenEventFunctionsHolder functionsHolder;

  GetSuggestionRequestEvent({required this.functionsHolder});
}

final class SelectOrderByTimeEvent extends SearchScreenEvents {
  OrderByTime orderByTime;

  SelectOrderByTimeEvent({required this.orderByTime});
}

final class SelectOrderByTypeEvent extends SearchScreenEvents {
  OrderByType orderByType;

  SelectOrderByTypeEvent({required this.orderByType});
}

final class StartCheckingPaginatingTimer extends SearchScreenEvents {
  final bool close;

  StartCheckingPaginatingTimer({this.close = false});
}

final class DeleteSearchedItemEvent extends SearchScreenEvents {
  final String item;

  DeleteSearchedItemEvent(this.item);
}

//
final class SearchScreenEventFunctionsHolder {
  final VoidCallback searchingBodyStateFunc;
  final VoidCallback errorSearchBodyStateFunc;
  final VoidCallback loadedSearchBodyStateFunc;
  final VoidCallback loadingSearchBodyStateFunc;
  final VoidCallback emitStateFunc;

  SearchScreenEventFunctionsHolder({
    required this.searchingBodyStateFunc,
    required this.errorSearchBodyStateFunc,
    required this.loadedSearchBodyStateFunc,
    required this.loadingSearchBodyStateFunc,
    required this.emitStateFunc,
  });
}
