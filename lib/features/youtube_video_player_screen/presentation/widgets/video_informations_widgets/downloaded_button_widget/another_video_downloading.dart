import 'package:flutter/material.dart';

class AnotherVideosDownloading extends StatelessWidget {
  const AnotherVideosDownloading({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (downloadingVideoCubit.isDownloading) {
          context.read<YoutubeVideoCubit>().cancelTheVideo();
        } else {
          context.read<YoutubeVideoCubit>().cancelTheAudio();
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.close, size: 20),
            SizedBox(width: 10),
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                color: Colors.red,
                strokeWidth: 2,
              ),
            )
          ],
        ),
      ),
    );
  }
}
