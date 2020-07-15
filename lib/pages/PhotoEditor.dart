import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lockdown_diaries/pages/CreatePostMedia.dart';
import 'package:lockdown_diaries/utils/Classes.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class Cropper extends StatefulWidget {
  final String imagePath;
  final Filter filter;

  Cropper(this.imagePath, this.filter);

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
          child: imageFile == null
          ? Container()
          : ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.filter.color1,
                  widget.filter.color2
                ]
              ).createShader(bounds);
            },
            blendMode: BlendMode.color,
            child: Image.file(imageFile),
          ),
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
                      builder: (context) => CreatePostWithMedia(filePath,widget.filter)
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