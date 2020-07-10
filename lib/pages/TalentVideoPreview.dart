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
    //OptionUtils.addDefaultOptions(controller);
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
      body: ListView(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1280 / 720,
            child: IjkPlayer(
              mediaController: controller,
              controllerWidgetBuilder: (ctl) {
                return DefaultIJKControllerWidget(
                  controller: ctl,
                  volumeType: VolumeType.media,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}