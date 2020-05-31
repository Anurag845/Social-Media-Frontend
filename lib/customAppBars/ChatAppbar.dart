//created by Hatem Ragap
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lockdown_diaries/pages/PeerProfile.dart';
import 'package:lockdown_diaries/providers/Theme_provider.dart';
import 'package:lockdown_diaries/utils/Constants.dart';

// ignore: must_be_immutable
class ChatAppbar extends StatefulWidget implements PreferredSizeWidget {
  String peerImg;
  String peerName;
  String peerId;
  bool isOnline;
  String chatType;

  ChatAppbar(this.peerId, this.peerImg, this.isOnline, this.peerName, this.chatType);

  @override
  _ChatAppbarState createState() => _ChatAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _ChatAppbarState extends State<ChatAppbar> {
  final double minValue = 8.0;
  final double iconSize = 25.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: <Widget>[
          InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                size: 27,
              )),
          SizedBox(
            width: 15,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PeerProfile(widget.peerId)
                )
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: CachedNetworkImage(
                imageUrl: widget.chatType == 'PC'
                ? Constants.USERS_PROFILES_URL + widget.peerImg
                : Constants.PUBLIC_ROOMS_IMAGES + widget.peerImg,
                fit: BoxFit.cover,
                width: 40,
                height: 40,
              ),
            ),
          ),
          SizedBox(
            width: 6,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PeerProfile(widget.peerId)));
            },
            child: Container(
              height: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    '${widget.peerName}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  Text(widget.isOnline ? 'online' : '',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          )
        ],
      ),

      // backgroundColor: themeProvider.getThemeData.backgroundColor,
      elevation: 1,
    );
  }
}
