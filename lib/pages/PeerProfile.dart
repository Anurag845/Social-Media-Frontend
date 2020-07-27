import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:navras/models/ChatModel.dart';
import 'package:navras/models/PostModel.dart';
import 'package:navras/models/UserModel.dart';
import 'package:navras/pages/ChatMessagesPage.dart';
import 'package:navras/pages/FullScreenImg.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/providers/Theme_provider.dart';
import 'package:navras/utils/Constants.dart';
import 'package:http/http.dart' as http;
import 'package:navras/widgets/PostsPageItem.dart';
import 'dart:convert' as convert;

// ignore: must_be_immutable
class PeerProfile extends StatefulWidget {
  String peerId;

  PeerProfile(this.peerId);

  @override
  _PeerProfileState createState() => _PeerProfileState();
}

class _PeerProfileState extends State<PeerProfile> {
  var _firstMessageController = TextEditingController();
  UserModel _myModel;
  UserModel peerModel;
  List<PostModel> _listPosts = [];
  String follow = 'FOLLOW';

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: screenSize.height / 2.6,
      decoration: BoxDecoration(
           color: Colors.black12),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
              FullScreenImg(Constants.USERS_PROFILES_URL + peerModel.img, false)
            )
          );
        },
        child: Container(
          width: 140.0,
          height: 140.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(Constants.USERS_PROFILES_URL + peerModel.img),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(80.0),
            border: Border.all(
              color: Colors.white,
              width: 5.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullName() {
    TextStyle _nameTextStyle = TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
    );

    return Text(
      peerModel.username,
      style: _nameTextStyle,
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        ' ',
        style: TextStyle(
          fontSize: 1.0,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildBio(BuildContext context) {
    TextStyle bioTextStyle = TextStyle(
      fontWeight: FontWeight.w400, //try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
      fontSize: 16.0,
    );

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(8.0),
      child: Text(
        '${peerModel.profileAbout}',
        textAlign: TextAlign.center,
        style: bioTextStyle,
      ),
    );
  }

  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.6,
      height: 2.0,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 4.0),
    );
  }

  Widget _buildGetInTouch(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.only(top: 8.0),
      child:  Text(
        "Get in Touch with ${peerModel.username},",
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  String likes = "";

  String posts = "";

  String comments = "";

  startGetCommentLikesPostsCount() async {
    var req = await http.post(
      '${Constants.SERVER_URL}user/get_likes_posts_comments_counts',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${_myModel.accessToken}"
      },
      body: convert.jsonEncode({
        'user_id': widget.peerId
      })
    );
    var res = convert.jsonDecode(req.body);
    if (!res['error']) {
      setState(() {
        likes = res['likes'].toString();
        posts = res['posts'].toString();
        comments = res['comments'].toString();
      });
    }
  }

  Widget _likesCommentsPostsCount(BuildContext context, themeProvider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: themeProvider.getThemeData.dividerColor,
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text('Posts', textAlign: TextAlign.center),
              SizedBox(
                height: 10,
              ),
              Text(
                posts == "" ? '-' : posts,
                textAlign: TextAlign.center,
              )
            ],
          ),
          Column(
            children: <Widget>[
              Text('Comments', textAlign: TextAlign.center),
              SizedBox(
                height: 10,
              ),
              Text(
                comments == "" ? '-' : comments,
                textAlign: TextAlign.center,
              )
            ],
          ),
          Column(
            children: <Widget>[
              Text('Likes', textAlign: TextAlign.center),
              SizedBox(
                height: 10,
              ),
              Text(
                likes == "" ? '-' : likes,
                textAlign: TextAlign.center,
              )
            ],
          )
        ],
      )
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () => print("followed"),
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (follow == 'FOLLOW') {
                        follow = 'FOLLOWED';
                      } else {
                        follow = 'FOLLOW';
                      }
                    });
                  },
                  child: Center(
                    child: Text(
                      follow,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: InkWell(
                onTap: () {
                  getChat();
                },
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "MESSAGE",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _myModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    super.initState();
    getPeerUserData();
    startGetCommentLikesPostsCount();
    getUserPosts();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${peerModel == null ? '' : peerModel.username}'),
        elevation: 1,
      ),
      body: peerModel == null
          ? Container()
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      _buildCoverImage(screenSize),
                      SafeArea(
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: screenSize.height / 3.9),
                              _buildProfileImage(),
                              _buildFullName(),
                              _buildStatus(context),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'about me',
                                style: TextStyle(fontSize: 17),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              _buildBio(context),
                              _likesCommentsPostsCount(context, themeProvider),
                              SizedBox(
                                height: 10,
                              ),
                              _buildSeparator(screenSize),
                              SizedBox(height: 10.0),
                              _myModel.userId == peerModel.userId
                                  ? Container():  _buildGetInTouch(context),
                              SizedBox(height: 8.0),
                              _myModel.userId == peerModel.userId
                                  ? Container()
                                  : _buildButtons(),
                              Divider(
                                thickness: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  _listPosts.length == 0
                  ? Container()
                  : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _listPosts.length,
                      itemBuilder: (context, i) {
                        var postModel = _listPosts[i];
                        return PostsPageItem(postModel, _myModel);
                      }
                    )
                ],
              ),
            ),
    );
  }

  getUserPosts() {
    //start get Posts !
    String _url = "${Constants.SERVER_URL}post/fetch_posts_by_user_id";
    return http.post(
      _url,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${_myModel.accessToken}"
      },
      body: convert.jsonEncode({
        'user_id': '${_myModel.userId}',
        'peer_id': '${widget.peerId}'
      })
    )
    .then((res) async {
      var convertedData = convert.jsonDecode(res.body);
      if (!convertedData['error']) {
        List data = convertedData['data'];
        _listPosts = data.map((data) => PostModel.fromJson(data)).toList();
      }
      setState(() {});
    })
    .catchError((err) {
      print('init Data error is $err');
    });
  }

  void getChat() async {
    String _url = '${Constants.SERVER_URL}conversations/create';

    http.post(
      _url,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${_myModel.accessToken}"
      },
      body: convert.jsonEncode({
        'user_id': '${_myModel.userId}',
        'peer_id': '${widget.peerId}'
      })
    ).then((res) async {
      var data = convert.jsonDecode(res.body);
      if (!data['error']) {
        String conversationId = data['data']['conversation_id'];
        String userId = widget.peerId;
        String userImg = peerModel.img;
        String userName = peerModel.username;
        String peerToken = peerModel.token;
        String myId = _myModel.userId;
        String createdAt = data['data']['created_at'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatMessagesPage(ChatModel(
              userId,userName,userImg,conversationId),"PC"
            )
          )
        );
      }
    }).catchError((err) {
      print("Error is " + err.toString());
    });
  }

  void getPeerUserData() async {
    http.post(
      '${Constants.SERVER_URL}user/get',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${_myModel.accessToken}"
      },
      body: convert.jsonEncode({
        'user_id': '${widget.peerId}',
      })
    ).then((req) {
      var res = convert.jsonDecode(req.body);

      if (!res['error']) {
        var userData = res['data'];

        UserModel peerModel0 = UserModel.fromJson(userData);

        setState(() {
          peerModel = peerModel0;
        });
      }
    });
  }
}
