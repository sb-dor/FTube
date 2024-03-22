import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube/widgets/text_widget.dart';

class LibraryModuleTitleWidget extends StatelessWidget {
  final String title;
  final VoidCallback onButtonTap;
  final bool showAdd;
  final VoidCallback? onAddTap;
  final bool showSeeAll;

  const LibraryModuleTitleWidget({
    super.key,
    required this.title,
    required this.onButtonTap,
    required this.showAdd,
    this.onAddTap,
    this.showSeeAll = true,
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
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ),
        if (showSeeAll)
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
            ),
            onPressed: onButtonTap,
            child: const Text(
              "See all",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}
