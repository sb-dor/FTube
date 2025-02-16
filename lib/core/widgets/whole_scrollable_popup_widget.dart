import 'package:flutter/material.dart';

class WholeScrollablePopupWidget extends StatelessWidget {
  final Widget child;

  const WholeScrollablePopupWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.96,
      decoration: const BoxDecoration(
        borderRadius:
            BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15)),
        color: Colors.white,
      ),
      child: child,
    );
  }
}
