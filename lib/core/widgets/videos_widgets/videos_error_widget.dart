import 'package:flutter/material.dart';
import 'package:youtube/core/widgets/error_button_widget/error_button_widget.dart';

class VideosErrorWidget extends StatelessWidget {
  final VoidCallback onTap;

  const VideosErrorWidget({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorButtonWidget(
      onTap: onTap,
    );
  }
}
