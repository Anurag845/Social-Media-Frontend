import 'package:flutter/material.dart';
import 'package:navras/models/GoogleUserModel.dart';
import 'package:navras/models/UserModel.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:navras/utils/Constants.dart';

class AuthProvider with ChangeNotifier {
  io.Socket socket;

  UserModel _userModel;

  GoogleUserModel _googleUserModel;

  UserModel get userModel => _userModel;

  //GoogleUserModel get googleUserModel => _googleUserModel;

  setUserModel(UserModel value) {
    _userModel = value;
    notifyListeners();
  }

  /*setGoogleUserModel(GoogleUserModel model) {
    _googleUserModel = model;
    notifyListeners();
  }*/

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
