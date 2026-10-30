import 'package:flutter/material.dart';

/// Gives a dialog its own [ScaffoldMessenger], so a snackbar shown with a context from [builder]
/// appears above the dialog instead of under its barrier on the screen behind.
///
/// The transparent [Scaffold] fills the route and would swallow taps on the barrier, so a tap
/// outside the dialog is forwarded to [Navigator.maybePop], which still respects [PopScope].
class DialogMessengerWidget extends StatelessWidget {
  const DialogMessengerWidget({required this.builder, super.key});

  /// Builds the dialog; its context sees the dialog's own messenger.
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => ScaffoldMessenger(
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.maybePop(context),
          ),
          Builder(builder: builder),
        ],
      ),
    ),
  );
}
