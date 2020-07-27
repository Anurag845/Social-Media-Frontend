import 'dart:io';

import 'package:flutter/material.dart';
import 'package:navras/utils/Classes.dart';
import 'package:navras/utils/Constants.dart';
import 'package:photo_view/photo_view.dart';

class MomentPreview extends StatefulWidget {
  final String imagePath;
  final Filter filter;

  MomentPreview(this.imagePath, this.filter);

  @override
  _MomentPreviewState createState() => _MomentPreviewState();
}

class _MomentPreviewState extends State<MomentPreview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.filter.color1,
              widget.filter.color2
            ]
          ).createShader(bounds);
        },
        blendMode: BlendMode.color,
        child: PhotoView(
          imageProvider: FileImage(File(widget.imagePath)),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black.withOpacity(0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              child: Text("Proceed",style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                  Constants.PhotoEditorPageRoute,
                  arguments: PhotoEffectArgs(widget.imagePath,widget.filter)
                );
              },
            )
          ],
        ),
      ),
    );
  }
}