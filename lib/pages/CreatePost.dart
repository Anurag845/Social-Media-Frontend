import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:navras/models/UserModel.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/utils/Constants.dart';
import 'package:provider/provider.dart';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  UserModel _userModel;

  List<ListTile> options = [];

  @override
  void initState() {
    options.insert(0,ListTile(title: Text("Speak your mind"),onTap: () {},));
    options.insert(1,ListTile(title: Text("Share this moment"),onTap: () {
      Navigator.of(context).pushNamed(Constants.MomentPageRoute);
    },));
    options.insert(2,ListTile(title: Text("Share a memory"),onTap: () {
      Navigator.of(context).pushNamed(Constants.MemoryPageRoute);
    },));
    options.insert(3,ListTile(title: Text("Showcase your talent"),onTap: () {

    },));
    options.insert(4,ListTile(title: Text("I've been here"),onTap: () {},));
    options.insert(5,ListTile(title: Text("Start a story"),onTap: () {},));
    options.insert(6,ListTile(title: Text("My status today"),onTap: () {},));
    super.initState();
    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post"),
        actions: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(5),
              child: InkWell(
                child: Text("POST"),
                onTap: () {

                },
              )
            )
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget> [
                Flexible(
                  fit: FlexFit.loose,
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
                          //height: 300,
                          padding: EdgeInsets.fromLTRB(15,0,15,0),
                          child: TextField(
                            cursorColor: Colors.black,
                            decoration: InputDecoration.collapsed(
                              hintText: "What's in your mind?",
                              hintStyle: TextStyle(fontSize: 16.0)
                            ),/*InputDecoration(
                              border: new OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: new OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                            ),*/
                            keyboardType: TextInputType.multiline,
                            minLines: 5,
                            maxLines: null,
                          ),
                        )
                      )
                    ],
                  ),
                ),
              ],
            )
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.1,
            //maxChildSize: 1.0,
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.black12)
                  )
                ),
                //color: Colors.white,
                child: ListView.builder(
                  controller: controller,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return options[index];
                  }
                )
              );
            },
          )
        ]
      )
    );
  }
}