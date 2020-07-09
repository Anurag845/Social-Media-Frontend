import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bubble/bubble.dart';
import 'dart:io' as io;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:lockdown_diaries/customAppBars/ChatAppbar.dart';
import 'package:lockdown_diaries/models/ChatMessageModel.dart';
import 'package:lockdown_diaries/models/ChatModel.dart';
import 'package:lockdown_diaries/models/UserModel.dart';
import 'package:lockdown_diaries/providers/AuthProvider.dart';
import 'package:lockdown_diaries/providers/Theme_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:lockdown_diaries/utils/Constants.dart';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as Path;

import 'FullScreenImg.dart';

class ChatMessagesPage extends StatefulWidget {
  final ChatModel chatInfo;
  final String chatType;

  ChatMessagesPage(this.chatInfo,this.chatType);

  @override
  _ChatMessagesPageState createState() =>
      _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  UserModel _userModel;
  List<ChatMessageModel> _listMessages = [];
  io.Socket socket;
  TextEditingController _txtController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  final double minValue = 8.0;
  final double iconSize = 28.0;
  String numClients;

  bool isMicrophone = false;
  bool isCurrentUserTyping = false;

  FlutterSound recorderModule = FlutterSound();
  FlutterSound playerModule = FlutterSound();
  StreamSubscription _recorderSubscription;

  double maxDuration = 1.0;
  StreamSubscription _playerSubscription;

  String localFilePath;
  String maxRecordDuration;
  final LocalFileSystem localFileSystem = LocalFileSystem();
  String path;
  String message = '';

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  ScrollController _scrollController;
  int page = 1;

  @override
  void initState() {
    super.initState();
    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    initSocket();
    startGetLastMessages();
    _initRecorder();
  }

  void initSocket() async {
    String URI = "${Constants.SOCKET_URL}/api/joinConversation";
    socket = io.io('$URI', <String, dynamic>{
      'transports': ['websocket']
    });
    socket.on('connect', (_) {
      sendJoin();
    });
    socket.on('disconnect', (_) => print('disconnect'));

    socket.on('RoomMsgReceive', (data) {
      _onReceiveCommentMessage(data);
    });

    socket.on('UserJoin', (msg) {
      var data = convert.jsonDecode(msg);

      setState(() {
        numClients = '${data['numClients']}';
        /*_listMessages.insert(
          0,
          ChatMessageModel(
            senderName: data['sendername'], isJoin: true
          )
        );*/
      });
    });
  }

  void sendJoin() {
    String conversationId = widget.chatInfo.conversationId;
    var mainMap = Map<String, Object>();
    mainMap['conversation_id'] = conversationId;
    mainMap['username'] = _userModel.username;
    String jsonString = convert.jsonEncode(mainMap);
    socket.emit("joinConversation", [jsonString]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    cancelRecord();
    _unSubscribes();
    _txtController.dispose();
    if (recorderModule != null) closeRecorder();
    cancelPlayerSubscriptions();
    releaseFlauto();
    super.dispose();
  }

  _unSubscribes() {
    if (socket != null) {
      socket.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    ScreenUtil.init(context);

    return Scaffold(
      backgroundColor: themeProvider.getThemeData.backgroundColor,
      appBar: ChatAppbar(
        widget.chatInfo.chatId,widget.chatInfo.chatImg,widget.chatType == 'PC',
        widget.chatInfo.chatName,widget.chatType
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: SmartRefresher(
              header: WaterDropHeader(),
              onLoading: _onLoadMore,
              enablePullUp: true,
              enablePullDown: false,
              controller: _refreshController,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _listMessages.length,
                reverse: true,
                itemBuilder: (context, index) {
                  var myMessage = _listMessages[index];
                  if (myMessage.senderId == _userModel.userId) {
                    //my message
                    return InkWell(
                      onLongPress: () {
                        if (_userModel.userId == _listMessages[index].senderId)
                          showDialog(
                            context: context,
                            builder: (context0) {
                              return AlertDialog(
                                contentPadding: EdgeInsets.all(0),
                                content: Container(
                                  padding: EdgeInsets.only(
                                    top: 20,
                                    bottom: 20,
                                    left: 10,
                                    right: 10
                                  ),
                                  child: Text('delete from every one')
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      startDeleteMessage(_listMessages[index].id);
                                    },
                                    child: Text('delete')
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('cancel')
                                  )
                                ],
                              );
                            }
                          );
                      },
                      child: Bubble(
                        padding: BubbleEdges.all(9),
                        margin: BubbleEdges.only(
                          top: (index < _listMessages.length - 1)
                              ? ScreenUtil().setHeight(5.0)
                              : ScreenUtil().setHeight(20.0),
                          left: ScreenUtil().setWidth(100.0),
                          bottom: index == 0
                              ? ScreenUtil().setHeight(10.0)
                              : ScreenUtil().setHeight(0.0)
                        ),
                        elevation: 0.4,
                        nip: BubbleNip.no,
                        color: themeProvider.getThemeData.brightness ==
                                Brightness.dark
                            ? Colors.blue
                            : Colors.blue.shade300,
                        style: new BubbleStyle(
                            radius: Radius.circular(ScreenUtil().setWidth(40.0))
                        ),
                        nipHeight: ScreenUtil().setHeight(20),
                        nipWidth: ScreenUtil().setWidth(23),
                        alignment: Alignment.centerRight,
                        child: myMessage.messageType == 0
                        ? SelectableText(
                            '${myMessage.message}',
                            textAlign: TextAlign.start,
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w400,
                              fontSize: 18
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullScreenImg(
                                    Constants.USERS_MESSAGES_IMAGES + myMessage.image
                                  )
                                )
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: Constants.USERS_MESSAGES_IMAGES + myMessage.image,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              placeholder: (r, e) {
                                return Container(
                                  padding: EdgeInsets.all(60),
                                  color: themeProvider
                                      .getThemeData.buttonColor,
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                          )
                      ),
                    );
                  }
                  else {
                    //peer message
                    return InkWell(
                      onLongPress: () {
                        if (_userModel.userId == _listMessages[index].senderId)
                          showDialog(
                            context: context,
                            builder: (context0) {
                              return AlertDialog(
                                contentPadding: EdgeInsets.all(0),
                                content: InkWell(
                                  onTap: () {
                                    startDeleteMessage(_listMessages[index].id);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.only(
                                      top: 20,
                                      bottom: 20,
                                      left: 10,
                                      right: 10
                                    ),
                                    child: Text('delete from every one')
                                  )
                                ),
                              );
                            }
                          );
                      },
                      child: Bubble(
                        padding: BubbleEdges.all(9),
                        nip: BubbleNip.no,
                        margin: BubbleEdges.only(top: 10),
                        color: themeProvider.getThemeData.brightness ==
                                Brightness.dark
                            ? Colors.white30
                            : Colors.grey.shade100,
                        nipHeight: ScreenUtil().setHeight(20),
                        nipWidth: ScreenUtil().setWidth(23),
                        style: new BubbleStyle(
                            radius: Radius.circular(ScreenUtil().setWidth(40.0)
                          )
                        ),
                        alignment: Alignment.centerLeft,
                        elevation: 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Visibility(
                              child: Text('${myMessage.senderName}',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14
                                )
                              ),
                              visible: widget.chatType == 'GC',
                            ),
                            myMessage.messageType == 0
                            ? SelectableText(
                              '${myMessage.message}',
                              style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w400,
                                fontSize: 18)
                              )
                            : InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FullScreenImg(
                                        Constants.USERS_MESSAGES_IMAGES + myMessage.image
                                      )
                                    )
                                  );
                                },
                                child: CachedNetworkImage(
                                  imageUrl: Constants.USERS_MESSAGES_IMAGES + myMessage.image,
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  placeholder: (r, e) {
                                    return Container(
                                      padding: EdgeInsets.all(60),
                                      color: Colors.grey.shade200,
                                      child:
                                          CircularProgressIndicator(
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomSection(themeProvider),
          )
        ],
      ),
    );
  }

  _buildBottomSection(themeProvider) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 52,
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: themeProvider.getThemeData.dividerColor,
              borderRadius: BorderRadius.all(Radius.circular(8.0 * 4))
            ),
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    setState(() {
                      isMicrophone = true;
                    });
                  },
                  child: Icon(FontAwesomeIcons.microphone)
                ),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                  onTap: () {
                    startGetAndUploadPhoto();
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.photo),
                    ],
                  )
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextField(
                    autocorrect: true,
                    maxLines: null,
                    onChanged: _onMessageChanged,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.multiline,
                    controller: _txtController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type your message"),
                    autofocus: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: minValue, top: 5, bottom: 5),
          child: FloatingActionButton(
            elevation: 0,
            onPressed: () {
              if (message == '') {
                Fluttertoast.showToast(msg: 'cant send empty message');
              }
              else {
                _sendMessage();
              }
            },
            child: Icon(
              Icons.send,
              size: 25,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void _onReceiveCommentMessage(var msg) {
    try {
      var data = convert.jsonDecode(msg);

      setState(() {
        _listMessages.insert(
          0,
          ChatMessageModel(
            senderId: data['sender_id'],
            senderImg: data['sender_img'],
            senderName: data['sender_name'],
            message: data['message'],
            messageType: int.parse(data['message_type']),
            image: data['image']
          )
        );
      });
    }
    catch (err) {
      print('error is $err');
    }
  }

  void _sendMessage({int type = 0, String image = ''}) {
    var mainMap = Map<String, Object>();
    mainMap['sender_id'] = _userModel.userId;
    mainMap['message'] = type == 0 ? _txtController.text : 'Send image';
    mainMap['sender_name'] = _userModel.username;
    mainMap['sender_img'] = _userModel.img;
    mainMap['chat_id'] = widget.chatInfo.chatId;
    mainMap['conversation_id'] = widget.chatInfo.conversationId;
    mainMap['message_type'] = type;
    mainMap['image'] = image;
    mainMap['chat_type'] = widget.chatType;
    String jsonString = convert.jsonEncode(mainMap);
    socket.emit('new_comment', [jsonString]);
    if(type == 0) {
      setState(() {
        _listMessages.insert(
          0,
          ChatMessageModel(
            senderId: _userModel.userId,
            senderName: _userModel.username,
            senderImg: _userModel.img,
            message: _txtController.text,
            messageType: 0,
            image: ""
          )
        );
      });
    }
    else if(type == 1) {
      setState(() {
        _listMessages.insert(
          0,
          ChatMessageModel(
            senderId: _userModel.userId,
            senderName: _userModel.username,
            senderImg: _userModel.img,
            message: _txtController.text,
            messageType: 1,
            image: image
          )
        );
      });
    }

    _txtController.clear();
    _scrollToLast();
  }

  void startGetLastMessages() async {
    page = 1;
    var req = await http.post(
      '${Constants.SERVER_URL}chatMessages/getMessages',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${_userModel.accessToken}"
      },
      body: convert.jsonEncode({
        'conversation_id': '${widget.chatInfo.conversationId}',
        'user_id': '${_userModel.userId}'
      })
    );
    var res = convert.jsonDecode(req.body);
    if (!res['error']) {
      List data = res['data'];
      List<ChatMessageModel> temp = [];
      for (int i = 0; i < data.length; i++) {
        temp.add(ChatMessageModel(
            senderId: data[i]['sender_id'],
            senderName: data[i]['display_name'],
            message: data[i]['message'],
            senderImg: data[i]['profile_pic'],
            messageType: data[i]['message_type'],
            image: data[i]['image']
          )
        );
      }
      setState(() {
        _listMessages = temp;
        temp = null;
      });
    }
  }

  void _onLoadMore() async {
    ++page;
    var req = await http.post(
      '${Constants.SERVER_URL}chatMessages/getMessages',
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer ${_userModel.accessToken}"
      },
      body: convert.jsonEncode({
        'conversation_id': '${widget.chatInfo.conversationId}',
        'user_id': '${_userModel.userId}'
      })
    );
    var res = convert.jsonDecode(req.body);

    if (!res['error']) {
      List data = res['data'];
      List<ChatMessageModel> temp = [];
      for (int i = 0; i < data.length; i++) {
        temp.add(ChatMessageModel(
            senderId: data[i]['sender_id'],
            senderName: data[i]['display_name'],
            message: data[i]['message'],
            senderImg: data[i]['profile_pic'],
            messageType: data[i]['message_type'],
            image: data[i]['image']
          )
        );
      }
      setState(() {
        _listMessages.addAll(temp);
        temp = null;
        _refreshController.loadComplete();
      });
    }
    else {
      //load more done
      _refreshController.loadNoData();
    }
  }

  void _onMessageChanged(String value) {
    setState(() {
      message = value;
      if (value.trim().isEmpty) {
        isCurrentUserTyping = false;
        return;
      } else {
        isCurrentUserTyping = true;
      }
    });
  }

  void startGetAndUploadPhoto() async {
    String _url = '${Constants.SERVER_URL}chatMessages/uploadImage';
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              'Are you sure to send this image?',
              style: TextStyle(fontSize: 16),
            ),
            content: Image.file(
              file,
              fit: BoxFit.cover,
              width: 120,
              height: 120,
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  startSendImageMessage(file, _url);
                  Navigator.of(context).pop();
                },
                child: Text('Send')
              )
            ],
          );
        }
      );
    }
  }

  void startSendImageMessage(var file, var _url) async {
    var stream = new http.ByteStream(file.openRead().cast());
    var length = await file.length();
    var uri = Uri.parse(_url);
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: Path.basename(file.path));
    request.files.add(multipartFile);
    request.headers.addAll({
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer ${_userModel.accessToken}"
    });
    var response = await request.send();
    response.stream.transform(convert.utf8.decoder).listen((value) async {
      try {
        var jsonResponse = await convert.jsonDecode(value);
        bool error = jsonResponse['error'];
        if (error == false) {
          String imageName = jsonResponse['data'];
          _sendMessage(type: 1, image: imageName);
        }
        else {
          print('error! ' + jsonResponse);
        }
      }
      catch (err) {
        print(err);
      }
    });
  }

  void _scrollToLast() {
    try {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    } catch (err) {}
  }

  startDeleteMessage(String messageId) {

  }


  void startSendImageMessageOrRecord(var file, int type, var _url, {isRecord = false}) async {
    var stream = new http.ByteStream(file.openRead().cast());
    var length = await file.length();
    var uri = Uri.parse(_url);
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: Path.basename(file.path));
    request.files.add(multipartFile);
    var response = await request.send();
    response.stream.transform(convert.utf8.decoder).listen((value) async {
      try {
        var jsonResponse = await convert.jsonDecode(value);
        bool error = jsonResponse['error'];
        if (error == false) {
          String imageName = jsonResponse['data'];

          _sendMessage(type: type, image: imageName);
        } else {
          print('error! ' + jsonResponse);
        }
      } catch (err) {
        print(err);
      }
    });
  }

  _initRecorder() async {
    /*await recorderModule.setDbPeakLevelUpdate(0.8);
    await recorderModule.setDbLevelEnabled(true);
    await recorderModule.setDbLevelEnabled(true);*/

    /*recorderModule.openAudioSession(
        focus: AudioFocus.requestFocusTransient,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);*/
  }


  /*_buildRecordWidget(ThemeProvider themeProvider) {
    startRequestPermissionRec();
    return Container(
      color: themeProvider.getThemeData.brightness == Brightness.dark
          ? Colors.white30
          : Colors.black12,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
              onTap: () {
                closeRecorder();
                setState(() {
                  isMicrophone = false;
                });
              },
              child: Icon(
                Icons.delete,
                size: 30,
              )),
          Consumer<DateProvider>(builder: (context, dateProvider, child) {
            return Text('${dateProvider.dateText}');
          }),
          InkWell(
              onTap: () {
                startSendRecording();
              },
              child: Icon(
                Icons.play_arrow,
                size: 35,
              )),
        ],
      ),
    );
  }*/

  void startSendRecording() async {
    try {
      String _url = '${Constants.SERVER_URL}chatMessages/uploadImage';
      File file = localFileSystem.file(path);
      await recorderModule.stopRecorder();

      startSendImageMessageOrRecord(file, 2, _url, isRecord: true);

      setState(() {
        isMicrophone = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  /*void startRequestPermissionRec() async {
    if (await Permission.microphone.isGranted &&
        await Permission.storage.isGranted) {
      _startRecord();
    }
    else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.storage,
      ].request();

      _startRecord();
    }
  }*/

  /*_startRecord() async {
    String id = Uuid().v1();
    try {
      Directory tempDir = await getTemporaryDirectory();
      path = '${tempDir.path}/$id.aac';

      path = await recorderModule.startRecorder(
          codec: Codec.aacADTS, uri: path);
      _recorderSubscription = recorderModule.onRecorderStateChanged.listen((e) {
        if (e != null && e.currentPosition != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.currentPosition.toInt(),
              isUtc: true);
          maxRecordDuration = DateFormat('mm:ss:SS', 'en_GB').format(date);
          Provider.of<DateProvider>(context, listen: false).dateText =
              maxRecordDuration.substring(0, 8);
        }
      });
    } catch (e) {
      print(e);
    }
  }*/

  void closeRecorder() async {
    try{
      await recorderModule.stopRecorder();
    }
    catch(err){

    }
  }

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }

  /*void _addListeners(messageProvider) {
    cancelPlayerSubscriptions();
    _playerSubscription = playerModule.onPlayerStateChanged.listen((e) {
      if (e != null) {
        maxDuration = e.duration;
        if (maxDuration <= 0) maxDuration = 0.0;

        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
        messageProvider.playerText = txt.substring(0, 8);
        if(e.currentPosition.toInt() == maxDuration)
        {
          messageProvider.currentIcon = 0;
        }
      }
    });
  }*/

  /*Future _loadFile(String kUrl1, messageProvider) async {
    final bytes = await http.readBytes(kUrl1);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${Uuid().v1()}.aac');
    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      if (playerModule.isPlaying) {
        await playerModule.stopPlayer();
      }
      else {
        await playerModule.startPlayer(file.path);
        _addListeners(messageProvider);
      }

    }
  }*/

  void releaseFlauto() async {
    try {
      await playerModule.stopPlayer();
    }catch(err){}
  }

  void cancelRecord() async {
    if (_recorderSubscription != null) _recorderSubscription.cancel();
  }

}
