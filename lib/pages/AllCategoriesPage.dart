import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:navras/models/CategoryModel.dart';
import 'package:navras/models/UserModel.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/providers/CategoryProvider.dart';
import 'package:navras/utils/Constants.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AllCategoriesPage extends StatefulWidget {
  @override
  _AllCategoriesPageState createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {

  UserModel _userModel;
  List<CategoryModel> _categories = [];
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    Provider.of<CategoryProvider>(context, listen: false)
        .getAllCategories(_userModel.accessToken);
  }

  _refresh() async {
    await Future.delayed(Duration(milliseconds: 500));
    Provider.of<CategoryProvider>(context, listen: false)
        .getAllCategories(_userModel.accessToken);
    _refreshController.refreshCompleted();
  }

  _scrollListener() async {
    if(_controller.offset >= _controller.position.maxScrollExtent &&
      !_controller.position.outOfRange) {
        //load more
    }
    //if(x == 0) load no more
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Categories List"),
      ),
      body: Container(
        child: Consumer<CategoryProvider>(builder: (context,categoryProvider,child) {

          _categories = categoryProvider.allCategories;

          return SmartRefresher(
            scrollDirection: Axis.vertical,
            controller: _refreshController,
            header: WaterDropMaterialHeader(
              backgroundColor: Colors.blue,
            ),
            onRefresh: _refresh,
            child:  ListView.builder(
              controller: _controller,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, i) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.black12))
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero
                    ),
                    color: Colors.white,
                    elevation: 1.0,
                    margin: EdgeInsets.all(0),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: Container(
                        padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: Constants.CATEGORY_IMAGES + _categories[i].categoryImage,
                            placeholder: (context,url) => Center(
                              child:CircularProgressIndicator(
                                backgroundColor: Colors.green,
                              )
                            ),
                            errorWidget: (context,url,error) => new Icon(Icons.error),
                          )
                        )
                      ),
                      title: Container(
                        padding: EdgeInsets.all(10),
                        child: Text(_categories[i].categoryName),
                      ),
                      onTap: () {

                      },
                    ),
                  )
                );
              },
              itemCount: _categories.length,
            )
          );
        })
      )
    );
  }
}