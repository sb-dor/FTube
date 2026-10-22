import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/feature/search/controller/voice_search_controller.dart';

/// "Recording..." dialog shown while [controller] listens. It closes itself when listening
/// ends; "Finish" stops listening early.
class SearchVoiceDialogWidget extends StatefulWidget {
  const SearchVoiceDialogWidget({required this.controller, super.key});

  /// The dialog route is outside the search scope, so the controller is passed in.
  static Future<void> show(BuildContext context, {required VoiceSearchController controller}) =>
      showDialog<void>(
        context: context,
        builder: (_) => SearchVoiceDialogWidget(controller: controller),
      );

  final VoiceSearchController controller;

  @override
  State<SearchVoiceDialogWidget> createState() => _SearchVoiceDialogWidgetState();
}

class _SearchVoiceDialogWidgetState extends State<SearchVoiceDialogWidget> {
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    // Listening may already have failed (e.g. permission denied) before the dialog appeared.
    if (widget.controller.state is! VoiceSearch$ListeningState) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _close());
    }
  }

  void _close() {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.pop(context);
  }

  void _finish() {
    widget.controller.stop();
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return StateConsumer<VoiceSearchController, VoiceSearchState>(
      controller: widget.controller,
      listener: (context, controller, previous, next) {
        if (next is! VoiceSearch$ListeningState) _close();
      },
      builder: (context, state, _) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.searchVoiceRecording),
            if (state case VoiceSearch$ListeningState(:final words) when words.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(words, style: const TextStyle(color: Colors.grey)),
              ),
          ],
        ),
        actions: [TextButton(onPressed: _finish, child: Text(l10n.searchVoiceFinish))],
      ),
    );
  }
}
