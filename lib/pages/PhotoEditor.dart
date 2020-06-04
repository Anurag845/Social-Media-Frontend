import 'dart:io';

import 'package:flutter/material.dart';

class PhotoEditor extends StatefulWidget {
  String imagePath;

  PhotoEditor(this.imagePath);

  @override
  _PhotoEditorState createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  File imageFile;

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
}