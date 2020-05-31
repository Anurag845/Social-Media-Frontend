import 'package:flutter/foundation.dart';

class ChatMessageModel with ChangeNotifier{
  String id;
  String message;
  int messageType;
  String image;
  String senderName;
  String senderImg;
  String senderId;
  String conversationId;
  String _playerText = '00:00:00';

  ChatMessageModel({ 
    this.id,
    this.message,
    this.messageType,
    this.image,
    this.senderName,
    this.senderImg,
    this.senderId,
    this.conversationId
  });

  String get playerText => _playerText;

  set playerText(String value) {
    _playerText = value;
    notifyListeners();
  }
  int currentIcon = 0;

  void changePlayIcon() {
    if(currentIcon==0)
      currentIcon = 1;
    else
      currentIcon = 0;
    notifyListeners();
  }
}