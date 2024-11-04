import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/youtube_data_api/models/order_by/order_by_details/order_by_time.dart';
import 'package:youtube/core/youtube_data_api/models/order_by/order_by_details/order_by_type.dart';
import 'package:youtube/features/search_screen/bloc/main_search_screen_bloc.dart';
import 'package:youtube/features/search_screen/bloc/search_screen_events.dart';
import 'package:youtube/widgets/circle_selected_widget.dart';
import 'package:youtube/widgets/text_widget.dart';

class SearchScreenFilterLayout extends StatelessWidget {
  const SearchScreenFilterLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final mainSearchScreenBloc = context.watch<MainSearchScreenBloc>().state;

        final mainSearchScreenStateModel = mainSearchScreenBloc.searchScreenStateModel;
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () {
              Navigator.pop(context);
              context.read<MainSearchScreenBloc>().add(ClickSearchButtonEvent(context: context));
            },
            child: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          appBar: AppBar(
            title: const Text("Filter"),
            // elevation: 1,
            scrolledUnderElevation: 0,
            // backgroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.only(left: 15, right: 15),
            children: [
              const SizedBox(height: 10),
              const TextWidget(
                text: "Order by time",
                size: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.9,
              ),
              const SizedBox(height: 5),
              ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 3),
                padding: const EdgeInsets.only(left: 15, right: 15),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: OrderByTime.orderByTimes.length,
                itemBuilder: (context, index) {
                  var orderByTime = OrderByTime.orderByTimes[index];
                  return GestureDetector(
                    onTap: () => context
                        .read<MainSearchScreenBloc>()
                        .add(SelectOrderByTimeEvent(orderByTime: orderByTime)),
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          CircleSelectedWidget(
                              onTap: () => context
                                  .read<MainSearchScreenBloc>()
                                  .add(SelectOrderByTimeEvent(orderByTime: orderByTime)),
                              selected: orderByTime.id ==
                                  mainSearchScreenStateModel.orderBy?.orderByTime?.id),
                          const SizedBox(width: 5),
                          Expanded(
                            child: TextWidget(
                              text: "${orderByTime.name}",
                              size: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.9,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const TextWidget(
                text: "Order by type",
                size: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.9,
              ),
              const SizedBox(height: 5),
              ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 3),
                padding: const EdgeInsets.only(left: 15, right: 15),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: OrderByType.orderByType.length,
                itemBuilder: (context, index) {
                  var orderByType = OrderByType.orderByType[index];
                  return GestureDetector(
                    onTap: () => context
                        .read<MainSearchScreenBloc>()
                        .add(SelectOrderByTypeEvent(orderByType: orderByType)),
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          CircleSelectedWidget(
                              onTap: () => context
                                  .read<MainSearchScreenBloc>()
                                  .add(SelectOrderByTypeEvent(orderByType: orderByType)),
                              selected: orderByType.id ==
                                  mainSearchScreenStateModel.orderBy?.orderByType?.id),
                          const SizedBox(width: 5),
                          Expanded(
                            child: TextWidget(
                              text: "${orderByType.name}",
                              size: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.9,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }
}
