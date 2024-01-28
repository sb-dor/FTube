import 'package:flutter/material.dart';
import 'package:youtube/widgets/text_widget.dart';

class VideosErrorWidget extends StatelessWidget {
  const VideosErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextWidget(text: "Error state plz try again");
  }
}
