import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class TalentVideoPreview extends StatefulWidget {
  final String videoPath;
  TalentVideoPreview(this.videoPath);
  @override
  _TalentVideoPreviewState createState() => _TalentVideoPreviewState();
}

class _TalentVideoPreviewState extends State<TalentVideoPreview> {
  IjkMediaController _controller = IjkMediaController();
  StreamSubscription subscription;

  FlutterFFmpeg _flutterFFmpeg = FlutterFFmpeg();

  FlutterFFmpegConfig _flutterFFmpegConfig = FlutterFFmpegConfig();

  subscriptPlayFinish() {
    subscription = _controller.playFinishStream.listen((data) {
      //showToast(currentI18n.playFinishToast);
    });
  }

  @override
  void initState() {
    super.initState();
    OptionUtils.addDefaultOptions(_controller);
    _controller.setDataSource(
      DataSource.file(File(widget.videoPath)),
      autoPlay: true,
    );
    subscriptPlayFinish();
  }

  @override
  void dispose() {
    subscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            child: IjkPlayer(
              mediaController: _controller,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 90,
              margin: EdgeInsets.only(bottom: 40),
              color: Colors.black.withOpacity(0.5),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: InkWell(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 50,
                            width: 50,
                            child: Center(
                              child: Icon(
                                Icons.fast_forward,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            height: 20,
                            child: Text("Speed Up", style: TextStyle(color: Colors.white),),
                          )
                        ],
                      ),
                      onTap: () {
                        _flutterFFmpegConfig.registerNewFFmpegPipe().then((pipePath) {
                          _flutterFFmpeg.execute(
                            '-i ${widget.videoPath} -filter_complex "[0:v]setpts=0.5*PTS[v];[0:a]atempo=2.0[a]" -map "[v]" -map "[a]" -f flv -y $pipePath'
                          );
                          _controller.setNetworkDataSource(pipePath, autoPlay: true);
                          subscriptPlayFinish();
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: InkWell(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 50,
                            width: 50,
                            //color: Colors.blue,
                            child: Center(
                              child: Icon(
                                Icons.rotate_right,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            height: 20,
                            child: Text("Rotate", style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                      onTap: () {
                        _flutterFFmpegConfig.registerNewFFmpegPipe().then((pipePath) {
                          _flutterFFmpeg.execute('-i ${widget.videoPath} -vf "transpose=1" -f flv -y $pipePath');
                          _controller.setNetworkDataSource(pipePath, autoPlay: true);
                          subscriptPlayFinish();
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: 50,
                          color: Colors.orange,
                        ),
                        Container(
                          height: 20,
                          child: Text("Speed Up", style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: _controller.videoInfo == null
                      ? Container()
                      : _controller.videoInfo.isPlaying
                      ? IconButton(
                        icon: Icon(
                          Icons.pause
                        ),
                        onPressed: () {
                          _controller.pause();
                        },
                      )
                      : IconButton(
                        icon: Icon(
                          Icons.play_arrow
                        ),
                        onPressed: () {
                          _controller.play();
                        },
                      )
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OptionUtils {
  static void addDefaultOptions(IjkMediaController controller) {
    controller.addIjkPlayerOptions(
      [TargetPlatform.iOS, TargetPlatform.android],
      createIJKOptions(),
    );
  }

  static Set<IjkOption> createIJKOptions() {
    return <IjkOption>[
      IjkOption(IjkOptionCategory.player, "mediacodec", 1),
      IjkOption(IjkOptionCategory.player, "mediacodec-hevc", 1),
      IjkOption(IjkOptionCategory.player, "videotoolbox", 1),
      IjkOption(IjkOptionCategory.player, "opensles", 0),
      IjkOption(IjkOptionCategory.player, "overlay-format", 0x32335652),
      IjkOption(IjkOptionCategory.player, "framedrop", 1),
      IjkOption(IjkOptionCategory.player, "start-on-prepared", 0),
      IjkOption(IjkOptionCategory.format, "http-detect-range-support", 0),
      IjkOption(IjkOptionCategory.codec, "skip_loop_filter", 48),
    ].toSet();
  }
}