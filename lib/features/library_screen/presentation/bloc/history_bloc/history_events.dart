part of 'history_bloc.dart';

abstract class HistoryEvents {}

class GetHistoryEvent extends HistoryEvents {}

class PaginateHistoryEvent extends HistoryEvents {}

class AddOnHistoryEvent extends HistoryEvents {
  Video? video;

  AddOnHistoryEvent({required this.video});
}
