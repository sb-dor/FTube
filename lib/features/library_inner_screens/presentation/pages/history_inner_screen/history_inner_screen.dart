import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/widgets/history_inner_screen_widgets/history_inner_screen_error_widget.dart';
import 'package:youtube/core/widgets/history_inner_screen_widgets/history_inner_screen_loaded_widget.dart';
import 'package:youtube/core/widgets/history_inner_screen_widgets/history_inner_screen_loading_widget.dart';
import 'package:youtube/features/library_inner_screens/blocs/history_inner_screen_bloc/history_inner_screen_bloc.dart';
import 'package:youtube/features/library_inner_screens/blocs/history_inner_screen_bloc/history_inner_screen_event.dart';
import 'package:youtube/features/library_inner_screens/blocs/history_inner_screen_bloc/history_inner_screen_state.dart';

class HistoryInnerScreen extends StatefulWidget {
  const HistoryInnerScreen({super.key});

  @override
  State<HistoryInnerScreen> createState() => _HistoryInnerScreenState();
}

class _HistoryInnerScreenState extends State<HistoryInnerScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HistoryInnerScreenBloc>().add(RefreshHistoryInnerScreenEvent());

    _scrollController.addListener(() {
      if (_scrollController.offset == _scrollController.position.maxScrollExtent) {
        context.read<HistoryInnerScreenBloc>().add(PaginateHistoryInnerScreenEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final historyInnerScreenBloc = context.watch<HistoryInnerScreenBloc>();

      // data

      final historyInnerScreenStateModel =
          historyInnerScreenBloc.state.historyInnerScreenStateModel;

      return Scaffold(
        appBar: AppBar(
          title: const Text("History"),
          scrolledUnderElevation: 0,
        ),
        body: RefreshIndicator(
          color: Colors.red,
          onRefresh: () async =>
              context.read<HistoryInnerScreenBloc>().add(RefreshHistoryInnerScreenEvent()),
          child: ListView(
            padding: const EdgeInsets.only(left: 10, right: 10),
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (historyInnerScreenBloc.state is LoadingHistoryInnerScreen)
                const HistoryInnerScreenLoadingWidget()
              else if (historyInnerScreenBloc.state is ErrorHistoryInnerScreen)
                const HistoryInnerScreenErrorWidget()
              else if (historyInnerScreenBloc.state is LoadedHistoryInnerScreen &&
                  historyInnerScreenStateModel.historyVideos.isEmpty)
                const SizedBox()
              else
                HistoryInnerScreenLoadedWidget(
                  historyVideos: historyInnerScreenStateModel.historyVideos,
                  parentContext: context,
                ),
              if (historyInnerScreenStateModel.hasMore)
                const Column(
                  children: [
                    SizedBox(height: 15),
                    SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        color: Colors.red,
                        strokeWidth: 2,
                      ),
                    )
                  ],
                ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      );
    });
  }
}
