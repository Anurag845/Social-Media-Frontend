import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class AudioInter extends StatefulWidget {
  @override
  _AudioInterState createState() => _AudioInterState();
}

class _AudioInterState extends State<AudioInter> {
  IjkMediaController controller = IjkMediaController();
  String filePath;
  List<String> allowedExtensions = List<String>();

  //double fileLength;
  //VideoInfo fileInfo;

  List<FlutterSliderHatchMarkLabel> effects = [];
  List<Map<dynamic, dynamic>> mEffects = [];
  double ellv = 30;
  double euuv = 60;

  StreamSubscription subscription;

  subscriptPlayFinish() {
    subscription = controller.playFinishStream.listen((data) {
      //showToast(currentI18n.playFinishToast);
    });
  }

  initSlider() {
    var rng = new Random();
    for (double i = 0; i < 100; i++) {
      mEffects.add({"percent": i, "size": 5 + rng.nextInt(60 - 5).toDouble()});
    }
    effects = updateEffects(ellv * 100 / mEffects.length, euuv * 100 / mEffects.length);
  }

  List<FlutterSliderHatchMarkLabel> updateEffects(
      double leftPercent, double rightPercent) {
    List<FlutterSliderHatchMarkLabel> newLabels = [];
    for (Map<dynamic, dynamic> label in mEffects) {
      if(label['percent'] >= leftPercent && label['percent'] <= rightPercent) {
        newLabels.add(FlutterSliderHatchMarkLabel(
            percent: label['percent'],
            label: Container(
              height: label['size'],
              width: 2.5,
              color: Colors.red,
            )
          )
        );
      }
      else {
        newLabels.add(FlutterSliderHatchMarkLabel(
            percent: label['percent'],
            label: Container(
              height: label['size'],
              width: 1,
              color: Colors.white,
            )
          )
        );
      }
    }
    return newLabels;
  }

  fetchFile() async {
    allowedExtensions.add("mp4");
    allowedExtensions.add("mp3");
    allowedExtensions.add("avi");
    allowedExtensions.add("wav");
    allowedExtensions.add("mpg");
    allowedExtensions.add("mpeg");
    String path = await FilePicker.getFilePath(type: FileType.custom, allowedExtensions: allowedExtensions);

    if(path != null) {
      filePath = path;

      controller.setDataSource(
        DataSource.file(File(filePath)),
        autoPlay: true
      );

    }
    setState(() {  });
  }

  @override
  void initState() {
    super.initState();
    fetchFile();
    OptionUtils.addDefaultOptions(controller);
    initSlider();
  }

  @override
  void dispose() {
    subscription?.cancel();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: filePath == null
      ? Center(
        child: RaisedButton(
          child: Text("Select file"),
          onPressed: fetchFile,
        ),
      )
      : Container(
        child: Stack(
          children: <Widget>[
            Container(
              child: IjkPlayer(
                mediaController: controller,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120,
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(0.6),
                margin: EdgeInsets.only(bottom:40),
                child: FlutterSlider(
                  rangeSlider: true,
                  min: 0,
                  max: effects.length.toDouble(),
                  values: [ellv, euuv],
                  maximumDistance: 50,
                  handler: FlutterSliderHandler(
                    decoration: BoxDecoration(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black.withOpacity(0.65), width: 1
                        )
                      ),
                    ),
                  ),
                  rightHandler: FlutterSliderHandler(
                    decoration: BoxDecoration(),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black.withOpacity(0.65), width: 1
                        )
                      ),
                    ),
                  ),
                  handlerWidth: 6,
                  handlerHeight: 40,
                  touchSize: 20,
                  tooltip: FlutterSliderTooltip(
                    format: (value) {
                      return value + ' MHz';
                    },
                    textStyle: TextStyle(fontSize: 40),
                    boxStyle: FlutterSliderTooltipBox(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                                Border.all(color: Colors.black54, width: 1)))),
                  hatchMark: FlutterSliderHatchMark(
                    labels: effects,
                    linesAlignment: FlutterSliderHatchMarkAlignment.right,
                    density: 0.5,
                  ),
                  trackBar: FlutterSliderTrackBar(
                    inactiveTrackBar: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    activeTrackBarHeight: 2,
                    inactiveTrackBarHeight: 1,
                    activeTrackBar: BoxDecoration(
                      color: Colors.transparent,
                    )),
                  onDragCompleted: (a, b, c) {
                    ellv = b;
                    euuv = c;
                    effects = updateEffects(b * 100 / mEffects.length, c * 100 / mEffects.length);
                    //controller.pause();
                    controller.seekTo((b * controller.videoInfo.duration) / 100);
                    //controller.play();
                    print("Filelength is "+controller.videoInfo.duration.toString());

                    setState(() {});
                  }
                ),
            )),
          ],
        ),
      )
    );
  }
}

class OptionUtils {
  static void addDefaultOptions(IjkMediaController controller) {
    controller.addIjkPlayerOptions(
      [TargetPlatform.iOS, TargetPlatform.android],
      createIJKOptions(),
    );
  }

  static Set<IjkOption> createIJKOptions() {
    return <IjkOption>[
      IjkOption(IjkOptionCategory.player, "mediacodec", 1),
      IjkOption(IjkOptionCategory.player, "mediacodec-hevc", 1),
      IjkOption(IjkOptionCategory.player, "videotoolbox", 1),
      IjkOption(IjkOptionCategory.player, "opensles", 0),
      IjkOption(IjkOptionCategory.player, "overlay-format", 0x32335652),
      IjkOption(IjkOptionCategory.player, "framedrop", 1),
      IjkOption(IjkOptionCategory.player, "start-on-prepared", 0),
      IjkOption(IjkOptionCategory.format, "http-detect-range-support", 0),
      IjkOption(IjkOptionCategory.codec, "skip_loop_filter", 48),
    ].toSet();
  }
}