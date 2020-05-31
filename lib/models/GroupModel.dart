class GroupModel {
  String groupId;
  String groupName;
  int categoryId;
  String createdAt;
  String ownerId;
  String descr;
  String groupStatus;
  String conversationId;
  String groupImage;

  GroupModel(this.groupId, this.groupName, this.categoryId, this.createdAt, this.ownerId, this.descr, this.groupStatus, this.conversationId, this.groupImage);

  GroupModel.fromJson(Map<String,dynamic> map) :
    groupId = map["group_id"],
    groupName = map["group_name"],
    categoryId = map["category_id"],
    createdAt = map["created_at"],
    ownerId = map["owner_id"],
    descr = map["descr"],
    groupStatus = map["group_status"],
    conversationId = map["conversation_id"],
    groupImage = map["group_image"];
}