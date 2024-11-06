import 'package:flutter/material.dart';
import 'package:youtube/core/animations/fade_animation.dart';
import 'package:youtube/core/widgets/text_widget.dart';

class DownloadedButtonWidget extends StatelessWidget {
  final VoidCallback onTap;
  final bool showGettingInfo;
  final bool showErrorInfo;
  final bool showDownloading;
  final bool showTheSoundGettingInfo;
  final bool showPrecessingTheSound;
  final bool savingOnStorage;
  final bool loading;
  final double downloadingVideoProgress;
  final double downloadingAudioProgress;

  const DownloadedButtonWidget({
    super.key,
    required this.onTap,
    required this.showGettingInfo,
    required this.showErrorInfo,
    required this.showDownloading,
    required this.showTheSoundGettingInfo,
    required this.showPrecessingTheSound,
    required this.savingOnStorage,
    required this.loading,
    required this.downloadingVideoProgress,
    required this.downloadingAudioProgress,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: FadeAnimation(
        beginInterval: 0.5,
        child: Material(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 7, top: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showGettingInfo)
                      const Row(
                        children: [
                          TextWidget(
                            text: "Getting Information",
                            color: Colors.white,
                            size: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                          SizedBox(width: 7),
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      )
                    else if (showErrorInfo)
                      const TextWidget(
                        text: "Download error",
                        color: Colors.white,
                      )
                    else if (showDownloading)
                      Row(
                        children: [
                          const TextWidget(
                            text: "Downloading",
                            color: Colors.white,
                            size: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                          const SizedBox(width: 7),
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                              value: downloadingVideoProgress,
                            ),
                          ),
                        ],
                      )
                    else if (showTheSoundGettingInfo)
                      const Row(
                        children: [
                          TextWidget(
                            text: "Processing sound",
                            color: Colors.white,
                            size: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                          SizedBox(width: 7),
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      )
                    else if (showPrecessingTheSound)
                      Row(
                        children: [
                          const TextWidget(
                            text: "Processing sound",
                            color: Colors.white,
                            size: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                          const SizedBox(width: 7),
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blue,
                              value: downloadingAudioProgress,
                            ),
                          ),
                        ],
                      )
                    else if (savingOnStorage)
                      const Row(
                        children: [
                          TextWidget(
                            text: "A little more",
                            color: Colors.white,
                            size: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                          SizedBox(width: 7),
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      )
                    else
                      loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const FadeAnimation(
                              beginInterval: 0.6,
                              child: Row(
                                children: [
                                  TextWidget(
                                    text: "Download",
                                    color: Colors.white,
                                    size: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                  ),
                                  SizedBox(width: 7),
                                  Icon(
                                    Icons.download,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
