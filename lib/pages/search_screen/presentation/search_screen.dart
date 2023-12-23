import 'package:flutter/material.dart';
import 'package:youtube/pages/search_screen/presentation/animated_search_bar/animated_search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  late AnimationController _searchBarAnimationController;
  late Animation<double> _searchBarAnimation;

  @override
  void initState() {
    super.initState();
    _searchBarAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _searchBarAnimation = Tween<double>(begin: 0.200, end: 1.0).animate(
        CurvedAnimation(parent: _searchBarAnimationController, curve: Curves.easeInOutCubic));
    _searchBarAnimationController.forward();
    _searchBarAnimationController.addListener(() {
      if (_searchBarAnimationController.isCompleted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AnimatedSearchBar(
            searchBarAnimationController: _searchBarAnimationController,
            searchBarAnimation: _searchBarAnimation,
            focusNode: _focusNode),
        leadingWidth: MediaQuery.of(context).size.width,
      ),
    );
  }
}
