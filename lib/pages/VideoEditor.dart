import 'package:flutter/material.dart';

class VideoEditor extends StatefulWidget {
  @override
  _VideoEditorState createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Editor"),
      ),
      body: Container(),
    );
  }
}