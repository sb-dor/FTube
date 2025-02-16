import 'package:flutter/material.dart';

class CircleSelectedWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool selected;

  const CircleSelectedWidget({
    super.key,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            color: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: selected ? Colors.red : Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: ColoredBox(
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: ColoredBox(
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: selected ? Colors.red : Colors.grey.shade500,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
