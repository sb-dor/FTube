import 'package:flutter/material.dart';
import 'package:youtube/core/widgets/error_button_widget/error_button_widget.dart';

class VideosErrorWidget extends StatelessWidget {
  final VoidCallback onTap;

  const VideosErrorWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ErrorButtonWidget(onTap: onTap);
  }
}
