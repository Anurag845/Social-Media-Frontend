import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File videoFile;
  String filePath;

  VideoPlayerController _videoPlayerController;

  getVideo() async {
    File video = await ImagePicker.pickVideo(source: ImageSource.gallery);
    videoFile = video;
    _videoPlayerController = VideoPlayerController.file(videoFile)..initialize().then((_) {
      setState(() {

      });
    });
  }

  @override
  void initState() {
    getVideo();
    super.initState();
  }

  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video"),
      ),
      body: Center(
        child: _videoPlayerController == null
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
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
      ),
    );
  }
}