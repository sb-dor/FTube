import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/search_screen/bloc/main_search_screen_bloc.dart';
import 'package:youtube/widgets/text_widget.dart';

class SearchingBodyScreen extends StatelessWidget {
  const SearchingBodyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final mainSearchBlocStates = context.watch<MainSearchScreenBloc>().state;

      // data
      var mainSearchBlocStateModel = mainSearchBlocStates.searchScreenStateModel;
      return ListView.separated(
          padding: const EdgeInsets.only(left: 20, right: 10, top: 15),
          separatorBuilder: (context, index) => const SizedBox(height: 5),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mainSearchBlocStateModel.searchData.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => [],
              child: Container(
                color: Colors.transparent,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextWidget(
                      text: "${mainSearchBlocStateModel.searchData[index]}",
                      size: 15,
                    ),
                  ),
                ]),
              ),
            );
          });
    });
  }
}
