import 'state_model/history_inner_screen_state_model.dart';

sealed class HistoryInnerScreenState {
  HistoryInnerScreenStateModel historyInnerScreenStateModel;

  HistoryInnerScreenState({
    required this.historyInnerScreenStateModel,
  });
}

final class LoadingHistoryInnerScreen extends HistoryInnerScreenState {
  LoadingHistoryInnerScreen(HistoryInnerScreenStateModel historyInnerScreenStateModel)
      : super(historyInnerScreenStateModel: historyInnerScreenStateModel);
}

final class ErrorHistoryInnerScreen extends HistoryInnerScreenState {
  ErrorHistoryInnerScreen(HistoryInnerScreenStateModel historyInnerScreenStateModel)
      : super(historyInnerScreenStateModel: historyInnerScreenStateModel);
}

final class LoadedHistoryInnerScreen extends HistoryInnerScreenState {
  LoadedHistoryInnerScreen(HistoryInnerScreenStateModel historyInnerScreenStateModel)
      : super(historyInnerScreenStateModel: historyInnerScreenStateModel);
}
