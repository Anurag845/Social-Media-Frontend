//created by Hatem Ragap
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:lockdown_diaries/models/ChatModel.dart';
import 'package:lockdown_diaries/pages/ChatMessagesPage.dart';
import 'package:lockdown_diaries/models/UserModel.dart';
import 'package:lockdown_diaries/pages/CreateRoomPage.dart';
import 'package:lockdown_diaries/utils/Constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


// ignore: must_be_immutable
class GroupChatsPage extends StatefulWidget {
  UserModel _userModel;

  GroupChatsPage(this._userModel);

  @override
  _GroupChatsPageState createState() =>
      _GroupChatsPageState();
}

class _GroupChatsPageState extends State<GroupChatsPage> {
  List<ChatModel> _listChats = [];
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  @override
  void initState() {
    super.initState();
    startGetChats();
  }

  @override
  Widget build(BuildContext context) {
    //final themeProvider = Provider.of<ThemeProvider>(context);
    var screenSize = MediaQuery.of(context).size;
    return Stack(
      children: <Widget>[
        Container(
          height: screenSize.height,
          width: screenSize.width,
          child: SmartRefresher(
            enablePullUp: false,
            header: WaterDropHeader(),
            onRefresh: _onRefresh,

            controller: _refreshController,
            child: ListView.builder(
              itemBuilder: (context, i) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      onLongPress: () {
                        if (widget._userModel.email == Constants.ADMIN_EMAIL) {
                          showDialog(
                            context: context,
                            builder: (c) {
                              return AlertDialog(
                                title: Text('are you sure to delete '),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      starDeleteRoom(_listChats[i].chatId, i);
                                    },
                                    child: Text('delete')
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('cancel')
                                  )
                                ],
                              );
                            }
                          );
                        }
                      },
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                              ChatMessagesPage(_listChats[i],'GC')
                          )
                        );
                      },
                      contentPadding: EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: CachedNetworkImage(
                          imageUrl:
                              Constants.PUBLIC_ROOMS_IMAGES + 'default-chat-room-image.jpg',
                              //_listRooms[i].img,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(_listChats[i].chatName),
                    ),
                    Divider(
                      color: Colors.blue,
                    )
                  ],
                );
              },
              itemCount: _listChats.length,
              shrinkWrap: true,
            ),
          ),
        ),
        widget._userModel.email == Constants.ADMIN_EMAIL
            ? Positioned(
                bottom: 15,
                right: 15,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_)=>CreateRoomPage()));
                  },
                  child: Icon(Icons.add,color: Colors.black,),
                ))
            : Container()
      ],
    );
  }

  startGetChats() async {
    _listChats=[];
    var req = await http.post(
      '${Constants.SERVER_URL}chats/getGroupChats',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${widget._userModel.accessToken}"
      },
    );
    var res = convert.jsonDecode(req.body);
    if (!res['error']) {
      List data = res['data'];

      List<ChatModel> temp = [];
      temp.addAll(data.map((data) => ChatModel.fromJson(data)).toList());

      setState(() {
        _listChats = temp;
        temp = null;
      });
      _refreshController.refreshCompleted();
    }
  }

  void starDeleteRoom(String id, int index) async {
    var req = await http.post(
      '${Constants.SERVER_URL}chats/deleteGroup',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${widget._userModel.accessToken}"
      },
      body: convert.jsonEncode({
        "group_id": id
      })
    );
    var res = convert.jsonDecode(req.body);
    if (!res['error']) {
      setState(() {
        _listChats.removeAt(index);
      });
      Navigator.pop(context);
    }
  }

  void _onRefresh() {
    startGetChats();
  }
}
