import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:navras/models/GroupModel.dart';
import 'package:navras/models/PostModel.dart';
import 'package:navras/models/UserModel.dart';
import 'package:navras/pages/AddPost.dart';
import 'package:navras/pages/InviteMembersPage.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/providers/GroupProvider.dart';
import 'package:navras/providers/PostProvider.dart';
import 'package:navras/utils/Constants.dart';
import 'package:navras/widgets/PostsPageItem.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SingleGroupPage extends StatefulWidget {
  final GroupModel group;

  SingleGroupPage(this.group);

  @override
  _SingleGroupPageState createState() => _SingleGroupPageState();
}

class _SingleGroupPageState extends State<SingleGroupPage> {

  UserModel _userModel;
  GroupModel _group;
  List<UserModel> _participants = [];

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);

    super.initState();
    _group = widget.group;
    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    Provider.of<PostProvider>(context, listen: false)
        .startGetPostsData(_userModel.userId, _userModel.accessToken);
    Provider.of<GroupProvider>(context, listen: false)
        .getParticipants(widget.group.groupId, _userModel.accessToken);
    Provider.of<GroupProvider>(context, listen: false)
        .getGroupInfo(widget.group.groupId, _userModel.accessToken);
  }

  _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 500));
    Provider.of<PostProvider>(context, listen: false)
        .startGetPostsData(_userModel.userId, _userModel.accessToken);
    Provider.of<GroupProvider>(context, listen: false)
        .getParticipants(widget.group.groupId, _userModel.accessToken);
    Provider.of<GroupProvider>(context, listen: false)
        .getGroupInfo(widget.group.groupId, _userModel.accessToken);
    _refreshController.refreshCompleted();
  }

  _scrollListener() async {
    //start LoadMore when maxScrollExtent
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      int x = await Provider.of<PostProvider>(context, listen: false)
          .loadMore(_userModel.userId,_userModel.accessToken);

      if (x == 0) {
        _refreshController.loadNoData();
      }
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Single Group Page"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Consumer<GroupProvider>
                (builder: (context, groupProvider, child) {

                _participants = groupProvider.groupParticipants;
                _group = groupProvider.groupInfo;

                return SmartRefresher(
                  scrollDirection: Axis.vertical,
                  enablePullUp: true,
                  onRefresh: _onRefresh,
                  header: WaterDropMaterialHeader(
                    backgroundColor: Colors.blue,
                  ),
                  controller: _refreshController,
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    controller: _controller,
                    shrinkWrap: true,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        //mainAxisSize: MainAxisSize.max,
                        //mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                              height: 200,
                              child: CachedNetworkImage(
                                imageUrl: Constants.GROUP_IMAGES + widget.group.groupImage,
                                placeholder: (context,url) => Center(
                                  child:CircularProgressIndicator(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                                errorWidget: (context,url,error) => new Icon(Icons.error),
                                fit: BoxFit.fill,
                              )
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 30,
                              child: Text(
                                widget.group.groupName,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 0,
                          ),
                          Container(
                            height: 30.0,
                            padding: EdgeInsets.all(5),
                            child: Text(
                              "Members: " + _participants.length.toString()
                            ),
                          ),
                          Container(
                            height: 65,
                            child: Align(
                              alignment: Alignment.center,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, i) {
                                  if(i == 3 || i == _participants.length) {
                                    return Container(
                                      padding: EdgeInsets.fromLTRB(8,10,8,10),
                                      child: RaisedButton(
                                        color: Colors.lightBlue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0)
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => InviteMembersPage(_group.groupId)
                                            )
                                          );
                                        },
                                        child: Text(
                                          "+ Invite"
                                        ),
                                      ),
                                    );
                                  }
                                  else {
                                    return Container(
                                      padding: EdgeInsets.fromLTRB(0,10,0,10),
                                      height: 35,
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: Constants.USERS_PROFILES_URL + _participants[i].img,
                                          placeholder: (context,url) => Center(
                                            child:CircularProgressIndicator(
                                              backgroundColor: Colors.green,
                                            )
                                          ),
                                          errorWidget: (context,url,error) => new Icon(Icons.error),
                                        )
                                      ),
                                    );
                                  }
                                },
                                itemCount: _participants.length >= 3 ? 4 : _participants.length+1,
                              )
                            )
                          ),
                          Container(
                            height: 50.0,
                            margin: EdgeInsets.fromLTRB(0,5,0,15),
                            padding: EdgeInsets.all(5),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: <Widget>[
                                Align(
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    height: 38,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0)
                                      ),
                                      onPressed: () {

                                      },
                                      child: Text(
                                        "Group Info"
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    height: 38,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0)
                                      ),
                                      onPressed: () {

                                      },
                                      child: Text(
                                        "Participants"
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    height: 38,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0)
                                      ),
                                      onPressed: () {

                                      },
                                      child: Text(
                                        "Activities"
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                    height: 38,
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.0)
                                      ),
                                      onPressed: () {

                                      },
                                      child: Text(
                                        "Create Activity"
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ),
                        ]
                      ),
                      Divider(
                        thickness: 5,
                        height: 0,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                top: 15.0,
                                bottom: 15.0
                              ),
                              margin: EdgeInsets.only(bottom: 5.0,),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                          Constants.USERS_PROFILES_URL + _userModel.img
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) => AddPost()));
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 16.0, right: 16.0),
                                        padding: EdgeInsets.only(
                                            left: 16.0,
                                            top: 8.0,
                                            right: 16.0,
                                            bottom: 8.0),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(40.0),
                                            border: Border.all(
                                                width: 1.0,
                                                color: Colors.grey)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                "Hey, what's up?",
                                                style:
                                                    TextStyle(fontSize: 14.0),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                "Share with your friends...",
                                                style:
                                                    TextStyle(fontSize: 13.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        child: Consumer<PostProvider>(builder: (context, postProvider, child) {
                          List<PostModel> _posts = postProvider.listPosts;
                          return ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context,i) {
                              return PostsPageItem(_posts[i],_userModel);
                            },
                            itemCount: _posts.length,
                          );
                        }),
                      )
                    ],
                  )
                );
              })
            ),
          )
        ],
      )
    );
  }
}