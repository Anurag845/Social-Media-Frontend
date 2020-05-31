//created by Hatem Ragap
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lockdown_diaries/models/NotificationModel.dart';
import 'package:lockdown_diaries/models/UserModel.dart';
import 'package:lockdown_diaries/providers/AuthProvider.dart';
import 'package:lockdown_diaries/providers/NotificationProvider.dart';
import 'package:lockdown_diaries/widgets/NotificationItem.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> _listNotification = [];
  UserModel _userModel;

  @override
  void initState() {
    super.initState();
    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    Provider.of<NotificationProvider>(context, listen: false)
        .startGetNotificationsData(_userModel.userId);
  }

  @override
  Widget build(BuildContext context) {
    _listNotification = [];
    _listNotification =
        Provider.of<NotificationProvider>(context).listNotification;
    return _listNotification.length == 0
    ? Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/empty.png',
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'No Notifications yet',
                style: TextStyle(fontSize: 15),
              )
            ],
          ),
        ),
      )
    : Container(
        child: ListView.builder(
          itemBuilder: (context, i) {
            return NotificationItem(_listNotification[i]);
          },
          shrinkWrap: true,
          itemCount: _listNotification.length,
        )
      );
  }
}
