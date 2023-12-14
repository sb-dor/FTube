import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube/widgets/text_widget.dart';

class VideoInfoSubsButtonsLoadedWidget extends StatelessWidget {
  const VideoInfoSubsButtonsLoadedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
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
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(),
                child: Center(
                  child: Icon(
                    CupertinoIcons.bell,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 15),
          Material(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => [],
              child: Container(
                padding: EdgeInsets.all(10),
                child: TextWidget(
                  text: "Подписаться",
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.9,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
