import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lockdown_diaries/models/CategoryModel.dart';
import 'package:lockdown_diaries/models/GroupModel.dart';
import 'package:lockdown_diaries/models/UserModel.dart';
import 'package:lockdown_diaries/pages/CreateGroupPage.dart';
import 'package:lockdown_diaries/pages/SingleGroupPage.dart';
import 'package:lockdown_diaries/providers/AuthProvider.dart';
import 'package:lockdown_diaries/providers/GroupProvider.dart';
import 'package:lockdown_diaries/providers/PostProvider.dart';
import 'package:lockdown_diaries/providers/Theme_provider.dart';
import 'package:lockdown_diaries/utils/Constants.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SingleCategoryPage extends StatefulWidget {
  final CategoryModel category;

  SingleCategoryPage(this.category);

  @override
  _SingleCategoryPageState createState() => _SingleCategoryPageState();
}

class _SingleCategoryPageState extends State<SingleCategoryPage> {
  UserModel _userModel;
  bool groupsloading;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  ScrollController _controller;

  @override
  void initState() {
    groupsloading = true;
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    super.initState();

    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    Provider.of<GroupProvider>(context, listen: false)
    .getUserGroupsbyCategory(_userModel.userId, _userModel.accessToken, widget.category.categoryId);
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

  void _onRefresh() async {
    await Future.delayed(Duration(milliseconds: 500));
    Provider.of<GroupProvider>(context, listen: false)
    .getUserGroupsbyCategory(_userModel.userId, _userModel.accessToken, widget.category.categoryId);
    //getCategories();
    //getGroups();
    _refreshController.refreshCompleted();
  }

  getCategories() {

  }

  @override
  Widget build(BuildContext context) {
    Provider.of<GroupProvider>(context).userGroupsbyCategory;
    Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.categoryName),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Consumer<GroupProvider>(builder: (context,groupProvider,child) {
                List<GroupModel> _groups = groupProvider.userGroupsbyCategory;
                return SmartRefresher(
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
                      Container(
                        padding: EdgeInsets.fromLTRB(0,0,0,0),
                        child: Column(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: 200,
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: CachedNetworkImage(
                                  imageUrl: Constants.CATEGORY_IMAGES + widget.category.categoryImage,
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.green,
                                    )
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(10, 8, 0, 3),
                                child: Text(
                                  "Groups",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 220,
                              margin: EdgeInsets.fromLTRB(5,0,5,0),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (context, i) {
                                  if(i == 7) {
                                    return Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width/2.5,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Material(
                                                elevation: 4.0,
                                                //color: Colors.transparent,
                                                clipBehavior: Clip.hardEdge,
                                                shape: CircleBorder(),
                                                child: Ink.image(
                                                  image: AssetImage('assets/images/see_all.png'),
                                                  height: 50,
                                                  width: 50,
                                                  child: InkWell(
                                                    onTap: () {

                                                    },
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(5),
                                                child: InkWell(
                                                  splashColor: Colors.transparent,
                                                  onTap: () {

                                                  },
                                                  child: Text("See all"),
                                                )
                                              )
                                            ],
                                          ),
                                        )
                                      ),
                                    );
                                  }
                                  else {
                                    return Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        height: MediaQuery.of(context).size.width/2,
                                        width: MediaQuery.of(context).size.width/2.5,
                                        child: Card(
                                          elevation: 4.0,
                                          clipBehavior: Clip.antiAliasWithSaveLayer,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => SingleGroupPage(_groups[i])
                                                )
                                              );
                                            },
                                            child: Wrap(
                                              children: <Widget>[
                                                Align(
                                                  alignment: Alignment.topCenter,
                                                  child: Container(
                                                    padding: EdgeInsets.all(3),
                                                    height: MediaQuery.of(context).size.width/3,
                                                    child: ClipOval(
                                                      child: CachedNetworkImage(
                                                        imageUrl: Constants.GROUP_IMAGES + _groups[i].groupImage,
                                                        placeholder: (context,url) => Center(
                                                          child:CircularProgressIndicator(
                                                            backgroundColor: Colors.green,
                                                          )
                                                        ),
                                                        errorWidget: (context,url,error) => new Icon(Icons.error),
                                                        //fit: BoxFit.fill,
                                                        //height: MediaQuery.of(context).size.width/2.5,
                                                      )
                                                    )
                                                  )
                                                ),
                                                Align(
                                                  alignment: Alignment.bottomCenter,
                                                  child: Container(
                                                    height: 50,
                                                    child:  ListTile(
                                                      title: Text(
                                                        _groups[i].groupName,
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    )
                                                  )
                                                )
                                              ],
                                            )
                                          )
                                        ),
                                      ),
                                    );
                                  }
                                },
                                itemCount: _groups.length,
                              ),
                            ),
                            Divider(
                              thickness: 5,
                              height: 0,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                margin: EdgeInsets.all(20),
                                padding: EdgeInsets.all(5),
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => CreateGroupPage(widget.category.categoryId)
                                      )
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Icon(
                                        Icons.add_box,
                                        size: 40,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "Create your own group",
                                          style: TextStyle(
                                            fontSize: 16
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ),
                            ),
                            Divider(
                              thickness: 5,
                              height: 0,
                            )
                          ]
                        )
                      ),
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