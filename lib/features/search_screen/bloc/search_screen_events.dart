import 'package:flutter/material.dart';
import 'package:youtube/core/youtube_data_api/models/order_by/order_by_details/order_by_time.dart';
import 'package:youtube/core/youtube_data_api/models/order_by/order_by_details/order_by_type.dart';

abstract class SearchScreenEvents {}

class InitSearchScreenEvent extends SearchScreenEvents {
  final ScrollController? scrollController;
  final VoidCallback searchingBodyStateFunc;

  InitSearchScreenEvent({
    this.scrollController,
    required this.searchingBodyStateFunc,
  });
}

class RequestToTextField extends SearchScreenEvents {}

class ClearTextField extends SearchScreenEvents {
  final ScrollController? scrollController;
  final VoidCallback searchingBodyStateFunc;

  ClearTextField({
    this.scrollController,
    required this.searchingBodyStateFunc,
  });
}

class StartListeningSpeechEvent extends SearchScreenEvents {
  final VoidCallback popupFunc;
  final SearchScreenEventFunctionsHolder functionsHolder;

  StartListeningSpeechEvent({
    required this.popupFunc,
    required this.functionsHolder,
  });
}

class StopListeningSpeechEvent extends SearchScreenEvents {
  final bool popup;
  final VoidCallback popupFunc;

  StopListeningSpeechEvent({
    required this.popup,
    required this.popupFunc,
  });
}

class ClickSearchButtonEvent extends SearchScreenEvents {
  final ScrollController? scrollController;
  final SearchScreenEventFunctionsHolder functionsHolder;

  ClickSearchButtonEvent({
    this.scrollController,
    required this.functionsHolder,
  });
}

class ClickOnAlreadySearchedValueEvent extends SearchScreenEvents {
  final String value;
  final SearchScreenEventFunctionsHolder functionsHolder;

  ClickOnAlreadySearchedValueEvent({
    required this.value,
    required this.functionsHolder,
  });
}

class PaginateSearchScreenEvent extends SearchScreenEvents {
  final SearchScreenEventFunctionsHolder functionsHolder;
  final bool isLoadedSearchBodyState;

  PaginateSearchScreenEvent({
    required this.functionsHolder,
    required this.isLoadedSearchBodyState,
  });
}

class GetSuggestionRequestEvent extends SearchScreenEvents {
  final SearchScreenEventFunctionsHolder functionsHolder;

  GetSuggestionRequestEvent({
    required this.functionsHolder,
  });
}

class SelectOrderByTimeEvent extends SearchScreenEvents {
  OrderByTime orderByTime;

  SelectOrderByTimeEvent({required this.orderByTime});
}

class SelectOrderByTypeEvent extends SearchScreenEvents {
  OrderByType orderByType;

  SelectOrderByTypeEvent({required this.orderByType});
}

class StartCheckingPaginatingTimer extends SearchScreenEvents {
  final bool close;

  StartCheckingPaginatingTimer({this.close = false});
}

class DeleteSearchedItemEvent extends SearchScreenEvents {
  final String item;

  DeleteSearchedItemEvent(this.item);
}

//
class SearchScreenEventFunctionsHolder {
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
