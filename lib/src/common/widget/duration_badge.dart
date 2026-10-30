import 'package:flutter/material.dart';

/// Black rounded badge with a duration or playback position.
class DurationBadge extends StatelessWidget {
  const DurationBadge({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
    ),
  );
}
