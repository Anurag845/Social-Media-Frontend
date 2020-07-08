import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'CaptureTalentVideo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart';

class AudioInter2 extends StatefulWidget {
  final String fileType;
  AudioInter2(this.fileType);
  @override
  _AudioInterState createState() => _AudioInterState();
}

class _AudioInterState extends State<AudioInter2> {
  //IjkMedia_controller _controller = IjkMedia_controller();
  String filePath;
  String outputFilePath;
  List<String> allowedExtensions = List<String>();
  VideoPlayerController _controller;
  FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  double fileLength;
  double maxSliderDistance;
  //VideoInfo fileInfo;

  List<FlutterSliderHatchMarkLabel> effects = [];
  List<Map<dynamic, dynamic>> mEffects = [];
  double ellv = 0;
  double euuv = 0;

  /*StreamSubscription subscription;

  subscriptPlayFinish() {
    subscription = _controller.playFinishStream.listen((data) {
      //showToast(currentI18n.playFinishToast);
    });
  }*/

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

    if(widget.fileType == "AUDIO") {
      allowedExtensions.add("mp3");
      allowedExtensions.add("avi");
      allowedExtensions.add("wav");
    }
    else if(widget.fileType == "VIDEO"){
      allowedExtensions.add("mp4");
      allowedExtensions.add("mpg");
      allowedExtensions.add("mpeg");
    }
    String path = await FilePicker.getFilePath(type: FileType.custom, allowedExtensions: allowedExtensions);

    if(path != null) {
      filePath = path;

      print("File path is " + filePath);

      _controller = VideoPlayerController.file(File(filePath))
        ..initialize().then((_) {
          fileLength = _controller.value.duration.inSeconds.toDouble();
          maxSliderDistance = fileLength > 15 ? (15/fileLength)*100 : 100;
          initSlider();
          setState(() {

          });
        }
      );
      _controller.addListener(() { });
      _controller.setLooping(true);
    }
  }

  initSlider() {
    ellv = 0;
    euuv = maxSliderDistance.floorToDouble();
    var rng = new Random();
    for (double i = 0; i < 100; i++) {
      mEffects.add({"percent": i, "size": 5 + rng.nextInt(60 - 5).toDouble()});
    }
    effects = updateEffects(ellv * 100 / mEffects.length, euuv * 100 / mEffects.length);
  }

  @override
  void initState() {
    super.initState();
    fetchFile();
  }

  @override
  void dispose() {
    _controller.removeListener(() { });
    _controller.dispose();
    super.dispose();
  }

  String _getDurationString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  callTrim(BuildContext context) async {
    await trim();
    print ('outputFilePath $outputFilePath');
    Navigator.pop(context, outputFilePath);
  }

  trim() async {
    String filename = basename(filePath);
    //print("Filename is " + filename);
    Directory dir = await getApplicationDocumentsDirectory();
    String dirPath = dir.path;
    outputFilePath = '$dirPath/$filename';
    int start = ((ellv*fileLength)/100).round();
    int end = ((euuv*fileLength)/100).round();
    String startPos = _getDurationString(Duration(seconds: start));
    String endPos = _getDurationString(Duration(seconds: end));
    _flutterFFmpeg.execute("-ss $startPos -y -i '$filePath' -to $endPos -c copy '$outputFilePath'");
    setState(() { });
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
      : _controller.value.initialized
      ? Container(
        child: Stack(
          children: <Widget>[
            Container(
              padding: EdgeInsets.zero,
              color: Colors.black,
              child: Center(
                child: widget.fileType == "AUDIO"
                ? VideoPlayer(_controller)
                : AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            ),
            Container(
              child: Center(
                child: FloatingActionButton(
                  child: Icon(
                    _controller.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                    });
                  },
                ),
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
                  maximumDistance: maxSliderDistance.floorToDouble(),
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
                  handlerWidth: 5,
                  handlerHeight: 40,
                  touchSize: 10,
                  tooltip: FlutterSliderTooltip(
                    disabled: true,
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
                    int newPos = (b*fileLength)~/100;
                    _controller.seekTo(Duration(seconds: newPos));
                    setState(() {});
                  }
                ),
              )
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 40,
                margin: EdgeInsets.only(bottom: 0),
                color: Colors.black.withOpacity(0.5),
                child: FlatButton(
                  child: Text("Trim", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    callTrim(context);
                  },
                ),
              ),
            )
          ],
        ),
      )
      : Container(
        child: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.green
          ),
        ),
      )
    );
  }
}