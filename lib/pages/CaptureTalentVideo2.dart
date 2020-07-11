import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:lockdown_diaries/main.dart';
import 'package:lockdown_diaries/pages/IntermediatePage2.dart';
import 'package:lockdown_diaries/utils/Constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_timer/simple_timer.dart';
import 'package:video_player/video_player.dart';

class CaptureTalent extends StatefulWidget {
  @override
  _CaptureTalentState createState() => _CaptureTalentState();
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CaptureTalentState extends State<CaptureTalent>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController controller;
  String imagePath;
  String videoPath;
  String audioPath;
  String finalVideoPath;
  VideoPlayerController _videoController;
  TimerController _timerController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  FlutterFFmpeg flutterFFmpeg = new FlutterFFmpeg();

  bool frontexists = false;
  bool backexists = false;

  bool video = false;

  String currentCamera;
  CameraDescription frontCamera;
  CameraDescription rearCamera;

  static const String FRONT = "FRONT";
  static const String REAR = "REAR";

  /*IjkMediaController _videoController = IjkMediaController();
  OverlayEntry entry;*/

  void setDefaultCamera() {
    for (CameraDescription cameraDescription in cameras) {
      if (cameraDescription.lensDirection == CameraLensDirection.front) {
        onNewCameraSelected(cameraDescription);
        frontexists = true;
        frontCamera = cameraDescription;
        currentCamera = FRONT;
      } else if (cameraDescription.lensDirection == CameraLensDirection.back) {
        backexists = true;
        rearCamera = cameraDescription;
      }
    }
  }

  @override
  void initState() {
    _timerController = TimerController(this);
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    WidgetsBinding.instance.addObserver(this);
    setDefaultCamera();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller.description);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Container(
                child: _cameraPreviewWidget(),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.white.withOpacity(0.6),
                    margin: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(currentCamera == FRONT
                              ? Icons.camera_rear
                              : Icons.camera_front),
                          onPressed: controller.value.isRecordingVideo
                              ? null
                              : _switchCamera,
                        ),
                        IconButton(
                            icon: Icon(Icons.audiotrack),
                            onPressed: () async {
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) =>
                                          AudioInter2("AUDIO")))
                                  .then((value) {
                                audioPath = value;
                                _initVideoPlayer(false);
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.music_video),
                            onPressed: () async {
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) =>
                                          AudioInter2("VIDEO")))
                                  .then((value) {
                                audioPath = value;
                                _initVideoPlayer(true);
                              });
                            }),
                        IconButton(
                          icon: Icon(enableAudio ? Icons.mic_off : Icons.mic),
                          onPressed: controller.value.isRecordingVideo
                              ? null
                              : _toggleAudio,
                        ),
                        IconButton(
                          icon: Icon(Icons.fiber_manual_record),
                          onPressed: controller != null &&
                                  controller.value.isInitialized &&
                                  !controller.value.isRecordingVideo
                              ? onVideoRecordButtonPressed
                              : null,
                        ),
                        IconButton(
                          icon: controller != null &&
                                  controller.value.isRecordingPaused
                              ? Icon(Icons.play_arrow)
                              : Icon(Icons.pause),
                          color: Colors.blue,
                          onPressed: controller != null &&
                                  controller.value.isInitialized &&
                                  controller.value.isRecordingVideo
                              ? (controller != null &&
                                      controller.value.isRecordingPaused
                                  ? onResumeButtonPressed
                                  : onPauseButtonPressed)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.stop),
                          color: Colors.red,
                          onPressed: controller != null &&
                                  controller.value.isInitialized &&
                                  controller.value.isRecordingVideo
                              ? () {
                                  onStopButtonPressed(context);
                                }
                              : null,
                        )
                      ],
                    ),
                  )),
              Positioned(
                top: 30,
                right: 10,
                child: Container(
                    height: 32,
                    width: 32,
                    child: SimpleTimer(
                      controller: _timerController,
                      duration: Duration(seconds: 15),
                      progressIndicatorColor: Colors.red[700],
                      displayProgressText: false,
                      onEnd: controller != null &&
                              controller.value.isInitialized &&
                              controller.value.isRecordingVideo
                          ? () {
                              onStopButtonPressed(context);
                            }
                          : null,
                    )),
              ),
              _videoController != null && video
                  ? Positioned(
                      top: 20,
                      left: 20,
                      child: _videoController.value.initialized
                          ? Container(
                              height: 70,
                              width: 70,
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio:
                                      _videoController.value.aspectRatio,
                                  child: VideoPlayer(_videoController),
                                ),
                              ),
                            )
                          : Container())
                  : Container()
            ],
          ),
        ));
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      final size = MediaQuery.of(context).size;
      return ClipRect(
        child: Container(
          child: Transform.scale(
            scale: controller.value.aspectRatio / size.aspectRatio,
            child: Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
            ),
          ),
        ),
      );
    }
  }

  _switchCamera() {
    switch (currentCamera) {
      case FRONT:
        onNewCameraSelected(rearCamera);
        currentCamera = REAR;
        break;
      case REAR:
        onNewCameraSelected(frontCamera);
        currentCamera = FRONT;
        break;
      default:
    }
  }

  _toggleAudio() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller.description);
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<String> secondOutputPath() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

    final String dirPath = '${extDir.path}/1234/user-posts';
    await Directory(dirPath).create(recursive: true);
    return '$dirPath/${timestamp()}.mp4';
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      //if (filePath != null) showInSnackBar('Saving video to $filePath');
      _timerController.start();
      //showInOverlay();
      //_videoController.play();
      if (_videoController != null) {
        if (_videoController.value.initialized) _videoController.play();
      }
    });
  }

  Future<int> executeFFmpeg(String command) async {
    return await flutterFFmpeg.execute(command);
  }

  stopAndMerge() async {
    await stopVideoRecording().then((_) {
      if (mounted) setState(() {});

      _timerController.stop();

      _timerController.reset();

      if (_videoController != null) {
        if (_videoController.value.initialized) {
          //if(_videoController.value.isPlaying) {
          _videoController.pause();
          //}
          _videoController.seekTo(Duration(seconds: 0));
        }
      }

      print('Video recording completed: $videoPath');
      if (audioPath == null) {
        secondOutputPath().then((secondVideo) {
          finalVideoPath = secondVideo;
          executeFFmpeg("-i $videoPath -c:v copy $finalVideoPath").then((rc) {
            print("FFmpeg process completed with $rc.");

            Navigator.of(context).pushNamed(Constants.TalentPreviewPageRoute,
                arguments: finalVideoPath);
          });
        });
      } else {
        secondOutputPath().then((secondVideo) {
          finalVideoPath = secondVideo;
          executeFFmpeg(
                  "-i $videoPath -i $audioPath -c:v copy -c:a aac -shortest $finalVideoPath")
              .then((rc) {
            print("FFmpeg process completed with $rc.");

            Navigator.of(context).pushNamed(Constants.TalentPreviewPageRoute,
                arguments: finalVideoPath);
          });
        });
      }
    });
    setState(() {});
  }

  void onStopButtonPressed(BuildContext context) async {
    await stopAndMerge();
  }

  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      _timerController.pause();
      if (_videoController != null) {
        if (_videoController.value.initialized) {
          if (_videoController.value.isPlaying) {
            _videoController.pause();
          }
        }
      }
    });
  }

  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      _timerController.start();
      if (_videoController != null) {
        if (_videoController.value.initialized) {
          if (!_videoController.value.isPlaying) {
            _videoController.play();
          }
        }
      }
    });
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    //await _startVideoPlayer();
  }

  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> _initVideoPlayer(bool value) async {
    final VideoPlayerController vcontroller =
        VideoPlayerController.file(File(audioPath));
    videoPlayerListener = () {
      if (_videoController != null && _videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        _videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    //await vcontroller.setLooping(true);
    await vcontroller.initialize();
    //await _videoController?.dispose();
    if (mounted) {
      setState(() {
        //imagePath = null;
        video = value;
        _videoController = vcontroller;
      });
    }
    //await vcontroller.play();
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}