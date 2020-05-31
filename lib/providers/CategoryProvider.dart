import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:lockdown_diaries/models/CategoryModel.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:lockdown_diaries/utils/Constants.dart';
import 'dart:convert' as convert;

class CategoryProvider with ChangeNotifier {
  List<CategoryModel> _categories = [];

  List<CategoryModel> get allCategories => _categories;

  Future<void> getAllCategories(String accessToken) async {
    return http.post(
      '${Constants.SERVER_URL}categories/getCategories',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }
    ).then((res) async {
      var convertedData = convert.jsonDecode(res.body);
      if(!convertedData["error"]) {
        var data = convertedData["data"];
        _categories = data.map<CategoryModel>((i) => CategoryModel.fromJson(i)).toList();
      }
      else {
        print(convertedData["error"]);
      }
      notifyListeners();
    });
  }
}