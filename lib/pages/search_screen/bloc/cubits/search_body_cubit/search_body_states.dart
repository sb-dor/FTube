import 'package:flutter/material.dart';

@immutable
abstract class SearchBodyStates {}

// for typing
class SearchingBodyState extends SearchBodyStates {}

//while finished typing, for showing shimmer
class LoadingSearchBodyState extends SearchBodyStates {}

// if code will throw an error
class ErrorSearchBodyState extends SearchBodyStates {}

// loaded state which means search was successfully ended
class LoadedSearchBodyState extends SearchBodyStates {}
