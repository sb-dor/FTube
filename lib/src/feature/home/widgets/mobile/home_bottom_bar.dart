import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/feature/home/models/home_tab.dart';

/// Floating rounded bottom navigation bar.
class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({required this.tab, required this.onSelected, super.key});

  final HomeTab tab;
  final ValueChanged<HomeTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return Container(
      height: kBottomNavigationBarHeight + 10,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 3, spreadRadius: 0.5)],
      ),
      child: Row(
        children: [
          for (final (item, icon, label) in [
            (HomeTab.feed, FontAwesomeIcons.laptop, l10n.tabHome),
            (HomeTab.trending, FontAwesomeIcons.boltLightning, l10n.tabTrending),
            (HomeTab.library, FontAwesomeIcons.folder, l10n.tabLibrary),
          ])
            Expanded(
              child: _BottomBarItem(
                icon: icon,
                label: label,
                selected: item == tab,
                onTap: () => onSelected(item),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final FaIconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.inactive;
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 25, color: color),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
