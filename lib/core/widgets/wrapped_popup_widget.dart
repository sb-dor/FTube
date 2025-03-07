import 'package:flutter/material.dart';

class WrappedPopupWidget extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final bool fromFullScreen;

  const WrappedPopupWidget({
    super.key,
    required this.child,
    this.backgroundColor,
    this.fromFullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Wrap(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10),
              width:
                  fromFullScreen
                      ? MediaQuery.of(context).size.height
                      : MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 50,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 15),
                  child,
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
