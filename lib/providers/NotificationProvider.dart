import 'package:flutter/foundation.dart';
import 'package:lockdown_diaries/models/NotificationModel.dart';
import 'package:lockdown_diaries/utils/Constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _listNotification = [];

  List<NotificationModel> get listNotification => _listNotification;

  Future<void> startGetNotificationsData(String id) {
    _listNotification = [];

    String _url = "${Constants.SERVER_URL}notifications/fetch_all";
    return http.post(_url, body: {'user_id': id}).then((res) async {
      var convertedData = convert.jsonDecode(res.body);
      if (!convertedData['error']) {
        List data = convertedData['data'];

        _listNotification =
            data.map((item) => NotificationModel.fromJson(item)).toList();
      }
      notifyListeners();
    });
  }
}
