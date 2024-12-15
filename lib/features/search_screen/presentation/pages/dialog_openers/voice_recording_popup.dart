import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/search_screen/bloc/main_search_screen_bloc.dart';
import 'package:youtube/features/search_screen/bloc/search_screen_events.dart';

abstract class VoiceRecordingPopup {
  static Future<void> voiceRecordingPopup(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: const Text("Recording..."),
        actions: [
          TextButton(
            onPressed: () {
              context.read<MainSearchScreenBloc>().add(
                    StopListeningSpeechEvent(popup: true, context: context),
                  );
            },
            child: const Text("Finish"),
          ),
        ],
      ),
    );
    if (context.mounted) {
      context
          .read<MainSearchScreenBloc>()
          .add(StopListeningSpeechEvent(popup: false, context: context));
    }
  }
}
