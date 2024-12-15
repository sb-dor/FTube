import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/widgets/text_widget.dart';
import 'package:youtube/features/search_screen/bloc/main_search_screen_bloc.dart';
import 'package:youtube/features/search_screen/bloc/search_screen_events.dart';

class SearchingBodyScreen extends StatelessWidget {
  final List<String> suggests;
  final bool showDeleteButton;
  final SearchScreenEventFunctionsHolder functionsHolder;

  const SearchingBodyScreen({
    Key? key,
    required this.suggests,
    this.showDeleteButton = false,
    required this.functionsHolder,
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
          onTap: () => context.read<MainSearchScreenBloc>().add(
                ClickOnAlreadySearchedValueEvent(
                  value: value,
                  functionsHolder: functionsHolder,
                ),
              ),
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
              if (showDeleteButton)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(2),
                    onPressed: () {
                      context.read<MainSearchScreenBloc>().add(
                            DeleteSearchedItemEvent(value),
                          );
                    },
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // the '2023' part
                    ),
                    icon: const Icon(
                      Icons.delete,
                    ),
                  ),
                )
            ]),
          ),
        );
      },
    );
  }
}
