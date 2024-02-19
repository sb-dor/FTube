part of 'history_bloc.dart';

abstract class HistoryStates {
  HistoryStateModel historyStateModel;

  HistoryStates({required this.historyStateModel});
}

class LoadingHistoryState extends HistoryStates {
  LoadingHistoryState(HistoryStateModel historyStateModel)
      : super(historyStateModel: historyStateModel);
}

class ErrorHistoryState extends HistoryStates {
  String message;

  ErrorHistoryState(this.message, HistoryStateModel historyStateModel)
      : super(historyStateModel: historyStateModel);
}

class LoadedHistoryState extends HistoryStates {
  LoadedHistoryState(HistoryStateModel historyStateModel)
      : super(historyStateModel: historyStateModel);
}
