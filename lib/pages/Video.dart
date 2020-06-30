import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FijkPlayer player = FijkPlayer();
  String videoPath;
  File video;
  final ImagePicker _picker = ImagePicker();

  getVideo() async {
    PickedFile file = await _picker.getVideo(source: ImageSource.gallery);
    videoPath = file.path;
    setState(() {
      player.setDataSource(videoPath, autoPlay: true);
    });
  }

  @override
  void initState() {
    super.initState();
    getVideo();
    /*player.setDataSource(
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        autoPlay: true);*/
  }

  @override
  void dispose() {
    super.dispose();
    player.release();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("fijkplayer"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: FijkView(player: player),
      ),
    );
  }
}