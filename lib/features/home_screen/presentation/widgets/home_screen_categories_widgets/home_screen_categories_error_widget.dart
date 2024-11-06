import 'package:flutter/material.dart';
import 'package:youtube/core/widgets/text_widget.dart';

class HomeScreenCategoriesErrorWidget extends StatelessWidget {
  const HomeScreenCategoriesErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TextWidget(text: "Error state plz try again");
  }
}
