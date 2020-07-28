import 'package:flutter/foundation.dart';

class CommentsModel {
  String comment;
  String commentId;
  String postId;
  String userName;
  String userId;
  String userImg;
  String postOwnerId;

  CommentsModel(
      {@required this.commentId,
      this.comment,
      this.postId,
      this.userName,
      this.userId,
      this.userImg,
      this.postOwnerId});
}
