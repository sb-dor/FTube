import 'package:flutter/material.dart';
import 'package:youtube/core/youtube_data_api/models/order_by/order_by_details/order_by_time.dart';
import 'package:youtube/core/youtube_data_api/models/order_by/order_by_details/order_by_type.dart';

abstract class SearchScreenEvents {}

class InitSearchScreenEvent extends SearchScreenEvents {
  BuildContext context;
  ScrollController? scrollController;

  InitSearchScreenEvent({
    required this.context,
    this.scrollController,
  });
}

class RequestToTextField extends SearchScreenEvents {}

class ClearTextField extends SearchScreenEvents {
  BuildContext context;
  ScrollController? scrollController;

  ClearTextField({
    required this.context,
    this.scrollController,
  });
}

class StartListeningSpeechEvent extends SearchScreenEvents {
  BuildContext context;

  StartListeningSpeechEvent({required this.context});
}

class StopListeningSpeechEvent extends SearchScreenEvents {
  bool popup;
  BuildContext context;

  StopListeningSpeechEvent({required this.popup, required this.context});
}

class ClickSearchButtonEvent extends SearchScreenEvents {
  BuildContext context;
  ScrollController? scrollController;

  ClickSearchButtonEvent({
    required this.context,
    this.scrollController,
  });
}

class ClickOnAlreadySearchedValueEvent extends SearchScreenEvents {
  String value;
  BuildContext context;

  ClickOnAlreadySearchedValueEvent({
    required this.value,
    required this.context,
  });
}

class PaginateSearchScreenEvent extends SearchScreenEvents {
  BuildContext context;

  PaginateSearchScreenEvent({required this.context});
}

class GetSuggestionRequestEvent extends SearchScreenEvents {
  BuildContext context;

  GetSuggestionRequestEvent({required this.context});
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
