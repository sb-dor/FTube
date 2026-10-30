import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/feature/video/models/video_streams.dart';

/// Lists the playable [qualities], best first, with [selected] checked.
Future<void> showVideoQualitySheet(
  BuildContext context, {
  required List<PlayableStream> qualities,
  required PlayableStream? selected,
  required ValueChanged<PlayableStream> onSelected,
}) => showModalBottomSheet<void>(
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
        for (final quality in qualities.reversed)
          ListTile(
            title: Text(quality.qualityLabel),
            trailing: quality.url == selected?.url
                ? const Icon(Icons.check, color: AppColors.accent)
                : null,
            onTap: () {
              Navigator.pop(context);
              onSelected(quality);
            },
          ),
      ],
    ),
  ),
);
