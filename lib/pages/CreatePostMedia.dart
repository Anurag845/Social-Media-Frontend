import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lockdown_diaries/models/CategoryModel.dart';
import 'package:lockdown_diaries/models/UserModel.dart';
import 'package:lockdown_diaries/pages/ChipPage.dart';
import 'package:lockdown_diaries/providers/AuthProvider.dart';
import 'package:lockdown_diaries/providers/CategoryProvider.dart';
import 'package:lockdown_diaries/providers/PostProvider.dart';
import 'package:lockdown_diaries/utils/Classes.dart';
import 'package:lockdown_diaries/utils/Constants.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'dart:convert' as convert;

class CreatePostWithMedia extends StatefulWidget {
  final String filePath;
  final Filter filter;

  CreatePostWithMedia(this.filePath, this.filter);

  @override
  _CreatePostWithMediaState createState() => _CreatePostWithMediaState();
}

class _CreatePostWithMediaState extends State<CreatePostWithMedia> {
  UserModel _userModel;
  File mediaFile;
  TextEditingController postTextController = TextEditingController();
  CategoryModel category;
  List<ListTile> options = [];

  List<Chip> categories = [];

  @override
  void initState() {
    options.insert(0,ListTile(title: Text("Speak your mind"),onTap: () {},));
    options.insert(1,ListTile(title: Text("Share this moment"),onTap: () {
      Navigator.of(context).pushNamed(Constants.MomentPageRoute);
    },));
    options.insert(2,ListTile(title: Text("Share a memory"),onTap: () {
      Navigator.of(context).pushNamed(Constants.MemoryPageRoute);
    },));
    options.insert(3,ListTile(title: Text("Showcase your talent"),onTap: () {},));
    options.insert(4,ListTile(title: Text("I've been here"),onTap: () {},));
    options.insert(5,ListTile(title: Text("Start a story"),onTap: () {},));
    options.insert(6,ListTile(title: Text("My status today"),onTap: () {},));
    super.initState();
    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    mediaFile = File(widget.filePath);
    Provider.of<CategoryProvider>(context, listen: false).
        getAllCategories(_userModel.accessToken);
  }

  uploadFile() async {
    try{
      var stream = new http.ByteStream(mediaFile.openRead().cast());
      var length = await mediaFile.length();
      var uri = Uri.parse("${Constants.SERVER_URL}post/create");
      var request = http.MultipartRequest('POST', uri);
      var multipartFile = new http.MultipartFile('attachments', stream, length,
          filename: path.basename(mediaFile.path));
      request.files.add(multipartFile);
      request.fields.addAll({
        "user_id": _userModel.userId,
        "descr": '${postTextController.text}',
        "effect_id": widget.filter.effectId,
        "effect_name": widget.filter.effectName,
        "color1": '${widget.filter.color1.value}',
        "color2": '${widget.filter.color2.value}'
      });
      request.headers.addAll({
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${_userModel.accessToken}"
      });

      var response = await request.send();

      response.stream.transform(convert.utf8.decoder).listen((value) async {
        try {
          var jsonResponse = await convert.jsonDecode(value);
          bool error = jsonResponse['error'];
          if (error == false) {
            Provider.of<PostProvider>(context, listen: false)
                .startGetPostsData(_userModel.userId,_userModel.accessToken);
            Fluttertoast.showToast(msg: ' done ...');
            postTextController.clear();
            Fluttertoast.showToast(msg: ' done ...');
            Navigator.pop(context);
          }
          else {
            print('error! ' + jsonResponse);

            Fluttertoast.showToast(
              msg: "unkown error !" + jsonResponse,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
            );
          }
        }
        catch (err) {
          print(err);
          print(value);
          Fluttertoast.showToast(
            msg: "unkown error ! check your connection",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
          );
        }
      });
    }
    catch(error) {
      print(error);
    }
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
                onTap: uploadFile
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
                            controller: postTextController,
                            cursorColor: Colors.black,
                            decoration: InputDecoration.collapsed(
                              hintText: "Write something about this",
                              hintStyle: TextStyle(fontSize: 16.0)
                            ),/*InputDecoration(
                              border: new OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: new OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                            ),*/
                            keyboardType: TextInputType.multiline,
                            minLines: null,
                            maxLines: null,
                          ),
                        )
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: mediaFile == null
                        ? Container(
                          child: Center(
                            child: CircularProgressIndicator(backgroundColor: Colors.green),
                          ),
                        )
                        : Container(
                          child: ShaderMask(
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
                            child: Center(
                              child: Image.file(mediaFile),
                            ),
                          )
                        )
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(25,25,25,25),
                          child: InkWell(
                            child: Text(
                              category == null
                              ? "What is this about?"
                              : category.categoryName,
                              style: TextStyle(fontSize: 16),
                            ),
                            onTap: () async {
                              final cat = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChoiceChipDisplay()
                                )
                              );
                              setState(() {
                                category = cat;
                              });
                            },
                          )
                        )
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          //height: 300,
                          padding: EdgeInsets.fromLTRB(15,0,15,0),
                          child: TextField(
                            cursorColor: Colors.black,
                            decoration: InputDecoration.collapsed(
                              hintText: "How did this make you feel?",
                              hintStyle: TextStyle(fontSize: 16.0)
                            ),/*InputDecoration(
                              border: new OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: new OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                            ),*/
                            keyboardType: TextInputType.multiline,
                            minLines: null,
                            maxLines: null,
                          ),
                        )
                      ),
                    ],
                  ),
                ),
              ],
            )
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.1,
            maxChildSize: 0.75,
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