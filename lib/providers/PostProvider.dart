import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:lockdown_diaries/models/PostModel.dart';
import 'package:lockdown_diaries/utils/Constants.dart';

class PostProvider with ChangeNotifier {
  List<PostModel> _postModelList = [];

  List<PostModel> get listPosts => _postModelList;
  int offset = 0;

  Future<void> startGetPostsData(String userId, String accessToken) {
    _postModelList = [];

    offset = 0;
    String _url = "${Constants.SERVER_URL}post/fetch";
    return http.post(
      _url,
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      },
      body: convert.jsonEncode({
        "user_id": userId,
        "offset": offset
      })
    ).then((res) async {
      var convertedData = convert.jsonDecode(res.body);
      if (!convertedData['error']) {
        List data = convertedData['data'];
        _postModelList = data.map((i) => PostModel.fromJson(i)).toList();
      }
      notifyListeners();
    })
    .catchError((err) {
      print('init Data error is $err');
    });
  }

  Future<int> loadMore(String userId, String accessToken) async {
    offset += 20;
    String _url = "${Constants.SERVER_URL}post/fetch";
    try {
      var req = await http.post(
        _url,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        },
        body: convert.jsonEncode({
          "user_id": userId,
          "offset": offset
        })
      );
      var convertedData = convert.jsonDecode(req.body);
      if (!convertedData['error']) {
        List data = convertedData['data'];
        _postModelList
            .addAll(data.map((data) => PostModel.fromJson(data)).toList());
        notifyListeners();
        return 1;
      }
      else {
        notifyListeners();
        return 0;
      }
    }
    catch (err) {
      return 0;
    }
  }

  void removePostFromListByPostId(String postId) {
    _postModelList.removeWhere((item) => item.postId == postId);
    notifyListeners();
  }

  void deletePostRequest(String postId, String accessToken) async {
    try {
      await http.post(
        '${Constants.SERVER_URL}post/deletePost',
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        },
        body: convert.jsonEncode({
          'post_id': postId
        })
      );
      removePostFromListByPostId(postId);
    }
    catch (err) {
      Fluttertoast.showToast(msg: 'error while delete post  try again !');
    }
    notifyListeners();
  }
}
