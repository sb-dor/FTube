import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/feature/preview_hint/widgets/preview_hint_config_widget.dart';

/// Full-screen hint: a red square over the preview zone, an arrow, the explanation and a
/// "Close" button that fades in after two seconds.
class PreviewHintMobileWidget extends StatefulWidget {
  const PreviewHintMobileWidget({super.key});

  @override
  State<PreviewHintMobileWidget> createState() => _PreviewHintMobileWidgetState();
}

class _PreviewHintMobileWidgetState extends State<PreviewHintMobileWidget> {
  late final _scope = PreviewHintConfigInhWidget.of(context);
  late final Timer _closeTimer;
  bool _showClose = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _closeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showClose = true);
    });
  }

  @override
  void dispose() {
    _closeTimer.cancel();
    super.dispose();
  }

  /// Closes the hint route; the config widget persists the flag once it is gone.
  void _close() {
    if (_closing) return;
    _closing = true;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final target = _scope.target;
    final size = MediaQuery.sizeOf(context);
    // Explanation goes below the square when there is room, otherwise above it.
    final infoBelow = size.height - target.bottom >= 220;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // A swipe anywhere dismisses the hint instead of blocking the list underneath.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) => _close(),
            ),
          ),
          Positioned.fill(
            top: infoBelow ? target.bottom : 0,
            bottom: infoBelow ? 0 : size.height - target.top,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: infoBelow ? Alignment.topCenter : Alignment.bottomCenter,
                    end: infoBelow ? Alignment.bottomCenter : Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fromRect(
            rect: target,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              onLongPressDown: (_) => _close(),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.black.withValues(alpha: 0.5),
                  border: Border.all(color: AppColors.accent, width: 3),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: infoBelow ? target.bottom + 4 : null,
            bottom: infoBelow ? null : size.height - target.top + 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              verticalDirection: infoBelow ? VerticalDirection.down : VerticalDirection.up,
              children: [
                Icon(infoBelow ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: size.width * 0.6),
                  child: Text(
                    Localization.of(context).previewHintText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                IgnorePointer(
                  ignoring: !_showClose,
                  child: AnimatedOpacity(
                    opacity: _showClose ? 1 : 0,
                    duration: const Duration(seconds: 1),
                    child: ElevatedButton(
                      onPressed: _close,
                      child: Text(Localization.of(context).close),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
