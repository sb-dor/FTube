import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/feature/video/widgets/controllers/video_playback_controller.dart';

/// Lists the playable qualities.
Future<void> showVideoQualitySheet(BuildContext context, VideoPlaybackController playback) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                Localization.of(context).videoQualityTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            for (final quality in playback.qualities.reversed)
              ListTile(
                title: Text(quality.qualityLabel),
                trailing: quality.url == playback.quality?.url
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  playback.changeQuality(quality);
                },
              ),
          ],
        ),
      ),
    );
