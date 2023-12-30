import 'package:flutter/material.dart';

abstract class SearchScreenEvents {}

class InitSearchScreenEvent extends SearchScreenEvents {
  BuildContext context;

  InitSearchScreenEvent({required this.context});
}

class ClickSearchButtonEvent extends SearchScreenEvents {}

class PaginateSearchScreenEvent extends SearchScreenEvents {}
