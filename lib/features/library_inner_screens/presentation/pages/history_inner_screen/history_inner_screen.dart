import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/history_inner_screen_bloc/history_inner_screen_bloc.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/history_inner_screen_bloc/history_inner_screen_event.dart';
import 'package:youtube/features/library_inner_screens/presentation/pages/history_inner_screen/widgets/history_inner_screen_loaded_widget.dart';

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
          title: Text("History"),
          scrolledUnderElevation: 0,
        ),
        body: RefreshIndicator(
          color: Colors.red,
          onRefresh: () async =>
              context.read<HistoryInnerScreenBloc>().add(RefreshHistoryInnerScreenEvent()),
          child: ListView(
            padding: EdgeInsets.only(left: 10, right: 10),
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              HistoryInnerScreenLoadedWidget(),
              if (historyInnerScreenStateModel.hasMore)
                Column(
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
              SizedBox(height: 15),
            ],
          ),
        ),
      );
    });
  }
}
