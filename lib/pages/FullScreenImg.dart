import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:navras/providers/Theme_provider.dart';
// ignore: must_be_immutable
class FullScreenImg extends StatelessWidget {
  String imgUrl;
  Color color1;
  Color color2;
  bool effect;

  FullScreenImg(this.imgUrl,this.effect,{this.color1,this.color2});

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);
    return Scaffold(
      //  backgroundColor: theme.getThemeData.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Full image '),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              showDialog(
                context: (context),
                builder: (context) {
                  return AlertDialog(
                    content: InkWell(
                      onTap: () {
                        checkPermissions(context);
                      },
                      child: Text('save image to gallery')
                    ),
                  );
                }
              );
            }
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: effect
          ? ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color1,
                  color2
                ]
              ).createShader(bounds);
            },
            blendMode: BlendMode.color,
            child: PhotoView(
              imageProvider: NetworkImage(imgUrl),
            ),
          )
          : PhotoView(
            imageProvider: NetworkImage(imgUrl),
          )
        ),
      ),
    );
  }

  void checkPermissions(BuildContext context) async {

    if (await Permission.storage.request().isGranted) {
      GallerySaver.saveImage(imgUrl).then((bool success) {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'image saved to your gallery !');
      });

    }
    else{
      PermissionStatus status=  await Permission.storage.request();
      if(status.isGranted){
        GallerySaver.saveImage(imgUrl).then((bool success) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: 'image saved to your gallery !');
        });
      }
      else{
        Fluttertoast.showToast(msg: 'you must accept Permission to save img ! ');
      }
    }
  }
}
