import 'dart:io';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:lockdown_diaries/models/GroupModel.dart';
import 'package:lockdown_diaries/models/UserModel.dart';
import 'package:lockdown_diaries/utils/Constants.dart';

class GroupProvider with ChangeNotifier {
  List<GroupModel> _allusergroups = [];
  List<GroupModel> _usergroupsbycategory = [];
  List<UserModel> _participants = [];
  List<UserModel> _inviteList = [];
  GroupModel _group;

  List<GroupModel> get allUserGroups => _allusergroups;
  List<GroupModel> get userGroupsbyCategory => _usergroupsbycategory;
  List<UserModel> get groupParticipants => _participants;
  GroupModel get groupInfo => _group;
  List<UserModel> get inviteList => _inviteList;

  Future<void> getAllUserGroups(String userId, String accessToken) async {
    return http.post(
      '${Constants.SERVER_URL}groups/getAllUserGroups',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      },
      body: convert.jsonEncode({
        "user_id": userId
      })
    ).then((res) async {
      var convertedData = convert.jsonDecode(res.body);
      if(!convertedData["error"]) {
        List data = convertedData["data"];
        _allusergroups = data.map<GroupModel>((i) => GroupModel.fromJson(i)).toList();
      }
      else {
        print(convertedData["data"]);
      }
      notifyListeners();
    });
  }

  Future<void> getUserGroupsbyCategory(String userId, String accessToken, int categoryId) async {
    return http.post(
      '${Constants.SERVER_URL}groups/getUserGroupsbyCategory',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      },
      body: convert.jsonEncode({
        "user_id": userId,
        "category_id": categoryId
      })
    ).then((res) async {
      var convertedData = convert.jsonDecode(res.body);
      if(!convertedData["error"]) {
        List data = convertedData["data"];
        _usergroupsbycategory = data.map<GroupModel>((i) => GroupModel.fromJson(i)).toList();
      }
      else {
        print(convertedData["data"]);
      }
      notifyListeners();
    });
  }

  Future<void> getParticipants(String groupId, String accessToken) async {
    return http.post(
      '${Constants.SERVER_URL}groups/getParticipants',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      },
      body: convert.jsonEncode({
        "group_id": groupId,
      })
    ).then((res) async {
      var convertedData = convert.jsonDecode(res.body);
      if(!convertedData["error"]) {
        List data = convertedData["data"];
        _participants = data.map<UserModel>((i) => UserModel.fromJson(i)).toList();
      }
      else {
        print(convertedData["data"]);
      }
      notifyListeners();
    });
  }

  Future<void> getInviteList(String userId, String groupId, String accessToken) async {
    return http.post(
      '${Constants.SERVER_URL}groups/getInviteList',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      },
      body: convert.jsonEncode({
        "group_id": groupId,
        "user_id": userId
      })
    ).then((res) async {
      var convertedData = convert.jsonDecode(res.body);
      if(!convertedData["error"]) {
        List data = convertedData["data"];
        _inviteList = data.map<UserModel>((i) => UserModel.fromJson(i)).toList();
      }
      else {
        print(convertedData["data"]);
      }
      notifyListeners();
    });
  }

  Future<void> getGroupInfo(String groupId, String accessToken) {
    return http.post(
      '${Constants.SERVER_URL}groups/getInfo',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      },
      body: convert.jsonEncode({
        "group_id": groupId,
      })
    ).then((res) async {
      var convertedData = convert.jsonDecode(res.body);
      if(!convertedData["error"]) {
        var data = convertedData["data"];
        _group = GroupModel.fromJson(data);
      }
      else {
        print(convertedData["data"]);
      }
      notifyListeners();
    });
  }
}