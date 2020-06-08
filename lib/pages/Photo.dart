import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lockdown_diaries/pages/PhotoEditor.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/photofilters.dart';

class Photo extends StatefulWidget {
  final ImageSource imageSource;

  Photo(this.imageSource);

  @override
  _PhotoState createState() => _PhotoState();
}

class _PhotoState extends State<Photo> {

  File imageFile;
  String filePath;
  var image;
  String fileName;
  bool empty = false;

  Future getImage() async {
    File imagefile;
    imagefile = await ImagePicker.pickImage(source: widget.imageSource);
    if(imagefile == null) {
      setState(() {
        empty = true;
      });
    }
    else {
      String filename = path.basename(imagefile.path);
      image = imageLib.decodeImage(imagefile.readAsBytesSync());
      image = imageLib.copyResize(image, width: 600);
      Directory tempDir = await getTemporaryDirectory();
      String filepath = tempDir.path;
      File tempImage = await imagefile.copy('$filepath/$filename');
      setState(() {
        imageFile = tempImage;
        filePath = tempImage.path;
        fileName = filename;
      });
    }
  }

  @override
  void initState() {
    empty = false;
    super.initState();
    getImage();
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
                  if (imagefile != null && imagefile.containsKey('image_filtered')) {
                    imageFile = imagefile['image_filtered'];
                    String filename = path.basename(imageFile.path);
                    Directory tempDir = await getTemporaryDirectory();
                    String filepath = tempDir.path;
                    File tempImage = await imageFile.copy('$filepath/$filename');
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Cropper(tempImage.path))
                    );
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