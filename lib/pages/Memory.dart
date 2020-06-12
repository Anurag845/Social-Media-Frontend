import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lockdown_diaries/utils/Constants.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/photofilters.dart';

class Memory extends StatefulWidget {

  @override
  _MemoryState createState() => _MemoryState();
}

class _MemoryState extends State<Memory> {

  File imageFile;
  String filePath;
  var image;
  String fileName;
  bool empty = true;
  String fileType = "";

  Future getImage() async {
    File imagefile;
    imagefile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(imagefile == null) {
      setState(() {
        empty = true;
      });
    }
    else {
      String filename = path.basename(imagefile.path);
      print("File name from imagepicker:- " + filename);
      image = imageLib.decodeImage(imagefile.readAsBytesSync());
      image = imageLib.copyResize(image, width: 600);
      Directory tempDir = await getTemporaryDirectory();
      String filepath = tempDir.path;
      File tempImage = await imagefile.copy('$filepath/$filename');
      setState(() {
        empty = false;
        fileType = "image";
        imageFile = tempImage;
        filePath = tempImage.path;
        fileName = filename;
      });
    }
  }

  @override
  void initState() {
    empty = true;
    super.initState();
    //getImage();
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
                  onPressed: () {},
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
          : fileType == "image"
          ? Container(
            child: imageFile == null
            ? Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.green,
                ),
              )
            : Image.file(imageFile),
          )
          : Container()
        ),
        bottomNavigationBar: empty
        ? Container()
        : BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            //textDirection: TextDirection.,
            children: <Widget>[
              FlatButton(
                onPressed: fileType == "image"
                  ? () async {
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
                }
                : () {

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