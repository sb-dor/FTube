import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/feature/search/widgets/search_config_widget.dart';

/// Rounded search field that grows from 20% to the full app bar width, then takes focus.
class SearchFieldWidget extends StatefulWidget {
  const SearchFieldWidget({super.key});

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> with SingleTickerProviderStateMixin {
  late final _scope = SearchConfigInhWidget.of(context);
  late final _dataController = _scope.searchDataController;
  late final _trailingListenable = Listenable.merge([_dataController, _scope.textController]);
  late final AnimationController _animationController;
  late final Animation<double> _widthFactor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addStatusListener(_onAnimationStatus);
    _widthFactor = Tween<double>(
      begin: 0.2,
      end: 1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _scope.focusNode.requestFocus();
    setState(() {}); // Shows the trailing button.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    final field = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey.shade300)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _scope.textController,
                focusNode: _scope.focusNode,
                style: const TextStyle(fontSize: 14),
                textInputAction: TextInputAction.search,
                onChanged: _scope.onTextChanged,
                onTap: _scope.onFieldTap,
                onSubmitted: _scope.submit,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: l10n.searchHint,
                ),
              ),
            ),
            if (_animationController.isCompleted)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListenableBuilder(
                  listenable: _trailingListenable,
                  builder: (context, _) {
                    if (_dataController.showResults) {
                      return _TrailingButton(
                        icon: Icons.filter_list,
                        tooltip: l10n.searchFilterTitle,
                        onTap: _scope.openFilter,
                      );
                    }
                    if (_scope.textController.text.isNotEmpty) {
                      return _TrailingButton(
                        icon: Icons.close,
                        tooltip: l10n.searchClear,
                        onTap: _scope.clearText,
                      );
                    }
                    return _TrailingButton(
                      icon: Icons.keyboard_voice,
                      tooltip: l10n.searchVoice,
                      onTap: _scope.startVoiceSearch,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: LayoutBuilder(
        builder: (context, constraints) => AnimatedBuilder(
          animation: _widthFactor,
          builder: (context, child) => Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: constraints.maxWidth * _widthFactor.value,
              height: 40,
              child: child,
            ),
          ),
          child: field,
        ),
      ),
    );
  }
}

class _TrailingButton extends StatelessWidget {
  const _TrailingButton({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.grey.shade100,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(dimension: 30, child: Icon(icon, size: 18, color: Colors.black)),
      ),
    ),
  );
}
