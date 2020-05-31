//created by Hatem Ragap
import 'package:flutter/foundation.dart';

class MessageModel with ChangeNotifier{
  String id;
  String message;
  int messageType;
  int isDeleted;
  String senderId;
  String img;
  String receiverId;
  String userName;
  String userImg;
  String _playerText = '00:00:00';


  MessageModel(
      {this.id,
        this.message,
        this.messageType,
        this.senderId,
        this.receiverId,
        this.isDeleted,
        this.userImg,
        this.userName,
        this.img});

  String get playerText => _playerText;

  set playerText(String value) {
    _playerText = value;
    notifyListeners();
  }
  int currentIcon = 0;




  void changePlayIcon(){
    if(currentIcon==0)
      currentIcon = 1;
    else
      currentIcon = 0;
    notifyListeners();

  }



}
