import 'state_model/history_inner_screen_state_model.dart';

abstract class HistoryInnerScreenState {
  HistoryInnerScreenStateModel historyInnerScreenStateModel;

  HistoryInnerScreenState({
    required this.historyInnerScreenStateModel,
  });
}

class LoadingHistoryInnerScreen extends HistoryInnerScreenState {
  LoadingHistoryInnerScreen(HistoryInnerScreenStateModel historyInnerScreenStateModel)
      : super(historyInnerScreenStateModel: historyInnerScreenStateModel);
}

class ErrorHistoryInnerScreen extends HistoryInnerScreenState {
  ErrorHistoryInnerScreen(HistoryInnerScreenStateModel historyInnerScreenStateModel)
      : super(historyInnerScreenStateModel: historyInnerScreenStateModel);
}

class LoadedHistoryInnerScreen extends HistoryInnerScreenState {
  LoadedHistoryInnerScreen(HistoryInnerScreenStateModel historyInnerScreenStateModel)
      : super(historyInnerScreenStateModel: historyInnerScreenStateModel);
}
