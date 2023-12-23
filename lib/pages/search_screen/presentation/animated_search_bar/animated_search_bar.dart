import 'package:flutter/material.dart';

class AnimatedSearchBar extends StatelessWidget {
  final AnimationController searchBarAnimationController;
  final Animation<double> searchBarAnimation;
  final FocusNode focusNode;

  const AnimatedSearchBar({
    Key? key,
    required this.searchBarAnimationController,
    required this.searchBarAnimation,
    required this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: searchBarAnimationController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.only(left: 15, right: 15),
            // color: Colors.red,
            width: MediaQuery.of(context).size.width,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width * searchBarAnimation.value,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        color: Colors.grey.shade300,
                      )
                    ]),
                child: Stack(
                  children: [
                    Row(children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.130,
                        height: MediaQuery.of(context).size.width * 0.130,
                        decoration: BoxDecoration(
                          // color: Colors.amber,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 60),
                          child: TextField(
                            focusNode: focusNode,
                            onTapOutside: (v) => FocusManager.instance.primaryFocus?.unfocus(),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ]),
                    if (searchBarAnimationController.isCompleted)
                      Positioned(
                          top: 0,
                          right: 10,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () => [],
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(
                                  child: Icon(Icons.close),
                                ),
                              ),
                            ),
                          )),
                    Positioned(
                        left: 0,
                        bottom: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.130,
                              height: MediaQuery.of(context).size.width * 0.130,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
