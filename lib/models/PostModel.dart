import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PostModel with ChangeNotifier {
  String postId;
  String postOwnerId;
  String postData;
  int postLikes;
  int commentsCount;
  bool hasImg;
  bool isUserLiked;
  String userName;
  List<Attachment> attachments;
  String postImg;
  int timeStamp;
  String createdAt;
  String img;
  String displayName;

  PostModel({
    this.postId,
    this.postOwnerId,
    this.postData,
    this.postLikes,
    this.commentsCount,
    this.hasImg,
    this.isUserLiked,
    this.userName,
    this.displayName,
    this.postImg,
    this.timeStamp,
    this.img,
    this.attachments,
    this.createdAt
  });

  PostModel.fromJson(Map<String, dynamic> map)
  : postId = map['post_id'],
    postOwnerId = map['user_id'],
    hasImg = map['no_attachments'] > 0 ? true : false,
    isUserLiked = map['isUserLiked'],
    postData = map['descr'],
    postLikes = map['likes_count'],
    commentsCount = map['comments_count'],
    createdAt = map['created_at'],
    attachments = (jsonDecode(map['attachments']) as List).map((i) => Attachment.fromJson(i)).toList(),
    timeStamp = map['timestamp'],
    userName = map['username'],
    displayName = map['display_name'],
    img = map['profile_pic'];

  String toJson() {
      Map<String, dynamic> temp = {};

      temp['user_id'] = this.postOwnerId;

      temp['post_data'] = this.postData;

      temp['post_img'] = this.attachments[0].name;

      return jsonEncode(temp);
  }
}

class Attachment {
  String guid;
  String name;
  String effectId;
  String effectName;
  Color color1;
  Color color2;

  Attachment({
    this.guid,
    this.name,
    this.effectId,
    this.effectName,
    this.color1,
    this.color2
  });

  Attachment.fromJson(Map jsonMap)
  : guid = jsonMap['guid'],
    name = jsonMap['name'],
    effectId = jsonMap['effect_id'],
    effectName = jsonMap['effect_name'],
    color1 = jsonMap['color1'] == null ? Colors.transparent : Color(int.parse(jsonMap['color1'])),
    color2 = jsonMap['color2'] == null ? Colors.transparent : Color(int.parse(jsonMap['color2']));
}
