import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:navras/pages/TrimmerPage.dart';
import 'package:navras/utils/Constants.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/photofilters.dart';
import 'package:video_trimmer/video_trimmer.dart';

class Memory extends StatefulWidget {

  @override
  _MemoryState createState() => _MemoryState();
}

class _MemoryState extends State<Memory> {

  File imageFile;
  final picker = ImagePicker();
  File videoFile;
  //VideoPlayerController _videoPlayerController;
  String filePath;
  var image;
  String fileName;
  bool empty = true;
  String fileType = "";
  final Trimmer _trimmer = Trimmer();

  getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    File imagefile = File(pickedFile.path);
    String filename = path.basename(imagefile.path);
    image = imageLib.decodeImage(imagefile.readAsBytesSync());
    image = imageLib.copyResize(image, width: 600);
    setState(() {
      empty = false;
      imageFile = File(pickedFile.path);
      fileName = filename;
    });
  }

  getVideo() async {
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);
    videoFile = File(pickedFile.path);
    if (videoFile != null) {
      await _trimmer.loadVideo(videoFile: videoFile);
      String filename = path.basename(videoFile.path);
      Directory tempDir = await getTemporaryDirectory();
      String filepath = tempDir.path;
      File video = await videoFile.copy('$filepath/captured$filename');
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) {
        return TrimmerView(_trimmer, video.path);
      }));
    }
  }

  @override
  void initState() {
    empty = true;
    super.initState();
  }

  void dispose() {
    //_videoPlayerController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return(await showDialog(
        context: context,
        builder: (context) => new AlertDialog(
          title: new Text('Are you sure?'),
          content: new Text('Do you want to discard this memory?'),
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
          title: Text("Share this moment"),
        ),
        body: Center(
          child: empty
          ? Container(
            //color: Colors.deepOrange,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  color: Colors.cyan[200],
                  onPressed: () {
                    getImage();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(
                        Icons.photo
                      ),
                      Text("Photo")
                    ],
                  ),
                ),
                RaisedButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  color: Colors.cyan[200],
                  onPressed: () {
                    getVideo();
                    /*Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MyHomePage())
                    );*/
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(
                        Icons.video_call
                      ),
                      Text("Video")
                    ],
                  ),
                )
              ],
            ),
          )
          : imageFile == null
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.green,
              ),
            )
          : Image.file(imageFile),
          /*: fileType == "image"
          ? Container(
            child: imageFile == null
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.green,
                ),
              )
            : Image.file(imageFile),
          )
          : _videoPlayerController == null
          ? Container(
            child: CircularProgressIndicator(
              backgroundColor: Colors.green,
            ),
          )
          : _videoPlayerController.value.initialized
          ? AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController),
          )
          : Container(
            child: CircularProgressIndicator(
              backgroundColor: Colors.green,
            ),
          )*/
        ),
        /*floatingActionButton: FloatingActionButton(
          onPressed: empty
          ? () {}
          : () {
            setState(() {
              _videoPlayerController.value.isPlaying
                ? _videoPlayerController.pause()
                : _videoPlayerController.play();
            });
          },
          child: _videoPlayerController == null
          ? Container()
          : Icon(
            _videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
          )
        ),*/
        bottomNavigationBar: empty
        ? BottomAppBar(

        )
        : BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            //textDirection: TextDirection.,
            children: <Widget>[
              FlatButton(
                onPressed: () async {
                  Map imagefile = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoFilterSelector(
                        title: Text("Apply filters"),
                        image: image,
                        filters: presetFiltersList,
                        filename: fileName,
                        loader: Center(child: CircularProgressIndicator()),
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                  if(imagefile != null && imagefile.containsKey('image_filtered')) {
                    imageFile = imagefile['image_filtered'];
                    String filename = path.basename(imageFile.path);
                    print("Filename from photo filter" + filename);
                    Directory tempDir = await getTemporaryDirectory();
                    String filepath = tempDir.path;
                    File tempImage = await imageFile.copy('$filepath/$filename');
                    Navigator.of(context).pushReplacementNamed(
                      Constants.PhotoEditorPageRoute,
                      arguments: tempImage.path
                    );
                    /*Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Cropper(tempImage.path))
                    );*/
                  }
                },
                child: Text("NEXT"),
              )
            ],
          ),
        ),
      ),
    );
  }
}