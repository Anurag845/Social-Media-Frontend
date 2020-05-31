//created by Hatem Ragap
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:lockdown_diaries/models/PostModel.dart';
import 'package:lockdown_diaries/models/UserModel.dart';
import 'package:lockdown_diaries/pages/CommentsPage.dart';
import 'package:lockdown_diaries/pages/FullScreenImg.dart';
import 'package:lockdown_diaries/pages/PeerProfile.dart';
import 'package:lockdown_diaries/providers/AuthProvider.dart';
import 'package:lockdown_diaries/providers/PostProvider.dart';
import 'package:lockdown_diaries/utils/Constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:timeago/timeago.dart' as timeAgo;

// ignore: must_be_immutable
class PostsPageItem extends StatefulWidget {
  PostModel _postModel;
  UserModel _userModel;
  bool isFromHomePage = false;
  bool isFromCommentPage = true;

  PostsPageItem(this._postModel, this._userModel,
      {this.isFromHomePage = false, this.isFromCommentPage = true});

  @override
  _PostsPageItemState createState() => _PostsPageItemState();
}

class _PostsPageItemState extends State<PostsPageItem> {

  var hasLikedIcon = Icon(
    FontAwesomeIcons.solidThumbsUp,
    size: 20,
  );
  var hasNoLikedIcon = Icon(
    FontAwesomeIcons.thumbsUp,
    size: 20,
  );
  var liking = Icon(
    Icons.more_horiz,
    size: 20,
  );

  var date;
  UserModel userModel;

  bool isBasy = false;

  @override
  void initState() {
    super.initState();

    userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    date = new DateTime.fromMillisecondsSinceEpoch(widget._postModel.timeStamp * 1000);
  }

  void _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
            height: 190,
            color: Colors.transparent, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: new Container(
                decoration: new BoxDecoration(

                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                child: Column(
                  children: <Widget>[
                    userModel.userId == widget._postModel.postOwnerId
                        ?  ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete this post'),
                            onTap: () {
                              Provider.of<PostProvider>(context, listen: false)
                                  .deletePostRequest(widget._postModel.postId, userModel.accessToken);
                              Navigator.of(context).pop();
                              if (widget.isFromCommentPage) {
                                Navigator.of(context).pop();
                              }
                            },
                          ): userModel.email == Constants.ADMIN_EMAIL? ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Delete this post'),
                      onTap: () {
                        Provider.of<PostProvider>(context, listen: false)
                            .deletePostRequest(widget._postModel.postId, userModel.accessToken);
                        Navigator.of(context).pop();
                        if (widget.isFromCommentPage) {
                          Navigator.of(context).pop();
                        }
                      },
                    ):Container(),
                    ListTile(
                      leading: Icon(Icons.report),
                      title: Text('Report this post'),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.report),
                      title: Text('Report this person'),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Divider(
            thickness: 5,
            height: 0,
          ),
          // user name , user img and time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //img and name and time ago
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          PeerProfile(widget._postModel.postOwnerId)));
                },
                child: Row(
                  children: <Widget>[
                    Container(
                        width: 51,
                        height: 51,
                        margin: EdgeInsets.only(left: 5, top: 5),
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: CachedNetworkImage(
                                imageUrl: Constants.USERS_PROFILES_URL + widget._userModel.img,
                                  //'https://homepages.cae.wisc.edu/~ece533/images/boat.png',
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ],
                        )),
                    SizedBox(
                      width: 8,
                    ),
                    // name and time ago
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${widget._postModel.userName}',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          '${timeAgo.format(date)}',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                  onTap: () {
                    _modalBottomSheetMenu();
                  },
                  child: Icon(
                    Icons.more_vert,
                    size: 25,
                  ))
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SelectableText(
              '${widget._postModel.postData}',
              textAlign: TextAlign.justify,
              style:
                  GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          SizedBox(
            height: 10,
          ),

          widget._postModel.hasImg
              ? ListView.builder(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget._postModel.attachments.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => FullScreenImg(
                            Constants.USERS_POSTS_IMAGES + widget._postModel.attachments[index].name
                          )
                        )
                      );
                    },
                    child: CachedNetworkImage(
                      imageUrl: Constants.USERS_POSTS_IMAGES + widget._postModel.attachments[index].name,
                      placeholder: (c, d) {
                        return Center(
                          child: Container(
                              color: Colors.grey.shade100,
                              padding: EdgeInsets.only(
                                  top: 100,
                                  bottom: 100,
                                  right: MediaQuery.of(context).size.width / 3 +
                                      20,
                                  left: MediaQuery.of(context).size.width / 3 +
                                      20),
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.green,
                              )),
                        );
                      },
                      fit: BoxFit.contain,
                    ),
                  ),
                  );
                },
              )
              : Container(),

          SizedBox(
            height: 10,
          ),
          Divider(
            thickness: 1,
            height: 0,
          ),

          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        /*if (widget._postModel.postOwnerId == userModel.userId) {
                          Fluttertoast.showToast(msg: 'can\'t like your post ');
                        } 
                        else {*/
                          if(!isBasy)
                            startAddLike();
                          },
                     // },
                      child: Container(
                          padding: EdgeInsets.only(
                              right: 10, left: 15, top: 10, bottom: 13),
                          margin: EdgeInsets.only(left: 15),
                          child: isBasy
                              ? liking
                              : widget._postModel.isUserLiked ? hasLikedIcon : hasNoLikedIcon),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Text(
                        '${widget._postModel.postLikes == 0 ? '' : widget._postModel.postLikes.abs()}')
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => CommentsPage(
                          widget._postModel,
                          true,
                        )
                      )
                    );
                  },
                  child: Row(
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(
                              right: 10, left: 30, top: 10, bottom: 13),
                          child: Icon(
                            FontAwesomeIcons.comment,
                            size: 20,
                          )),
                      Text(
                          '${widget._postModel.commentsCount == 0 ? '' : widget._postModel.commentsCount.abs()}')
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: InkWell(
                    onTap: () {
                      Share.share('${widget._postModel.postData}');
                    },
                    child: Container(
                        padding: EdgeInsets.only(left: 30, top: 10, bottom: 13),
                        margin: EdgeInsets.only(right: 15),
                        child: Icon(
                          Icons.share,
                          size: 20,
                        )),
                  ),
                )
              ],
            ),
          ),
          Divider(
            thickness: 1,
            height: 0,
          ),
        ],
      ),
    );
  }

  void startAddLike() async {
    setState(() {
      isBasy = true;
    });
    try{
      if (!widget._postModel.isUserLiked) {
        var req = await http.post(
          '${Constants.SERVER_URL}like/create',
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer ${widget._userModel.accessToken}"
          },
          body: convert.jsonEncode({
            'user_id': '${widget._userModel.userId}',
            'entity_id': '${widget._postModel.postId}',
            'entity_type': 'post',
            'username': '${widget._userModel.username}',
            'post_owner_id': '${widget._postModel.postOwnerId}'
          })
        );
        var res = convert.jsonDecode(req.body);
        if (!res['error']) {
          setState(() {
            widget._postModel.isUserLiked = true;
            ++widget._postModel.postLikes;
            isBasy = false;
          });
        }
        else {
          print("error is " + res['data']);
        }
      } 
      else {
        var req = await http.post(
          '${Constants.SERVER_URL}like/delete',
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Bearer ${widget._userModel.accessToken}"
          },
          body: convert.jsonEncode({
            'user_id': '${widget._userModel.userId}',
            'entity_id': '${widget._postModel.postId}',
            'entity_type': 'post',
            'username': '${widget._userModel.username}',
            'post_owner_id': '${widget._postModel.postOwnerId}'
          })
        );
        var res = convert.jsonDecode(req.body);
        if (!res['error']) {
          setState(() {
            widget._postModel.isUserLiked = false;
            --widget._postModel.postLikes;
            isBasy = false;
          });
        }
      }
    }
    catch(err){
      print("Error encountered is " + err);
    }
    finally{

    }

  }
}
