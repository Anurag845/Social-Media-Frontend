class NotificationModel {
  String id;
  String name;
  String title;
  String userImg;
  String postId;
  String peerId;
  int timeStamp;

  NotificationModel(
      {this.id,
      this.name,
      this.title,
      this.userImg,
      this.postId,
      this.peerId,
      this.timeStamp});

  NotificationModel.fromJson(Map<String, dynamic> map)
      : id = map['notif_id'],
        userImg = map['profile_pic'],
        title = map['title'],
        peerId = map['entity_owner_id'],
        postId = map['entity_id'],
        timeStamp = map['timestamp'],
        name = map['username'];
}
