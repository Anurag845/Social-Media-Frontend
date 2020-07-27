import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:navras/models/UserModel.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/providers/GroupProvider.dart';
import 'package:navras/utils/Constants.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:path/path.dart' as Path;

class CreateGroupPage extends StatefulWidget {
  final int categoryId;

  CreateGroupPage(this.categoryId);

  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {

  File groupImage;
  UserModel _userModel;
  String privacy = "private";
  TextEditingController nameController = TextEditingController();
  bool _disable = true;

  @override
  void initState() {
    super.initState();
    _disable = true;
    nameController.addListener(_buttonState);
    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
  }

  _radioHandler(String value) {
    setState(() {
      privacy = value;
    });
  }

  _buttonState() {
    if(nameController.text == "") {
      setState(() {
        _disable = true;
      });
    }
    else {
      setState(() {
        _disable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Group"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      height: 55,
                      child: Text(
                        "Name",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 90,
                      padding: EdgeInsets.fromLTRB(15, 5, 15, 10),
                      child: TextField(
                        controller: nameController,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.black),
                        cursorColor: Colors.black45,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: "Name your group",
                          focusedBorder: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Divider(
              thickness: 2,
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15,10,15,5),
                      height: 55,
                      child: Text(
                        "Cover Photo",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 15, 0),
                            child: InkWell(
                              onTap: () {
                                startPickImage();
                              },
                              child: Icon(
                                Icons.add_a_photo
                              ),
                            )
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Text(
                              "Add Cover Photo",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Divider(
              thickness: 2,
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15,10,15,5),
                      height: 55,
                      child: Text(
                        "Privacy",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.public,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(
                      "Public",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Anyone can see who's in the group and what they post"
                    ),
                    trailing: Radio(
                      activeColor: Colors.lightBlue,
                      value: "public",
                      groupValue: privacy,
                      onChanged: _radioHandler,
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.all(7),
                  ),
                  ListTile(
                    leading: Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        Icons.lock,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(
                      "Private",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Only members can see who's in the group and what they post"
                    ),
                    trailing: Radio(
                      activeColor: Colors.lightBlue,
                      value: "private",
                      groupValue: privacy,
                      onChanged: _radioHandler,
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.all(7),
                  )
                ],
              ),
            ),
            Divider(
              thickness: 2,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: FlatButton(
                  color: Colors.lightBlue,
                  onPressed: _disable ? null : () {
                    _createGroup();
                  },
                  child: Text(
                    "Create Group",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        )
      )
    );
  }

   void startPickImage() async {
    groupImage = await ImagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {

    });
  }

  _createGroup() async {
    if(nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please enter group name");
    }
    else if(groupImage == null){
      var req = await http.post(
        "${Constants.SERVER_URL}groups/createGroup",
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer ${_userModel.accessToken}"
        },
        body: convert.jsonEncode({
          "user_id": _userModel.userId,
          "group_name": "${nameController.text}"
        })
      );
      var res = convert.jsonDecode(req.body);
      if(!res["error"]) {
        Fluttertoast.showToast(msg: "Group created");
        Navigator.of(context).pop();
      }
    }
    else {
      String _url = "${Constants.SERVER_URL}groups/createGroup";
      var stream = new http.ByteStream(groupImage.openRead().cast());
      var length = await groupImage.length();
      var uri = Uri.parse(_url);
      var request = new http.MultipartRequest("POST", uri);

      var multipartFile = new http.MultipartFile('group_image', stream, length,
          filename: Path.basename(groupImage.path));
      request.files.add(multipartFile);
      request.fields.addAll({
        "user_id": _userModel.userId,
          "group_name": "${nameController.text}"
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
            Provider.of<GroupProvider>(context, listen: false)
                .getUserGroupsbyCategory(_userModel.userId,_userModel.accessToken,widget.categoryId);
            Fluttertoast.showToast(msg: 'Group created');
            nameController.clear();
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
              fontSize: 16.0);
        }
        finally {
          setState(() {

          });
        }
      });
    }
  }
}