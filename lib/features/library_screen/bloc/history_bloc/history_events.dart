part of 'history_bloc.dart';

sealed class HistoryEvents {}

final class GetHistoryEvent extends HistoryEvents {}

final class PaginateHistoryEvent extends HistoryEvents {}

final class AddOnHistoryEvent extends HistoryEvents {
  Video? video;

  AddOnHistoryEvent({required this.video});
}

final class InitLengthOfDownloadedFiles extends HistoryEvents {}
