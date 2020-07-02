import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lockdown_diaries/providers/CategoryProvider.dart';
import 'package:lockdown_diaries/providers/GroupProvider.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:lockdown_diaries/models/ChatModel.dart';
import 'package:lockdown_diaries/models/PostModel.dart';
import 'package:lockdown_diaries/models/UserModel.dart';
import 'package:lockdown_diaries/pages/ChatMessagesPage.dart';
import 'package:lockdown_diaries/pages/CommentsPage.dart';
import 'package:lockdown_diaries/pages/GroupChatsPage.dart';
import 'package:lockdown_diaries/pages/PersonalChatsPage.dart';
import 'dart:convert' as convert;
import 'package:lockdown_diaries/providers/AppBarProvider.dart';
import 'package:lockdown_diaries/providers/AuthProvider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:lockdown_diaries/providers/PostProvider.dart';
import 'package:lockdown_diaries/providers/Theme_provider.dart';
import 'package:lockdown_diaries/utils/Constants.dart';
import 'package:lockdown_diaries/customAppBars/HomeAppBar.dart';
import 'Notifictionpage.dart';
import 'PostsPage.dart';
import 'Settings.dart';
import 'package:http/http.dart' as http;
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int index = 0;
  io.Socket socket;
  io.Socket roomSocket;
  static int i = 0;
  static int i2 = 0;
  static int i3 = 0;
  UserModel _userModel;
  FirebaseMessaging _fcm = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  List<Widget> pages = [];

  List<Widget> options = [];

  SolidController _controller = SolidController();

  @override
  void initState() {
    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;

    Provider.of<PostProvider>(context, listen: false)
        .startGetPostsData(_userModel.userId, _userModel.accessToken);

    Provider.of<CategoryProvider>(context, listen: false)
        .getAllCategories(_userModel.accessToken);

    Provider.of<GroupProvider>(context, listen: false)
        .getAllUserGroups(_userModel.userId, _userModel.accessToken);

    pages.add(PostsPage());
    pages.add(NotificationPage());
    pages.add(GroupChatsPage(_userModel));
    pages.add(PersonalChatsPage());
    pages.add(Settings());

    options.insert(
        0,
        ListTile(
          leading: Icon(Icons.bubble_chart, color: Colors.red[600], size: 32),
          title: Text("Speak your mind"),
          onTap: () {},
        ));
    options.insert(
        1,
        ListTile(
          leading: Icon(Icons.camera, color: Colors.blue[600], size: 32),
          title: Text("Share this moment"),
          onTap: () {
            Navigator.of(context).pushNamed(Constants.MomentPageRoute);
          },
        ));
    options.insert(
        2,
        ListTile(
          leading: Icon(Icons.camera_roll, color: Colors.orange[600], size: 32),
          title: Text("Share a memory"),
          onTap: () {
            Navigator.of(context).pushNamed(Constants.MemoryPageRoute);
          },
        ));
    options.insert(
        3,
        ListTile(
          leading:
              Icon(Icons.directions_run, color: Colors.purple[600], size: 32),
          title: Text("Showcase your talent"),
          onTap: () {
            Navigator.of(context).pushNamed(Constants.CaptureTalentPageRoute);
          },
        ));
    options.insert(
        4,
        ListTile(
          leading: Icon(Icons.place, color: Colors.pink[600], size: 32),
          title: Text("I've been here"),
          onTap: () {},
        ));
    options.insert(
        5,
        ListTile(
          leading: Icon(Icons.camera_front, color: Colors.green, size: 32),
          title: Text("Start a story"),
          onTap: () {},
        ));
    options.insert(
        6,
        ListTile(
          leading: Icon(Icons.settings_input_svideo,
              color: Colors.teal[800], size: 32),
          title: Text("My status today"),
          onTap: () {},
        ));

    super.initState();
    initSocket();
    registerNotification();
    configLocalNotification();
  }

  @override
  Widget build(BuildContext context) {
    index = Provider.of<AppBarProvider>(context, listen: true).getIndex();
    final themeProvider = Provider.of<ThemeProvider>(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          backgroundColor: themeProvider.getThemeData.backgroundColor,
          appBar: HomeAppBar(),
          body: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: pages[index],
            ),
          ),
          bottomSheet: SingleChildScrollView(
            child: SolidBottomSheet(
                controller: _controller,
                draggableBody: true,
                maxHeight: 420,
                headerBar: Container(
                  height: 50,
                  decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(10.0),
                          topRight: const Radius.circular(10.0))),
                  child: Center(
                    child: Text(
                      "Hey, what's up?",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
                ),
                body: Container(
                  child: ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        return options[index];
                      }),
                )),
          )
        ),
    );
  }

  void registerNotification() async {
    await Future.delayed(Duration(seconds: 1));

    await _fcm.getToken().then((token) async {
      try {
        await http.post('${Constants.SERVER_URL}user/update_user_token',
            headers: {
              HttpHeaders.contentTypeHeader: "application/json",
              HttpHeaders.authorizationHeader:
                  "Bearer ${_userModel.accessToken}"
            },
            body: convert.jsonEncode(
                {'user_id': '${_userModel.userId}', 'token': '$token'}));
      } catch (err) {}
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });

    _fcm.requestNotificationPermissions();
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (i2 % 2 == 0) {
          //update posts
          Provider.of<PostProvider>(context, listen: false)
              .startGetPostsData(_userModel.userId, _userModel.accessToken);
        }
        i2++;
        //refresh posts and notifications when app open

        if (Platform.isIOS) {
          var fetchedMessage = message['notification'];
          //show overlay in foreground for ios only

          setState(() {
            showOverlayNotification((context) {
              return Material(
                child: InkWell(
                  onTap: () {
                    startNavigate(message);
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    margin: const EdgeInsets.only(left: 16, right: 16, top: 10),
                    elevation: 3,
                    color: Theme.of(context).primaryColor,
                    child: SafeArea(
                      child: ListTile(
                        onTap: () {
                          startNavigate(message);
                        },
                        title: Text(fetchedMessage['title'],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Text(fetchedMessage['body'],
                            style: TextStyle(
                              fontSize: 14,
                            )),
                      ),
                    ),
                  ),
                ),
              );
            }, duration: Duration(seconds: 3));
          });
        }

        showNotification(message['notification'], message);

        return;
      },
      onResume: (Map<String, dynamic> data) {
        startNavigate(data);

        return;
      },
      onLaunch: (Map<String, dynamic> data) {
        startNavigate(data);

        return;
      },
    );
  }

  void configLocalNotification() {
    //get icon from android/manifest
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: _startOnSelect);
  }

  @override
  void dispose() {
    super.dispose();

    if (roomSocket != null) {
      roomSocket.disconnect();
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => exit(0),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void initSocket() async {
    Provider.of<AuthProvider>(context, listen: false).sendOnline();
  }

  Future _startOnSelect(payload) {
    // for only one navigate
    if (i % 2 == 0) {
      var data = convert.jsonDecode(payload);
      String screen = data['data']['screen'];
      if (screen == 'chat') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChatMessagesPage(
                ChatModel(
                  data['data']['chat_id'],
                  data['data']['name'],
                  data['data']['img'],
                  data['data']['conversation_id'],
                ),
                "PC")));
      } else if (screen == 'comment') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => CommentsPage(
                PostModel(
                    postId: data['data']['id'],
                    postOwnerId: data['data']['post_owner_id']),
                false)));
      } else if (screen == 'like') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => CommentsPage(
                PostModel(
                    postId: data['data']['id'],
                    postOwnerId: data['data']['post_owner_id']),
                false)));
      }
    }
    i++;
    return Future<void>.value();
  }

  void showNotification(message, message2) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.hatem.lockdown_diaries'
          : 'com.duytq.flutterchatdemo',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'], platformChannelSpecifics,
        payload: convert.jsonEncode(message2));
  }

  void startNavigate(Map<String, dynamic> data) {
    if (i3 % 2 == 0) {
      var notificationData = Platform.isIOS ? data : data['data'];
      String screen = notificationData['screen'];

      if (screen == 'chat') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChatMessagesPage(
                ChatModel(
                  notificationData['chat_id'],
                  notificationData['name'],
                  notificationData['img'],
                  notificationData['conversation_id'],
                ),
                "PC")));
      } else if (screen == 'comment') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => CommentsPage(
                PostModel(
                    postId: notificationData['id'],
                    postOwnerId: notificationData['post_owner_id']),
                false)));
      } else if (screen == 'like') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => CommentsPage(
                PostModel(
                    postId: notificationData['id'],
                    postOwnerId: notificationData['post_owner_id']),
                false)));
      }
    }
    i3++;
  }
}
