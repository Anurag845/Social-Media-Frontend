import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';

class TalentVideoPreview extends StatefulWidget {
  final String videoPath;
  TalentVideoPreview(this.videoPath);
  @override
  _TalentVideoPreviewState createState() => _TalentVideoPreviewState();
}

class _TalentVideoPreviewState extends State<TalentVideoPreview> {
  IjkMediaController controller = IjkMediaController();
  StreamSubscription subscription;

  subscriptPlayFinish() {
    subscription = controller.playFinishStream.listen((data) {
      //showToast(currentI18n.playFinishToast);
    });
  }

  @override
  void initState() {
    super.initState();
    OptionUtils.addDefaultOptions(controller);
    controller.setDataSource(
      DataSource.file(File(widget.videoPath)),
      autoPlay: true,
    );
    subscriptPlayFinish();
  }

  @override
  void dispose() {
    subscription?.cancel();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            child: IjkPlayer(
              mediaController: controller,
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
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: 50,
                          color: Colors.white,
                        ),
                        Container(
                          height: 20,
                          child: Text("Speed Up", style: TextStyle(color: Colors.white),),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: 50,
                          color: Colors.blue,
                        ),
                        Container(
                          height: 20,
                          child: Text("Speed Up"),
                        )
                      ],
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
                          child: Text("Speed Up"),
                        )
                      ],
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