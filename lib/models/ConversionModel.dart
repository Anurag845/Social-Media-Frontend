class ConversionModel {
  String chatId;
  String userName;
  String token;
  String userImg;
  String userId;
  String lastMessage;
  bool isOnline;
  bool isLastMessageSeen;
  bool isTwoUsersSeeLastMessage;

  ConversionModel(
      {this.chatId,
      this.userName,
      this.isTwoUsersSeeLastMessage,
      this.token,
      this.userImg,
      this.userId,
      this.lastMessage,
      this.isOnline,
      this.isLastMessageSeen});
}
