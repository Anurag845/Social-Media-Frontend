import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lockdown_diaries/models/CategoryModel.dart';
import 'package:lockdown_diaries/models/GroupModel.dart';
import 'package:lockdown_diaries/pages/AllCategoriesPage.dart';
import 'package:lockdown_diaries/pages/SingleCategoryPage.dart';
import 'package:lockdown_diaries/pages/SingleGroupPage.dart';
import 'package:lockdown_diaries/providers/CategoryProvider.dart';
import 'package:lockdown_diaries/providers/GroupProvider.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:lockdown_diaries/models/PostModel.dart';
import 'package:lockdown_diaries/models/UserModel.dart';
import 'package:lockdown_diaries/providers/AuthProvider.dart';
import 'package:lockdown_diaries/providers/PostProvider.dart';
import 'package:lockdown_diaries/providers/Theme_provider.dart';
import 'package:lockdown_diaries/utils/Constants.dart';
import 'package:lockdown_diaries/widgets/PostsPageItem.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:admob_flutter/admob_flutter.dart';

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  AdmobBannerSize bannerSize;

  UserModel _userModel;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  //List<CategoryModel> _categories = List<CategoryModel>();
  //List<GroupModel> _groups = List<GroupModel>();
  bool categoriesloading = true;
  bool groupsloading = true;

  ScrollController _controller;

  @override
  void initState() {
    categoriesloading = true;
    groupsloading = true;
    bannerSize = AdmobBannerSize.MEDIUM_RECTANGLE;

    _controller = ScrollController();
    _controller.addListener(_scrollListener);

    super.initState();
    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    //getCategories();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<PostProvider>(context, listen: true).listPosts;
    Provider.of<GroupProvider>(context, listen: true).allUserGroups;
    Provider.of<CategoryProvider>(context, listen: true).allCategories;
    Provider.of<ThemeProvider>(context);

    //return Column()
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            child:
                Consumer<PostProvider>(builder: (context, postProvider, child) {
              List<PostModel> _listPosts = postProvider.listPosts;

              return SmartRefresher(
                  enablePullUp: true,
                  onRefresh: _onRefresh,
                  header: WaterDropMaterialHeader(
                    backgroundColor: Colors.blue,
                  ),
                  controller: _refreshController,
                  child: ListView(
                      controller: _controller,
                      shrinkWrap: true,
                      children: <Widget>[
                        // Create Post
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: <Widget>[
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0,
                                    top: 12.0,
                                    bottom: 12.0),
                                margin: EdgeInsets.only(bottom: 5.0, top: 5.0),
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
                                              Constants.USERS_PROFILES_URL +
                                                  _userModel.img),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(Constants.CreatePostPageRoute);
                                        /*Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (_) => CreatePost()));*/
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
                                    )),
                                  ],
                                ),
                              ),
                              /*Divider(
                              thickness: .2,
                            ),*/
                              SizedBox(
                                height: 12,
                              ),
                              Divider(
                                thickness: 1,
                                height: 0,
                              )
                            ],
                          ),
                        ),

                        ExpansionTile(
                            title: Text('Looking for focused content?'),
                            children: <Widget>[
                              // Categories ListView

                              Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Column(children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 3, 0, 3),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        AllCategoriesPage()));
                                          },
                                          child: Text(
                                            "Categories",
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: double.infinity,
                                        height: 220,
                                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        child: Consumer<CategoryProvider>(
                                            builder: (context, categoryProvider,
                                                child) {
                                          List<CategoryModel> categories =
                                              categoryProvider.allCategories;

                                          return ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemBuilder: (context, i) {
                                              if (i == 7) {
                                                return Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Material(
                                                              elevation: 4.0,
                                                              //color: Colors.transparent,
                                                              clipBehavior:
                                                                  Clip.hardEdge,
                                                              shape:
                                                                  CircleBorder(),
                                                              child: Ink.image(
                                                                image: AssetImage(
                                                                    'assets/images/see_all.png'),
                                                                height: 50,
                                                                width: 50,
                                                                child: InkWell(
                                                                  onTap: () {},
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                child: InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap: () {},
                                                                  child: Text(
                                                                      "See all"),
                                                                ))
                                                          ],
                                                        ),
                                                      )),
                                                );
                                              } else {
                                                return Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2.5,
                                                    child: Card(
                                                        elevation: 4.0,
                                                        clipBehavior: Clip
                                                            .antiAliasWithSaveLayer,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: InkWell(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(MaterialPageRoute(
                                                                      builder: (_) =>
                                                                          SingleCategoryPage(
                                                                              categories[i])));
                                                            },
                                                            child: Wrap(
                                                              children: <
                                                                  Widget>[
                                                                Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topCenter,
                                                                    child: Container(
                                                                        height: MediaQuery.of(context).size.width / 2.5,
                                                                        child: ClipRRect(
                                                                            borderRadius: BorderRadius.vertical(top: Radius.circular(5.0)),
                                                                            child: CachedNetworkImage(
                                                                              imageUrl: Constants.CATEGORY_IMAGES + categories[i].categoryImage,
                                                                              placeholder: (context, url) => Center(
                                                                                  child: CircularProgressIndicator(
                                                                                backgroundColor: Colors.green,
                                                                              )),
                                                                              errorWidget: (context, url, error) => new Icon(Icons.error),
                                                                              fit: BoxFit.fill,
                                                                              //height: MediaQuery.of(context).size.width/2.5,
                                                                            )))),
                                                                Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                    child: Container(
                                                                        height: 50,
                                                                        child: ListTile(
                                                                          title:
                                                                              Text(
                                                                            categories[i].categoryName,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        )))
                                                              ],
                                                            ))),
                                                  ),
                                                );
                                              }
                                            },
                                            itemCount: categories.length,
                                          );
                                        })),
                                  ])),

                              SizedBox(
                                height: 12,
                              ),
                              Divider(
                                thickness: 5,
                                height: 0,
                              ),

                              //Groups Listview
                              Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Column(children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 3, 0, 3),
                                        child: Text(
                                          "Groups",
                                          style: TextStyle(fontSize: 16.0),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: double.infinity,
                                        height: 220,
                                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                        child: Consumer<GroupProvider>(builder:
                                            (context, groupProvider, child) {
                                          List<GroupModel> groups =
                                              groupProvider.allUserGroups;

                                          return ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: true,
                                            itemBuilder: (context, i) {
                                              if (i == 7) {
                                                return Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Material(
                                                              elevation: 4.0,
                                                              //color: Colors.transparent,
                                                              clipBehavior:
                                                                  Clip.hardEdge,
                                                              shape:
                                                                  CircleBorder(),
                                                              child: Ink.image(
                                                                image: AssetImage(
                                                                    'assets/images/see_all.png'),
                                                                height: 50,
                                                                width: 50,
                                                                child: InkWell(
                                                                  onTap: () {},
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                child: InkWell(
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap: () {},
                                                                  child: Text(
                                                                      "See all"),
                                                                ))
                                                          ],
                                                        ),
                                                      )),
                                                );
                                              } else {
                                                return Align(
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2.5,
                                                    child: Card(
                                                        elevation: 4.0,
                                                        clipBehavior: Clip
                                                            .antiAliasWithSaveLayer,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: InkWell(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          SingleGroupPage(
                                                                              groups[i])));
                                                            },
                                                            child: Wrap(
                                                              children: <
                                                                  Widget>[
                                                                Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topCenter,
                                                                    child: Container(
                                                                        padding: EdgeInsets.all(3),
                                                                        height: MediaQuery.of(context).size.width / 3,
                                                                        child: ClipOval(
                                                                            child: CachedNetworkImage(
                                                                          imageUrl:
                                                                              Constants.GROUP_IMAGES + groups[i].groupImage,
                                                                          placeholder: (context, url) => Center(
                                                                              child: CircularProgressIndicator(
                                                                            backgroundColor:
                                                                                Colors.green,
                                                                          )),
                                                                          errorWidget: (context, url, error) =>
                                                                              new Icon(Icons.error),
                                                                          //fit: BoxFit.fill,
                                                                          //height: MediaQuery.of(context).size.width/2.5,
                                                                        )))),
                                                                Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                    child: Container(
                                                                        height: 50,
                                                                        child: ListTile(
                                                                          title:
                                                                              Text(
                                                                            groups[i].groupName,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        )))
                                                              ],
                                                            ))),
                                                  ),
                                                );
                                              }
                                            },
                                            itemCount: groups.length,
                                          );
                                        })),
                                  ])),
                            ]),

                        // Posts ListView
                        ListView.builder(
                          //controller: _controller,
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, i) {
                            PostModel _post = _listPosts[i];

                            return InkWell(
                              onLongPress: () {
                                if (_post.postOwnerId == _userModel.userId ||
                                    _userModel.email == Constants.ADMIN_EMAIL) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          content: InkWell(
                                              onTap: () {
                                                startDeletePost(_post, i);
                                              },
                                              child: Text('delete post')),
                                        );
                                      });
                                }
                              },
                              child: PostsPageItem(_post, _userModel),
                            );
                          },
                          itemCount: _listPosts.length,
                        )
                      ]));
            }),
          ),
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return Constants.BannerAdUnitIdAndroid;
    } else if (Platform.isAndroid) {
      return Constants.BannerAdUnitIdIOS;
    }
    return null;
  }

  _scrollListener() async {
    //start LoadMore when maxScrollExtent
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      int x = await Provider.of<PostProvider>(context, listen: false)
          .loadMore(_userModel.userId, _userModel.accessToken);

      if (x == 0) {
        _refreshController.loadNoData();
      }
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {}
  }

  void startDeletePost(PostModel post, int i) async {
    // deletePost
    await http.post('${Constants.SERVER_URL}post/deletePost',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer ${_userModel.accessToken}"
        },
        body: convert.jsonEncode({'post_id': post.postId}));
    Navigator.of(context).pop();
    //Provider.of<PostProvider>(context, listen: false).removePost(i);
  }

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 500));
    Provider.of<PostProvider>(context, listen: false)
        .startGetPostsData(_userModel.userId, _userModel.accessToken);
    Provider.of<CategoryProvider>(context, listen: false)
        .getAllCategories(_userModel.accessToken);
    Provider.of<GroupProvider>(context, listen: false)
        .getAllUserGroups(_userModel.userId, _userModel.accessToken);
    _refreshController.refreshCompleted();
  }
}