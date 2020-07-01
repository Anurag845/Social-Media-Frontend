import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:lockdown_diaries/utils/Constants.dart';
import 'package:video_trimmer/trim_editor.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_trimmer/video_viewer.dart';

class TrimmerView extends StatefulWidget {
  final Trimmer _trimmer;
  final String videoPath;
  TrimmerView(this._trimmer, this.videoPath);
  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  double _startValue = 0.0;
  double _endValue = 0.0;

  bool _isPlaying = false;
  bool _progressVisibility = false;

  String filename;
  String filepath;

  FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  Future<String> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String _value;

    await widget._trimmer
        .saveTrimmedVideo(startValue: _startValue, endValue: _endValue)
        .then((value) {
      setState(() {
        _progressVisibility = false;
        _value = value;
      });
    });

    return _value;
  }

  /*next() async {
    filename = basename(widget.videoPath);
    Directory tempDir = await getTemporaryDirectory();
    filepath = tempDir.path;

    _flutterFFmpeg.execute("-i ${widget.videoPath} -c copy -an $filepath/trimmed$filename")
    .then((rc) => print("FFmpeg process exited with rc $rc"));

    print("Received video path - ${widget.videoPath}");
    print("FFMPEG to be output - $filepath");

  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Trimmer"),
      ),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                /*RaisedButton(
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                          _saveVideo().then((outputPath) {
                            print('OUTPUT PATH: $outputPath');
                            final snackBar = SnackBar(content: Text('Video Saved successfully'));
                            Scaffold.of(context).showSnackBar(snackBar);
                          });
                        },
                  child: Text("SAVE"),
                ),*/
                Expanded(
                  child: VideoViewer(),
                ),
                Center(
                  child: TrimEditor(
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    onChangeStart: (value) {
                      _startValue = value;
                    },
                    onChangeEnd: (value) {
                      _endValue = value;
                    },
                    onChangePlaybackState: (value) {
                      setState(() {
                        _isPlaying = value;
                      });
                    },
                  ),
                ),
                FlatButton(
                  child: _isPlaying
                      ? Icon(
                          Icons.pause,
                          size: 80.0,
                          color: Colors.white,
                        )
                      : Icon(
                          Icons.play_arrow,
                          size: 80.0,
                          color: Colors.white,
                        ),
                  onPressed: () async {
                    bool playbackState =
                        await widget._trimmer.videPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    setState(() {
                      _isPlaying = playbackState;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              child: Text("NEXT"),
              onPressed: _progressVisibility
              ? null
              : () async {
                _saveVideo().then((outputPath) {
                  print('OUTPUT PATH: $outputPath');
                  Navigator.of(context).pushNamed(Constants.VideoEffectsPageRoute, arguments: outputPath);
                });
              },
            )
          ],
        ),
      ),
    );
  }
}