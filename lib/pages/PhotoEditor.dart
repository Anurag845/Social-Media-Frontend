/*import 'dart:io';
//import 'package:image_editor_pro/image_editor_pro.dart';
import 'package:flutter/material.dart';

class PhotoEditor extends StatefulWidget {
  final String imagePath;

  PhotoEditor(this.imagePath);

  @override
  _PhotoEditorState createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  File imageFile;
  File _image;

  Future getImage() async {
    imageFile = File(widget.imagePath);
  }

  @override
  void initState() {
    super.initState();
    getImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photo Editor"),
      ),
      body: Center(
        child: new Container(
          child: imageFile == null
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.green,
              ),
            )
          : Image.file(imageFile),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              onPressed: () {

              },
              child: Text("NEXT"),
            )
          ],
        ),
      ),
    );
  }
}*/

/*import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:crop/crop.dart';

class CropPage extends StatefulWidget {
  static final String path = "lib/src/pages/misc/crop.dart";
  @override
  _CropPageState createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  final _cropKey = GlobalKey<CropState>();
  double _rotation = 0;

  void _cropImage() async {
    final cropped = await _cropKey.currentState.crop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Crop Result'),
            centerTitle: true,
          ),
          body: Center(
            child: RawImage(
              image: cropped,
            ),
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Demo'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: _cropImage,
            tooltip: 'Crop',
            icon: Icon(Icons.crop),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Crop(
              key: _cropKey,
              child: Image.asset('assets/images/cover.jpg'),
              aspectRatio: 1920 / 1280.0,
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.undo),
                tooltip: 'Undo',
                onPressed: () {
                  _cropKey.currentState.rotation = 0;
                  _cropKey.currentState.scale = 1;
                  _cropKey.currentState.offset = Offset.zero;
                  setState(() {
                    _rotation = 0;
                  });
                },
              ),
              Expanded(
                child: SliderTheme(
                  data: theme.sliderTheme.copyWith(
                    trackShape: CenteredRectangularSliderTrackShape(),
                  ),
                  child: Slider(
                    divisions: 91,
                    value: _rotation,
                    min: -45,
                    max: 45,
                    label: '$_rotation°',
                    onChanged: (n) {
                      setState(() {
                        _rotation = n.roundToDouble();
                        _cropKey.currentState.rotation = _rotation;
                      });
                    },
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.aspect_ratio),
                tooltip: 'Aspect Ratio',
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CenteredRectangularSliderTrackShape extends RectangularSliderTrackShape {
  @override
  void paint(PaintingContext context, ui.Offset offset,
      {RenderBox parentBox,
      SliderThemeData sliderTheme,
      Animation<double> enableAnimation,
      ui.Offset thumbCenter,
      bool isEnabled: false,
      bool isDiscrete: false,
      ui.TextDirection textDirection}) {
    // If the slider track height is less than or equal to 0, then it makes no
    // difference whether the track is painted or not, therefore the painting
    // can be a no-op.
    if (sliderTheme.trackHeight <= 0) {
      return;
    }

    // Assign the track segment paints, which are left: active, right: inactive,
    // but reversed for right to left text.
    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation);
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation);

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final trackCenter = trackRect.center;
    final Size thumbSize =
        sliderTheme.thumbShape.getPreferredSize(isEnabled, isDiscrete);
    // final Rect leftTrackSegment = Rect.fromLTRB(
    //     trackRect.left + trackRect.height / 2,
    //     trackRect.top,
    //     thumbCenter.dx - thumbSize.width / 2,
    //     trackRect.bottom);
    // if (!leftTrackSegment.isEmpty)
    //   context.canvas.drawRect(leftTrackSegment, leftTrackPaint);
    // final Rect rightTrackSegment = Rect.fromLTRB(
    //     thumbCenter.dx + thumbSize.width / 2,
    //     trackRect.top,
    //     trackRect.right,
    //     trackRect.bottom);
    // if (!rightTrackSegment.isEmpty)
    //   context.canvas.drawRect(rightTrackSegment, rightTrackPaint);

    if (trackCenter.dx < thumbCenter.dx) {
      final Rect leftTrackSegment = Rect.fromLTRB(
          trackRect.left,
          trackRect.top,
          min(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
          trackRect.bottom);
      if (!leftTrackSegment.isEmpty)
        context.canvas.drawRect(leftTrackSegment, inactivePaint);

      final activeRect = Rect.fromLTRB(
          trackCenter.dx, trackRect.top, thumbCenter.dx, trackRect.bottom);
      if (!activeRect.isEmpty) {
        context.canvas.drawRect(activeRect, activePaint);
      }

      final Rect rightTrackSegment = Rect.fromLTRB(
          thumbCenter.dx + thumbSize.width / 2,
          trackRect.top,
          trackRect.right,
          trackRect.bottom);
      if (!rightTrackSegment.isEmpty) {
        context.canvas.drawRect(rightTrackSegment, inactivePaint);
      }
    } else if (trackCenter.dx > thumbCenter.dx) {
      final Rect leftTrackSegment = Rect.fromLTRB(trackRect.left, trackRect.top,
          thumbCenter.dx + thumbSize.width / 2, trackRect.bottom);
      if (!leftTrackSegment.isEmpty) {
        context.canvas.drawRect(leftTrackSegment, inactivePaint);
      }

      final activeRect = Rect.fromLTRB(
          thumbCenter.dx, trackRect.top, trackCenter.dx, trackRect.bottom);
      if (!activeRect.isEmpty) {
        context.canvas.drawRect(activeRect, activePaint);
      }

      final Rect rightTrackSegment = Rect.fromLTRB(
          min(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
          trackRect.top,
          trackRect.right,
          trackRect.bottom);
      if (!rightTrackSegment.isEmpty) {
        context.canvas.drawRect(rightTrackSegment, inactivePaint);
      }
    } else {
      final Rect leftTrackSegment = Rect.fromLTRB(
          trackRect.left,
          trackRect.top,
          min(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
          trackRect.bottom);
      if (!leftTrackSegment.isEmpty) {
        context.canvas.drawRect(leftTrackSegment, inactivePaint);
      }

      final Rect rightTrackSegment = Rect.fromLTRB(
          min(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
          trackRect.top,
          trackRect.right,
          trackRect.bottom);
      if (!rightTrackSegment.isEmpty) {
        context.canvas.drawRect(rightTrackSegment, inactivePaint);
      }
    }
  }
}*/

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lockdown_diaries/pages/CreatePostMedia.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class Cropper extends StatefulWidget {
  final String imagePath;

  Cropper(this.imagePath);

  @override
  _CropperState createState() => _CropperState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _CropperState extends State<Cropper> {
  AppState state;
  File imageFile;
  String filePath;

  @override
  void initState() {
    super.initState();
    imageFile = File(widget.imagePath);
    state = AppState.picked;
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text('Are you sure?'),
          content: new Text('Do you want to discard this moment?'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: new Text('No'),
            ),
            new FlatButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: new Text('Yes'),
            ),
          ],
        ),
      )
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Title"),
        ),
        body: Center(
          child: imageFile != null ? Image.file(imageFile) : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.deepOrange,
          onPressed: () {
            if (state == AppState.free)
              _pickImage();
            else if (state == AppState.picked)
              _cropImage();
            else if (state == AppState.cropped) _clearImage();
          },
          child: _buildButtonIcon(),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                onPressed: () async {
                  String filename = path.basename(imageFile.path);
                  Directory tempDir = await getApplicationDocumentsDirectory();
                  String filepath = tempDir.path;
                  File tempFile = await imageFile.copy('$filepath/$filename');
                  filePath = tempFile.path;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => CreatePostWithMedia(filePath)
                    )
                  );
                },
                child: Text("NEXT"),
              )
            ],
          ),
        ),
      )
    );
  }

  Widget _buildButtonIcon() {
    if (state == AppState.free)
      return Icon(Icons.add);
    else if (state == AppState.picked)
      return Icon(Icons.crop);
    else if (state == AppState.cropped)
      return Icon(Icons.clear);
    else
      return Container();
  }

  Future<Null> _pickImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
      });
    }
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: Platform.isAndroid
        ? [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ]
        : [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio5x3,
            CropAspectRatioPreset.ratio5x4,
            CropAspectRatioPreset.ratio7x5,
            CropAspectRatioPreset.ratio16x9
          ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        title: 'Cropper',
      )
    );
    if (croppedFile != null) {
      imageFile = croppedFile;

      setState(() {
        state = AppState.cropped;
      });
    }
  }

  void _clearImage() {
    imageFile = null;
    setState(() {
      state = AppState.free;
    });
  }
}