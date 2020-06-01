import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lockdown_diaries/models/UserModel.dart';
import 'package:lockdown_diaries/providers/AuthProvider.dart';
import 'package:lockdown_diaries/utils/Constants.dart';
import 'package:provider/provider.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  UserModel _userModel;

  @override
  void initState() {
    super.initState();
    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: Constants.USERS_PROFILES_URL + _userModel.img,
                          placeholder: (context,url) => Center(
                            child:CircularProgressIndicator(
                              backgroundColor: Colors.green,
                            )
                          ),
                          errorWidget: (context,url,error) => new Icon(Icons.error),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        _userModel.displayName,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 400,
                padding: EdgeInsets.all(10),
                child: TextField(
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    border: new OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: new OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 10,
                  maxLines: null,
                ),
              )
            )
          ],
        )
      )
    );
  }
}