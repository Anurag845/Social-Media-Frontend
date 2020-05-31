//created by Hatem Ragap
import 'dart:convert';

class UserModel {
  String username;
  String userId;
  String email;
  String token;
  String img;
  String profileAbout;
  int timeStamp;
  String accessToken;
  String displayName;

  UserModel(
      {this.userId,
      this.username,
      this.email,
      this.img,
      this.timeStamp,
      this.token,
      this.profileAbout,
      this.accessToken,
      this.displayName});

  UserModel.fromJson(Map<String, dynamic> map)
    : username = map['username'],
      userId = map['user_id'],
      profileAbout = map['profile_about'],
      //token = map['token'],
      email = map['email'],
      img = map['profile_pic'],
      accessToken = map['accessToken'],
      displayName = map['display_name'];
      //timeStamp = map['timestamp'];

  String toJson(UserModel adminModel) {
    Map<String, dynamic> temp = {};
    temp['username'] = adminModel.username;
    temp['user_id'] = adminModel.userId;
    temp['email'] = adminModel.email;
    temp['token'] = adminModel.token;
    temp['img'] = adminModel.img;
    temp['profile_about'] = adminModel.profileAbout;
    temp['accessToken'] = adminModel.accessToken;

    return jsonEncode(temp);
  }
}
