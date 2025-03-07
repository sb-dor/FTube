part of 'history_bloc.dart';

sealed class HistoryStates {
  HistoryStateModel historyStateModel;

  HistoryStates({required this.historyStateModel});
}

final class LoadingHistoryState extends HistoryStates {
  LoadingHistoryState(HistoryStateModel historyStateModel)
    : super(historyStateModel: historyStateModel);
}

final class ErrorHistoryState extends HistoryStates {
  String message;

  ErrorHistoryState(this.message, HistoryStateModel historyStateModel)
    : super(historyStateModel: historyStateModel);
}

final class LoadedHistoryState extends HistoryStates {
  LoadedHistoryState(HistoryStateModel historyStateModel)
    : super(historyStateModel: historyStateModel);
}
