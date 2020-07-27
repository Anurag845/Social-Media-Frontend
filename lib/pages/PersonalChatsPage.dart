import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:navras/models/ChatModel.dart';
import 'package:navras/models/UserModel.dart';
import 'package:navras/pages/ChatMessagesPage.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/utils/Constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class PersonalChatsPage extends StatefulWidget {
  PersonalChatsPage();

  @override
  _PersonalChatsPageState createState() => _PersonalChatsPageState();
}

class _PersonalChatsPageState extends State<PersonalChatsPage> {
  //List<ConversionModel> _listChatRooms = [];
  List<ChatModel> _listChats = [];
  RefreshController _refreshController = RefreshController(initialRefresh: false);

  UserModel _userModel;
  var textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    getChats();
  }

  @override
  void dispose() {
    super.dispose();
    textFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        if (_userModel.email == Constants.ADMIN_EMAIL) {
                          showDialog(
                            context: context,
                            builder: (c) {
                              return AlertDialog(
                                title: Text('are you sure to delete '),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      //starDeleteRoom(_listChats[i].chatId, i);
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
                              ChatMessagesPage(_listChats[i],'PC')
                          )
                        );
                      },
                      contentPadding: EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: CachedNetworkImage(
                          imageUrl:
                              Constants.USERS_PROFILES_URL + _listChats[i].chatImg,
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
      ],
    );
    //_listChatRooms = Provider.of<ConversionProvider>(context).conversionList;
    /*return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchUserPage(_userModel.userId,_userModel.email)
                )
              );
            },
            child:
              _entryField('search Users in v chat', textFieldController)
          ),
          _listChats.length == 0
          ? Container()
          : ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                ChatModel chat = _listChats[index];
                //ConversionModel _listChats = _listChatRooms[index];
                return InkWell(
                  onTap: () {
                    /*Provider.of<ConversionProvider>(context,
                                listen: false)
                            .isPeerSeeLastMessage =
                        _listChatRooms[index].isTwoUsersSeeLastMessage;*/
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                          ChatMessagesPage(chat)
                        /*MessagesPage(
                          _listChatRooms[index].chatId,
                          _listChatRooms[index].userId,
                          _listChatRooms[index].token,
                          _userModel.userId,
                          _listChatRooms[index].isLastMessageSeen,
                          _listChatRooms[index].userImg,
                          _listChatRooms[index].isOnline,
                          _listChatRooms[index].userName
                        )*/
                      )
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 7, left: 5),
                    child: ChatItem(chat, _userModel.userId)
                  )
                );
              },
              itemCount: _listChats.length,
            ),
        ],
      ),
    );*/
  }

  /*Widget _entryField(String title, controller, {bool isPassword = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            enabled: false,
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: InputBorder.none, hintText: title, filled: true
            )
          )
        ],
      ),
    );
  }*/

  getChats() async {
    var req = await http.post(
      '${Constants.SERVER_URL}chats/getPersonalChats',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${_userModel.accessToken}"
      },
      body: convert.jsonEncode({
        'user_id': _userModel.userId
      })
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

  void _onRefresh() {
    getChats();
  }
}
