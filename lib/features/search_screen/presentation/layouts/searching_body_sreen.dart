import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/search_screen/bloc/main_search_screen_bloc.dart';
import 'package:youtube/features/search_screen/bloc/search_screen_events.dart';
import 'package:youtube/widgets/text_widget.dart';

class SearchingBodyScreen extends StatelessWidget {
  final List<String> suggests;

  const SearchingBodyScreen({
    Key? key,
    required this.suggests,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: const EdgeInsets.only(left: 20, right: 10),
        separatorBuilder: (context, index) => const SizedBox(height: 5),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggests.length,
        itemBuilder: (context, index) {
          String value = suggests[index];
          return GestureDetector(
            onTap: () => context
                .read<MainSearchScreenBloc>()
                .add(ClickOnAlreadySearchedValueEvent(value: value, context: context)),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Row(children: [
                const Icon(Icons.search),
                const SizedBox(width: 10),
                Expanded(
                  child: TextWidget(
                    text: value,
                    size: 15,
                  ),
                ),
              ]),
            ),
          );
        });
  }
}