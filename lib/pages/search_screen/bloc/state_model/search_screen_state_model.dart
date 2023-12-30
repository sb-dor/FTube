import 'package:flutter/material.dart';

class SearchScreenStateModel {
  List<String> searchData = [];

  TextEditingController searchController = TextEditingController(text: '');

  Future<void> initLastSearchData() async {}
}
