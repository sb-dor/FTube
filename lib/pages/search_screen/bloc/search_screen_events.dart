import 'package:flutter/material.dart';

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
