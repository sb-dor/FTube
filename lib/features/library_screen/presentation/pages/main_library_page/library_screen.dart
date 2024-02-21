import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:youtube/features/library_screen/presentation/pages/main_library_page/widgets/history_widgets/error_history_widget.dart';
import 'package:youtube/features/library_screen/presentation/pages/main_library_page/widgets/history_widgets/loaded_history_widget.dart';
import 'package:youtube/features/library_screen/presentation/pages/main_library_page/widgets/history_widgets/loading_history_widget.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final historyBloc = context.watch<HistoryBloc>();

        // data
        final historyStateModel = historyBloc.state.historyStateModel;
        return Scaffold(
          body: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (historyBloc.state is LoadingHistoryState)
                const LoadingHistoryWidget()
              else if (historyBloc.state is ErrorHistoryState)
                const ErrorHistoryWidget()
              else if (historyBloc.state is LoadedHistoryState && historyStateModel.videos.isEmpty)
                const SizedBox()
              else
                const LoadedHistoryWidget()
            ],
          ),
        );
      },
    );
  }
}
