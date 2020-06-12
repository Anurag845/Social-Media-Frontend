import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lockdown_diaries/utils/Constants.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/photofilters.dart';

class Moment extends StatefulWidget {

  @override
  _MomentState createState() => _MomentState();
}

class _MomentState extends State<Moment> {

  File imageFile;
  String filePath;
  var image;
  String fileName;
  bool empty = true;
  bool loading = false;

  getImage() async {
    File imagefile;
    imagefile = await ImagePicker.pickImage(source:ImageSource.camera);
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
        loading = true;
        imageFile = tempImage;
        filePath = tempImage.path;
        fileName = filename;
      });
    }
  }

  @override
  void initState() {
    empty = true;
    loading = false;
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
          child: empty
          ? Container(
            child: FlatButton(
              color: Colors.cyan[200],
              onPressed: getImage,
              child: Text("Select Image"),
            ),
          )
          : Container(
            child: imageFile == null
            ? CircularProgressIndicator()
            : Image.file(imageFile),
          )
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
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