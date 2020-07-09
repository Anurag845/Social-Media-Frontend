import 'package:flutter/material.dart';
import 'package:lockdown_diaries/models/UserModel.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:lockdown_diaries/utils/Constants.dart';

class AuthProvider with ChangeNotifier {
  io.Socket socket;

  UserModel _userModel;

  // ignore: unnecessary_getters_setters
  UserModel get userModel => _userModel;

  // ignore: unnecessary_getters_setters
  set userModel(UserModel value) {
    _userModel = value;
  }

  void updateImg(String img) {
    _userModel.img = img;
    notifyListeners();
  }

  void updateBio(String bio) {
    _userModel.profileAbout = bio;
    notifyListeners();
  }

  void updateUserNameAndBio(String userName, String bio) {
    _userModel.username = userName;
    _userModel.profileAbout = bio;
    notifyListeners();
  }

  void sendOnline() {
    var url = '${Constants.SOCKET_URL}';
    socket = io.io('$url', <String, dynamic>{
      'transports': ['websocket']
    });
    socket.on('connect', (_) {
      socket.emit('goOnline', _userModel.userId);
    });
  }

  void disconnect() {
    if (socket != null) {
      socket.destroy();
    }
  }
}
