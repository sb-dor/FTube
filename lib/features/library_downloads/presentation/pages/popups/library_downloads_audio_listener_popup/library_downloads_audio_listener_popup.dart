import 'dart:io';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube/utils/duration_helper/duration_helper.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/widgets/text_widget.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class LibraryDownloadsAudioListenerPopup extends StatefulWidget {
  final BaseDownloadedFileModel? baseDownloadedFileModel;

  const LibraryDownloadsAudioListenerPopup({
    super.key,
    required this.baseDownloadedFileModel,
  });

  @override
  State<LibraryDownloadsAudioListenerPopup> createState() =>
      _LibraryDownloadsAudioListenerPopupState();
}

class _LibraryDownloadsAudioListenerPopupState extends State<LibraryDownloadsAudioListenerPopup>
    with TickerProviderStateMixin {
  final _durationHelper = locator<DurationHelper>();
  final _globalFunctions = locator<ReusableGlobalFunctions>();

  AudioPlayer? _audioPlayer;

  VideoPlayerController? _videoController;

  Duration? _totalDuration;

  Duration _positionDuration = const Duration(seconds: 0);

  bool _paused = false, _isVideo = false, _isShowingVideo = false;

  @override
  void initState() {
    super.initState();
    _isVideo = _globalFunctions.fileExtensionName(widget.baseDownloadedFileModel) == 'mp4';
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (_isVideo) {
        await _initVideo();
      } else {
        await _initAudio();
      }

      Future.delayed(
        const Duration(seconds: 1),
        () {
          if (_isVideo) {
            _totalDuration = _videoController?.value.duration;
          } else {
            _totalDuration = _audioPlayer?.duration;
          }
          setState(() {});
          // listening here
          if (_isVideo) {
            _videoController?.addListener(_durationVideoListener);
          } else {
            _audioPlayer?.positionStream.listen(_durationAudioListener);
          }
        },
      );
    });
  }

  Future<void> _initAudio() async {
    _audioPlayer = AudioPlayer();

    await _audioPlayer?.setFilePath(widget.baseDownloadedFileModel?.downloadedPath ?? "");

    await _audioPlayer?.setLoopMode(LoopMode.one);

    _play();
  }

  Future<void> _initVideo() async {
    if (_isVideo) {
      _videoController = VideoPlayerController.file(
        File(widget.baseDownloadedFileModel?.downloadedPath ?? ''),
      );
      await _videoController?.initialize();
      await _videoController?.setLooping(true);
      // await _videoController?.setVolume(0);
      _isShowingVideo = true;
      _play();
      setState(() {});
    }
  }

  void _durationAudioListener(Duration duration) {
    _positionDuration = duration;
    setState(() {});
  }

  void _durationVideoListener() async {
    _positionDuration = await _videoController?.position ?? const Duration(seconds: 0);
    setState(() {});
  }

  void _seek(double number) async {
    if (_isVideo) {
      await _videoController?.seekTo(Duration(seconds: number.toInt()));
    } else {
      await _audioPlayer?.seek(Duration(seconds: number.toInt()));
    }
    setState(() {});
  }

  void _stop() async {
    _paused = true;
    setState(() {});
    if (_isVideo) {
      _videoController?.pause();
    } else {
      _audioPlayer?.stop();
    }
  }

  Future<void> _play() async {
    _paused = false;
    setState(() {});
    if (_isVideo) {
      _videoController?.play();
    } else {
      _audioPlayer?.play();
    }
  }

  void _hideAndShowVideo() {
    _isShowingVideo = !_isShowingVideo;
    setState(() {});
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      if (_isVideo && _videoController != null && _isShowingVideo)
                        Column(
                          children: [
                            const SizedBox(height: 10),

                            Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FittedBox(
                                  fit: _videoController!.value.size.width >=
                                          _videoController!.value.size.height
                                      ? BoxFit.cover
                                      : BoxFit.scaleDown,
                                  child: SizedBox(
                                    width: _videoController!.value.size.width,
                                    height: _videoController!.value.size.height,
                                    child: VideoPlayer(
                                      _videoController!,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            // Container(
                            //   margin: const EdgeInsets.only(left: 10, right: 10),
                            //   width: MediaQuery.of(context).size.width,
                            //   height: MediaQuery.of(context).size.height * 0.315,
                            //   child: ClipRRect(
                            //     borderRadius: BorderRadius.circular(10),
                            //     child: VideoPlayer(
                            //       _videoController!,
                            //     ),
                            //   ),
                            // )
                          ],
                        ),
                      if (!_isShowingVideo)
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 20,
                              child: Marquee(
                                text: widget.baseDownloadedFileModel?.name ?? '-',
                                accelerationDuration: const Duration(seconds: 5),
                                accelerationCurve: Curves.linear,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      SfSlider(
                        min: 0,
                        max: _totalDuration?.inSeconds ?? 1,
                        value: _positionDuration.inSeconds,
                        onChanged: (v) => _seek(v as double),
                        onChangeEnd: (v) => _play(),
                        onChangeStart: (v) => _stop(),
                        activeColor: Colors.red,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextWidget(
                              text: _durationHelper.getFromDuration(_positionDuration),
                            ),
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(0),
                              onPressed: () {
                                if (_paused) {
                                  _play();
                                } else {
                                  _stop();
                                }
                              },
                              icon: Icon(
                                _paused ? Icons.play_arrow : Icons.stop,
                                size: 35,
                              ),
                            ),
                            TextWidget(
                              text: _durationHelper.getFromDuration(_totalDuration),
                            )
                          ],
                        ),
                      ),
                      if (_isVideo)
                        Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: IconButton(
                            onPressed: () => _hideAndShowVideo(),
                            icon: Icon(_isShowingVideo
                                ? Icons.highlight_remove
                                : Icons.slow_motion_video_outlined),
                          ),
                        )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
