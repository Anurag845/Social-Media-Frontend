import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:navras/main.dart';
import 'package:navras/pages/MomentPreview.dart';
import 'package:navras/providers/ShaderMaskProvider.dart';
import 'package:navras/utils/Classes.dart';
import 'package:navras/utils/Constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class Moment extends StatefulWidget {
  @override
  _MomentState createState() => _MomentState();
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

class _MomentState extends State<Moment>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {

  CameraController controller;
  String imagePath;

  FlutterFFmpeg flutterFFmpeg = new FlutterFFmpeg();

  bool frontexists = false;
  bool backexists = false;

  String currentCamera;
  CameraDescription frontCamera;
  CameraDescription rearCamera;

  static const String FRONT = "FRONT";
  static const String REAR = "REAR";

  Filter filter;

  bool showFilters = false;

  void setDefaultCamera() {
    for(CameraDescription cameraDescription in cameras) {
      if(cameraDescription.lensDirection == CameraLensDirection.front) {
        onNewCameraSelected(cameraDescription);
        frontexists = true;
        frontCamera = cameraDescription;
        currentCamera = FRONT;
      }
      else if(cameraDescription.lensDirection == CameraLensDirection.back) {
        backexists = true;
        rearCamera = cameraDescription;
      }
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
    ]);

    WidgetsBinding.instance.addObserver(this);
    setDefaultCamera();

    filter = Provider.of<ShaderMaskProvider>(context, listen: false).filter;
  }

  @override
  void dispose() {
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
            showFilters
            ? Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                height: 70,
                margin: EdgeInsets.only(bottom: 80),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: Constants.filters.length,
                  itemBuilder: (context, i) {
                    return InkWell(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: Constants.filters[i].color1,
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 60,
                              child: Text(
                                Constants.filters[i].effectName,
                                overflow: TextOverflow.fade,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        filter = Constants.filters[i];
                        Provider.of<ShaderMaskProvider>(context, listen: false)
                          .updateFilter(filter);
                      },
                    );
                  }
                ),
              ),
            )
            : Container(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70,
                padding: EdgeInsets.only(bottom: 0),
                color: Colors.black.withOpacity(0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      padding: EdgeInsets.all(15),
                      iconSize: 28,
                      color: Colors.white,
                      icon: Icon(
                        Icons.switch_camera
                      ),
                      onPressed: _switchCamera,
                    ),
                    IconButton(
                      padding: EdgeInsets.all(15),
                      iconSize: 36,
                      color: Colors.white,
                      icon: Icon(
                        Icons.photo_camera
                      ),
                      onPressed: controller.value.isInitialized
                      ?  () {
                        onTakePictureButtonPressed(context);
                      }
                      : null,
                    ),
                    IconButton(
                      padding: EdgeInsets.all(15),
                      iconSize: 26,
                      color: Colors.white,
                      icon: Icon(
                        Icons.filter
                      ),
                      onPressed: () {
                        print("Length of filters in Moment is " + Constants.filters.length.toString());
                        setState(() {
                          if(showFilters)
                            showFilters = false;
                          else
                            showFilters = true;
                        });
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      )
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Camera not available',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }
    else {
      final size = MediaQuery.of(context).size;
      return ClipRect(
        child: Container(
          child: Transform.scale(
            scale: controller.value.aspectRatio / size.aspectRatio,
            child: Center(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      filter.color1,
                      filter.color2
                    ]
                  ).createShader(bounds);
                },
                blendMode: BlendMode.color,
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                ),
              )
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

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  /*static Future<String> secondOutputPath() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

    final String dirPath = '${extDir.path}/1234/user-posts';
    await Directory(dirPath).create(recursive: true);
    return '$dirPath/${timestamp()}.mp4';
  }*/

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: true,
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

  void onTakePictureButtonPressed(BuildContext context) {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
        });
        Navigator.of(context).pushReplacementNamed(
          Constants.MomentPreviewPageRoute,
          arguments: PhotoEffectArgs(imagePath,filter)
        );
      }
    });
  }

  Future<int> executeFFmpeg(String command) async {
    return await flutterFFmpeg.execute(command);
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