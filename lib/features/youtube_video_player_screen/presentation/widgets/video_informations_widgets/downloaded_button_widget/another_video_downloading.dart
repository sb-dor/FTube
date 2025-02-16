import 'package:flutter/material.dart';

class AnotherVideosDownloading extends StatelessWidget {
  final VoidCallback onTap;
  final double downloadingProgress;

  const AnotherVideosDownloading({
    super.key,
    required this.onTap,
    required this.downloadingProgress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.close, size: 20),
            const SizedBox(width: 10),
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                color: Colors.red,
                strokeWidth: 2,
                value: downloadingProgress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
