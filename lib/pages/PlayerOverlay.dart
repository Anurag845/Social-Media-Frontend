import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';

class OverlayWidget extends StatefulWidget {
  final VideoInfo initVideoInfo;
  final IjkMediaController controller;
  final Function onTapClose;

  const OverlayWidget({
    Key key,
    this.initVideoInfo,
    this.controller,
    this.onTapClose,
  }) : super(key: key);

  @override
  _OverlayWidgetState createState() => _OverlayWidgetState();
}

const double _overlayWidth = 120;
const double _overlayHeight = 150;

class _OverlayWidgetState extends State<OverlayWidget> {
  double dx = 0;
  double dy = 1;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OffsetNotification>(
      onNotification: _onOffsetNotification,
      child:
      Padding(
        padding: EdgeInsets.only(top:50, left: 20),
        child: 
      Align(
        // alignment: Alignment(dx, dy),
        alignment: Alignment.topLeft,
        child: Container(
          width: _overlayWidth,
          height: _overlayHeight,
          child: AspectRatio(
            aspectRatio: widget.initVideoInfo.ratio,
            child: Opacity(
              opacity: 0.75,
              child: IjkPlayer(
              mediaController: widget.controller,
              controllerWidgetBuilder: (ctl) {
                return OverlayControllerWidget(
                  controller: ctl,
                  onTapClose: widget.onTapClose,
                );
              },
            )),
          ),
        ),
      ),
    ));
  }

  Offset _startOffset;

  bool _onOffsetNotification(OffsetNotification notification) {
    if (notification.type == OffsetType.start) {
      _startOffset = Offset(dx, dy);
      return true;
    }

    var offset = notification.offset;

    var size = MediaQuery.of(context).size;

    dx = _startOffset.dx + offset.dx / size.width * 2;
    dy = _startOffset.dy + offset.dy / size.height * 2;

    print("dx = $dx");
    print("dy = $dy");

    if (dx > 1) {
      dx = 1;
    } else if (dx < -1) {
      dx = -1;
    }

    if (dy > 1) {
      dy = 1;
    } else if (dy < -1) {
      dy = -1;
    }

    setState(() {});
    return true;
  }
}

class OverlayControllerWidget extends StatefulWidget {
  final IjkMediaController controller;
  final Function onTapClose;

  const OverlayControllerWidget({
    Key key,
    this.controller,
    this.onTapClose,
  }) : super(key: key);

  @override
  _OverlayControllerWidgetState createState() =>
      _OverlayControllerWidgetState();
}

class _OverlayControllerWidgetState extends State<OverlayControllerWidget> {
  bool showController = false;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (!showController) {
      child = Container();
    } else {
      child = Container(
        color: Colors.black.withOpacity(0.6),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.close),
              onPressed: widget.onTapClose,
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      child: child,
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => showController = !showController),
      // onPanUpdate: (detail) {
      //   var notification = OffsetNotification()
      //     ..offset = detail.delta
      //     ..type = OffsetType.update;
      //   notification.dispatch(context);
      // },

      // onPanStart: (detail) {
      //   var notication = OffsetNotification()..type = OffsetType.start;
      //   notication.dispatch(context);
      // },
      onLongPressMoveUpdate: (detail) {
        var notification = OffsetNotification()
          ..offset = detail.offsetFromOrigin
          ..type = OffsetType.update;
        notification.dispatch(context);
      },
      onLongPressStart: (detail) {
        var n = OffsetNotification()..type = OffsetType.start;
        n.dispatch(context);
      },
    );
  }
}

class OffsetNotification extends Notification {
  Offset offset;

  OffsetType type;
}

enum OffsetType {
  start,
  update,
}