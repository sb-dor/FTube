import 'package:flutter/material.dart';
import 'package:youtube/widgets/text_widget.dart';

class HomeScreenVideosErrorWidget extends StatelessWidget {
  const HomeScreenVideosErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextWidget(text: "Error state plz try again");
  }
}
