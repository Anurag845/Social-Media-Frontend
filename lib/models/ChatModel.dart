class ChatModel {
  String chatId;
  String chatName;
  String chatImg;
  String conversationId;
  //String createdAt;

  ChatModel(this.chatId, this.chatName, this.chatImg, this.conversationId);

  ChatModel.fromJson(Map<String, dynamic> map)
    : chatId = map['chat_id'],
      chatName = map['chat_name'],
      chatImg = map['chat_img'],
      conversationId = map['conversation_id'];
      //createdAt = map['created_at'];
}
