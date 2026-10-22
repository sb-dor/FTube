import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';

/// Centered illustration with a message for empty lists.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/custom_images/empty_data.png', width: 120, height: 120),
        const SizedBox(height: 12),
        Text(
          message ?? Localization.of(context).emptyList,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    ),
  );
}
