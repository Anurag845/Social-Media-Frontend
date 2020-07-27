import 'dart:async';
import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:navras/models/CommentsModel.dart';
import 'package:navras/models/PostModel.dart';
import 'package:navras/models/UserModel.dart';

import 'package:navras/providers/AuthProvider.dart';
import 'package:http/http.dart' as http;
import 'package:navras/providers/PostProvider.dart';
import 'package:navras/providers/Theme_provider.dart';
import 'dart:convert' as convert;

import 'package:navras/utils/Constants.dart';
import 'package:navras/widgets/CommentItem.dart';
import 'package:navras/widgets/PostsPageItem.dart';

// ignore: must_be_immutable
class CommentsPage extends StatefulWidget {
  // if come from any screen except Notification click so don't make new request to get data
  PostModel _postModel;
  bool isFromHomePage;

  CommentsPage(this._postModel,this.isFromHomePage);

  @override
  _CommentsPageState createState() => _CommentsPageState(_postModel,isFromHomePage);
}

class _CommentsPageState extends State<CommentsPage> {
  PostModel _postModel;
  UserModel _myModel;
  bool isFromHomePage;
  // if come from Notification click so make new request to get data
  PostModel postData;
  final double minValue = 8.0;
  AdmobInterstitial interstitialAd;
  _CommentsPageState(this._postModel, this.isFromHomePage);

  ScrollController _scrollController;
  final double iconSize = 28.0;
  FocusNode _focusNode = FocusNode();
  TextEditingController _txtController = TextEditingController();
  List<CommentsModel> _listComments = [];

  @override
  void initState() {
    interstitialAd = AdmobInterstitial(
      adUnitId: getInterstitialAdUnitId(),
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) interstitialAd.load();

      },
    );
    //interstitialAd.load();

    _scrollController = ScrollController();
    _myModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    super.initState();
    getPostData();
    getComments();
  }

  String getInterstitialAdUnitId() {
    if (Platform.isIOS) {
      return Constants.InterstitialAdUnitIdIOS;
    }
    else if (Platform.isAndroid) {
      return Constants.InterstitialAdUnitIdAndroid;
    }
    return null;
  }
  @override
  void dispose() {
    super.dispose();
    _txtController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.getThemeData.backgroundColor,
      appBar: AppBar(
        title: Text(
          'comments',
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: postData == null
          ? Container()
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    controller: _scrollController,
                    children: <Widget>[
                      PostsPageItem(
                        isFromHomePage ? _postModel : postData,
                        _myModel,
                        isFromHomePage: isFromHomePage
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, i) {
                          var comment = _listComments[i];
                          return InkWell(
                              onLongPress: () {
                                if (comment.userId == _myModel.userId || _myModel.email == Constants.ADMIN_EMAIL) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: InkWell(
                                          onTap: () {
                                            startDeleteComment(comment, i);
                                          },
                                          child: Text('delete comment')
                                        ),
                                      );
                                    }
                                  );
                                }
                              },
                              child: CommentItem(comment));
                        },
                        itemCount: _listComments.length,
                      ),
                    ],
                  ),
                ),
                Container(

                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildBottomSection(themeProvider),
                  ),
                ),
              ],
            ),
    );
  }

  void startDeleteComment(CommentsModel commentsModel, int index) async {
    await http.post(
        '${Constants.SERVER_URL}comment/delete',
        headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer ${_myModel.accessToken}"
        },
        body: convert.jsonEncode({
            'comment_id': '${commentsModel.commentId}',
            'entity_id': _postModel.postId,
            'entity_type': 'post'
        })
    );
    Navigator.of(context).pop();
    setState(() {
      _listComments.removeAt(index);
    });
    print('${commentsModel.commentId}');
    Provider.of<PostProvider>(context, listen: false)
        .startGetPostsData(_myModel.userId, _myModel.accessToken);
  }

  _buildBottomSection(themeProvider) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 52,
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                color: themeProvider.getThemeData.dividerColor,
                borderRadius: BorderRadius.all(Radius.circular(8.0 * 4))),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextField(
                    maxLines: null,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.multiline,
                    controller: _txtController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type your comment"),
                    autofocus: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: minValue, top: 5, bottom: 5),
          child: FloatingActionButton(
            elevation: 0,
            onPressed: () {
              if(_txtController.text.isEmpty){
               Fluttertoast.showToast(msg: 'cant send empty comment');
              }else{
                startAddComment();
              }
            },
            child: Icon(
              Icons.send,
              color: Colors.black,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }

  void startAddComment() async {
    String comment = '${_txtController.text}';
    String postId = _postModel.postId;
    String userName = _myModel.username;
    String userId = _myModel.userId;
    String userImg = _myModel.img;
    String postOwnerId = _postModel.postOwnerId;

    _txtController.clear();
    try {
      var req = await http.post(
        '${Constants.SERVER_URL}comment/create',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer ${_myModel.accessToken}"
        },
        body: convert.jsonEncode({
          'descr': comment,
          'entity_id': postId,
          'user_id': userId,
          'entity_type': 'post',
          'post_owner_id': postOwnerId,
          'username': userName
        })
      );

      var res = convert.jsonDecode(req.body);
      if (!res['error']) {
        setState(() {
          _listComments.add(CommentsModel(
              commentId: res['data']['comment_id'],
              comment: comment,
              postId: postId,
              userName: userName,
              userId: userId,
              userImg: userImg,
              postOwnerId: postOwnerId));
        });

        Provider.of<PostProvider>(context, listen: false)
            .startGetPostsData(_myModel.userId, _myModel.accessToken);
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent + _listComments.length * 100,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }
      else {
        Fluttertoast.showToast(
          msg: 'error ${res['error']}', toastLength: Toast.LENGTH_LONG
        );
      }
    } catch (err) {
      print(err);
    }
  }

  void getComments() async {
    var req = await http.post(
      '${Constants.SERVER_URL}comment/fetch_all',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${_myModel.accessToken}"
      },
      body: convert.jsonEncode({
        'entity_type': 'post',
        'entity_id': _postModel.postId
      })
    );
    var res = convert.jsonDecode(req.body);
    if (!res['error']) {
      var listComments = res['data'];
      List<CommentsModel> _temp = [];
      for (int i = 0; i < listComments.length; i++) {
        _temp.add(CommentsModel(
          comment: listComments[i]['descr'],
          commentId: listComments[i]['comment_id'],
          postId: listComments[i]['entity_id'],
          userName: listComments[i]['username'],
          userId: listComments[i]['user_id'],
          userImg: listComments[i]['profile_pic'],
          postOwnerId: _postModel.postOwnerId)
        );
      }
      setState(() {
        _listComments = _temp;
        _temp = null;
      });
     Future.delayed(Duration(seconds: 1),(){
       _scrollController.animateTo(
         _scrollController.position.minScrollExtent + _listComments.length * 100,
         curve: Curves.easeOut,
         duration: const Duration(milliseconds: 300),
       );
     });
    }
    else {}

    //interstitialAd.show();
  }

  void getPostData() async {
    try{
      var req = await http.post(
        '${Constants.SERVER_URL}post/getPostById',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer ${_myModel.accessToken}"
        },
        body: convert.jsonEncode({
          'user_id': _myModel.userId,
          'post_id': _postModel.postId
        })
      );

      var res = convert.jsonDecode(req.body);

      if (!res['error']) {
        setState(() {
          postData = PostModel.fromJson(res['data']);
        });
      }
      else{
        print('Error found is ' + res['data']);
        //print(_postModel.postId);
      }
    }
    catch(err){
      print('error is ' + err);
    }

  }
}
