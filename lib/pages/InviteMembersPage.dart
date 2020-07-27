import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:navras/models/UserModel.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/providers/GroupProvider.dart';
import 'package:navras/utils/Constants.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class InviteMembersPage extends StatefulWidget {
  final String groupId;
  InviteMembersPage(this.groupId);
  @override
  _InviteMembersPageState createState() => _InviteMembersPageState();
}

class _InviteMembersPageState extends State<InviteMembersPage> {

  UserModel _userModel;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  TextEditingController searchController;
  List<UserModel> _inviteList = [];
  //List<UserModel> _duplicateList = [];
  bool sendingRequest;

  List<String> invited = [];
  List<bool> enable = [];

  @override
  void initState() {
    super.initState();
    sendingRequest = false;
    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    Provider.of<GroupProvider>(context, listen: false)
        .getInviteList(_userModel.userId, widget.groupId, _userModel.accessToken);
  }

  _refresh() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invite Members"),
        /*actions: <Widget>[
          FlatButton(
            onPressed: () {
              sendInvite(invited);
            },
            child: Text("Done"),
          )
        ],*/
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            /*Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
                height: 50,
                child: Text(
                  "Suggestions",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ),
                ),
              )
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: TextField(
                  controller: searchController,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.black),
                  cursorColor: Colors.black45,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(5),
                    border: const OutlineInputBorder(),
                    hintText: "Search among friends",
                    focusedBorder: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    filterList(value);
                  },
                ),
              )
            ),*/
            Expanded(
              child: Consumer<GroupProvider>(builder: (context, groupProvider, child) {
                _inviteList = groupProvider.inviteList;
                /*_duplicateList.addAll(_inviteList);
                enable = List.filled(_inviteList.length, true);*/

                if(sendingRequest) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                else {
                  return ListView.separated(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: _inviteList.length,
                    separatorBuilder: (context, i) {
                      return SizedBox(
                        height: 20,
                      );
                    },
                    itemBuilder: (context, i) {
                      return ListTile(
                        leading: ClipOval(
                          child: CachedNetworkImage(
                            height: 50,
                            imageUrl: Constants.USERS_PROFILES_URL + _inviteList[i].img,
                            placeholder: (context,url) => Center(
                              child:CircularProgressIndicator(
                                backgroundColor: Colors.green,
                              )
                            ),
                            errorWidget: (context,url,error) => new Icon(Icons.error),
                          )
                        ),
                        title: Text(
                          _inviteList[i].displayName
                        ),
                        trailing: SizedBox(
                          height: 40,
                          width: 78,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)
                            ),
                            color: Colors.lightBlue,
                            onPressed: () {
                              setState(() {
                                sendingRequest = true;
                              });
                              sendInvite(_inviteList[i].userId,i);
                            },
                            /*enable[i]
                            ? () {
                              setState(() {
                                invited.add(_inviteList[i].userId);
                                enable[i] = false;
                                print("Inside true");
                              });
                            }
                            : () {
                              setState(() {
                                invited.remove(_inviteList[i].userId);
                                enable[i] = true;
                                print("Inside false");
                              });
                            },*/
                            child: Text(
                              "Invite",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      );
                    }
                  );
                }
              }),
            )
          ],
        ),
      ),
    );
  }

  sendInvite(String invited, int i) async {
    _inviteList.removeAt(i);
    var req = await http.post(
      "${Constants.SERVER_URL}groups/invite",
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${_userModel.accessToken}"
      },
      body: convert.jsonEncode({
        "requestor_id": "${_userModel.userId}",
        "requestor_name": "${_userModel.displayName}",
        "invitee_id": invited,
        "group_id": widget.groupId,
      })
    );
    var convertedData = convert.jsonDecode(req.body);
    Future.delayed(Duration(milliseconds: 3000), () {
      if(!convertedData["error"]) {
        setState(() {
          sendingRequest = false;
          Provider.of<GroupProvider>(context, listen: false)
              .getInviteList(_userModel.userId, widget.groupId, _userModel.accessToken);
        });
      }
      else {
        print(convertedData["data"]);
      }
    });
  }

  /*filterList(String query) {
    List<UserModel> dummySearchList = List<UserModel>();
    dummySearchList.addAll(_duplicateList);
    if(query.isNotEmpty) {
      List<UserModel> dummyListData = List<UserModel>();
      dummySearchList.forEach((user) {
        if(user.displayName.contains(query)) {
          dummyListData.add(user);
        }
      });
      setState(() {
        _inviteList.clear();
        _inviteList.addAll(dummyListData);
      });
      return;
    }
    else {
      setState(() {
        _inviteList.clear();
        _inviteList.addAll(_duplicateList);
      });
    }
  }*/
}