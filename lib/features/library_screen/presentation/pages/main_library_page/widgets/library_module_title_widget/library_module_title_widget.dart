import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube/widgets/text_widget.dart';

class LibraryModuleTitleWidget extends StatelessWidget {
  final String title;
  final VoidCallback onButtonTap;
  final bool showAdd;
  final VoidCallback? onAddTap;

  const LibraryModuleTitleWidget({
    super.key,
    required this.title,
    required this.onButtonTap,
    required this.showAdd,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              TextWidget(
                text: title,
                size: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.9,
              ),
              if (showAdd)
                IconButton(
                  onPressed: onAddTap,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.blue,
                  ),
                ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: onButtonTap,
          child: const Text("See all"),
        ),
      ],
    );
  }
}
