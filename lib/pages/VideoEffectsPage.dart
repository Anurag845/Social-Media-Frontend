import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
//import 'package:oktoast/oktoast.dart';

class ControllerStreamUsagePage extends StatefulWidget {
  final String videoPath;

  const ControllerStreamUsagePage(this.videoPath);

  @override
  _ControllerStreamUsagePageState createState() =>
      _ControllerStreamUsagePageState();
}

class _ControllerStreamUsagePageState extends State<ControllerStreamUsagePage> {
  IjkMediaController controller = IjkMediaController();

  @override
  void initState() {
    super.initState();
    OptionUtils.addDefaultOptions(controller);
    controller.setDataSource(
      //DataSource.asset("assets/sample1.mp4"),
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
      appBar: AppBar(
        title: Text("Video Editor"),
      ),
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
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: buildAudioVolume(),
                ),
                Expanded(
                  child: Container(
                    decoration:
                        BoxDecoration(border: Border(left: _borderSlider)),
                    child: buildVideoInfo(),
                  ),
                ),
              ],
            ),
            decoration: decoration,
          ),
          buildTextureId(),
        ],
      ),
    );
  }

  Widget buildAudioVolume() {
    return Container(
      child: Column(
        children: <Widget>[
          StreamBuilder<int>(
            builder: (BuildContext context, snapshot) {
              return buildText("volume: ${snapshot.data}");
            },
            stream: controller.volumeStream,
            initialData: controller.volume,
          ),
          StreamBuilder<IjkStatus>(
            builder: (ctx, snapshot) {
              return buildText("status : ${snapshot.data}");
            },
            stream: controller.ijkStatusStream,
            initialData: controller.ijkStatus,
          ),
        ],
      ),
    );
  }

  Widget buildVideoInfo() {
    return StreamBuilder<VideoInfo>(
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData || !snapshot.data.hasData) {
          return buildText("videoInfo: null");
        }
        return buildInfo(snapshot.data);
      },
      stream: controller.videoInfoStream,
      initialData: controller.videoInfo,
    );
  }

  buildInfo(VideoInfo info) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          buildInfoText("width", info.width.toString()),
          buildInfoText("height", info.height.toString()),
          buildInfoText("degree", info.degree.toString()),
          buildInfoText("currentPosition", info.currentPosition.toString()),
          buildInfoText("totalDuration", info.duration.toString()),
          buildInfoText("tcp speed", info.tcpSpeed.toString()),
          buildInfoText("isPlaying", info.isPlaying.toString()),
        ],
      ),
    );
  }

  StreamSubscription subscription;

  subscriptPlayFinish() {
    subscription = controller.playFinishStream.listen((data) {
      //showToast(currentI18n.playFinishToast);
    });
  }

  buildTextureId() {
    var stream = StreamBuilder<int>(
      builder: (BuildContext context, snapshot) {
        return buildText("texture id = ${snapshot.data}");
      },
      initialData: controller.textureId,
      stream: controller.textureIdStream,
    );
    return Column(
      children: <Widget>[
        buildButton("change data source", changeId),
        stream,
      ],
    );
  }

  changeId() {
    controller.setDataSource(
        DataSource.network(
          "http://img.ksbbs.com/asset/Mon_1703/05cacb4e02f9d9e.mp4",
        ),
        autoPlay: true);
  }
}

Widget buildInfoText(String title, String text) {
  return Container(
    height: 20.0,
    alignment: Alignment.center,
    child: Text(
      "$title : $text",
      textAlign: TextAlign.center,
    ),
  );
}

Widget buildText(String text) {
  return Container(
    height: 60.0,
    alignment: Alignment.center,
    child: Text(
      text,
      textAlign: TextAlign.center,
    ),
  );
}

Widget buildButton(String text, Function function) {
  return OutlineButton(
    child: Text(text),
    onPressed: function,
  );
}

const decoration = BoxDecoration(
  border: Border(
    top: _borderSlider,
    bottom: _borderSlider,
    left: _borderSlider,
    right: _borderSlider,
  ),
);

const _borderSlider = BorderSide(
  color: Colors.grey,
  style: BorderStyle.solid,
  width: 1,
);

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