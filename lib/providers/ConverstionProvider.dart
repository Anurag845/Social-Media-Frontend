import 'package:flutter/foundation.dart';

import 'package:navras/models/ConversionModel.dart';
import 'package:navras/models/UserModel.dart';
import 'package:navras/utils/Constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ConversionProvider with ChangeNotifier {
  UserModel _userModel;

  List<ConversionModel> _conversionList = [];

  List<ConversionModel> get conversionList => _conversionList;

  bool isPeerSeeLastMessage = false;

  void setIsPeerSeeLastMessage(bool value) {
    isPeerSeeLastMessage = value;
    notifyListeners();
  }

  initConversionSocketAndRequestChats(UserModel userModel) {
    this._userModel = userModel;
    var url = '${Constants.SOCKET_URL}/api/chatRoomList';

    io.Socket roomSocket = io.io('$url', <String, dynamic>{
      'transports': ['websocket']
    });

    roomSocket.on('connect', (_) {
      //send request to server to ge messages
      roomSocket.emit('getConversionsList', userModel.userId);
    });

    roomSocket.on('ConversionsListReady', (res) {
      // once server send Conversions
      try {
        if (!res['error']) {
          //data will send as this for single conversion
          /*   {
                   "error": "false",
                   "data": [
                   {
                       "lastMessage": {
                           "users_see_message": ["5e732abc41166a00173ab507"],
                           "message": "hgf"
                       },
                       "users": [
                           {
                               "token": "user token",
                               "img": "default-user-profile-image.png",
                               "_id": "5e732abc41166a00173ab507",
                               "user_name": "gdfgsdf"
                           },
                           {
                               "token": "fiLeEB6sFFE:-bp-xKC34TFVlrUXC",
                               "img": "1584605354597-received_479678612912945.png",
                               "_id": "5e72744475d74e0017a62f5a",
                               "user_name": "Admin"
                           }
                       ],
                       "created": "2020-03-19T08:48:48.629Z",
                       "_id": "5e7331ea41166a00173ab508",
                       "createdAt": "2020-03-19T08:48:42.682Z",
                       "updatedAt": "2020-03-19T08:48:48.667Z",
                       "__v": 0
                   }
               ],
                   "onLineUsersId": ["5e732abc41166a00173ab507"]
               }*/
          //if user id in _listOnlineUsers make this user Online else offline
          List<dynamic> _listOnlineUsers = res['onLineUsersId'];
          var listData = res['data'];
          List<ConversionModel> temp = [];

          for (int i = 0; i < listData.length; i++) {
            String userOne = res['data'][i]['users'][0]['_id'];
            String chatId = res['data'][i]['_id'];

            int indexOfPeerUser = 0;
            if (userOne == _userModel.userId) {
              indexOfPeerUser = 1;
            } else {
              indexOfPeerUser = 0;
            }
            var userModel = res['data'][i]['users'][indexOfPeerUser];
            temp.add(ConversionModel(
                chatId: chatId,
                userName: userModel['user_name'],
                token: userModel['token'],
                userImg: userModel['img'],
                userId: userModel['_id'],
                lastMessage: res['data'][i]['lastMessage']['message'],
                isOnline: _listOnlineUsers.contains(userModel['_id']),
                isTwoUsersSeeLastMessage:
                    res['data'][i]['lastMessage']['users_see_message'].length ==
                        2,
                isLastMessageSeen: res['data'][i]['lastMessage']
                        ['users_see_message']
                    .contains(_userModel.userId)
              )
            );
          }
          _conversionList = temp;
          temp = null;
          notifyListeners();
        }
        else {
          print("Conversions provider"+res);
        }
      }
      catch (err) {
        print("Conversions provider"+err.toString());
      }
    });

    roomSocket.on('updateChatRoomList', (data) {
      roomSocket.emit('getConversionsList', _userModel.userId);
    });

    //invoke if any user get online or offline
    roomSocket.on('onOnlineUserListUpdate', (res) {
      //list of Users Online
      List dataOnline = res;
      //is list length = 0 mean there no users online make all offline
      if (dataOnline.length == 0) {
        _conversionList.forEach((user) {
          user.isOnline = false;
        });
        notifyListeners();
      }
      else {
        _conversionList.forEach((user) {
          if (res.contains(user.userId)) {
            user.isOnline = true;
          }
          else {
            user.isOnline = false;
          }
        });
        notifyListeners();
      }
    });
  }
}
