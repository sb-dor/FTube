import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';

/// "In-App downloads" row with the number of downloaded files.
class LibraryDownloadsTileWidget extends StatelessWidget {
  const LibraryDownloadsTileWidget({required this.count, required this.onTap, super.key});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            const Icon(Icons.download),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.libraryDownloads,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.9,
                    ),
                  ),
                  Text(
                    l10n.libraryDownloadsCount(count),
                    style: const TextStyle(fontSize: 13, color: Colors.grey, letterSpacing: 0.9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
