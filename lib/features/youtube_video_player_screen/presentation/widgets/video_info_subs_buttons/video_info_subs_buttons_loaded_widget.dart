import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube/core/animations/fade_animation.dart';
import 'package:youtube/core/widgets/text_widget.dart';

class VideoInfoSubsButtonsLoadedWidget extends StatelessWidget {
  const VideoInfoSubsButtonsLoadedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: FadeAnimation(
        beginInterval: 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => [],
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.bell,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Material(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => [],
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const TextWidget(
                    text: "Subscribe",
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
