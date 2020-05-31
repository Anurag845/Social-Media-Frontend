//created by Hatem Ragap
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lockdown_diaries/models/ConversionModel.dart';
import 'package:lockdown_diaries/utils/Constants.dart';

// ignore: must_be_immutable
class ChatItem extends StatelessWidget {
  ConversionModel _chatRoomModel;
  String myId;

  ChatItem(this._chatRoomModel, this.myId);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            width: MediaQuery.of(context).size.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //user image
                Container(
                    width: 51,
                    height: 51,
                    margin: EdgeInsets.only(left: 5),
                    child: Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: CachedNetworkImage(
                            imageUrl: Constants.USERS_PROFILES_URL +
                                _chatRoomModel.userImg,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          ),
                        ),
                        _chatRoomModel.isOnline == false
                            ? Container()
                            : Positioned(
                                bottom: 0,
                                right: 0,
                                child: Icon(
                                  Icons.brightness_1,
                                  color: Colors.green,
                                  size: 16,
                                ))
                      ],
                    )),
                SizedBox(
                  width: 5,
                ),
                //user Name And last message
                Container(
                  height: 51,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _chatRoomModel.userName,
                        style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w500, fontSize: 14.5),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2 + 20,
                        child: Text(
                          _chatRoomModel.lastMessage,
                          style: _chatRoomModel.isLastMessageSeen
                              ? GoogleFonts.roboto(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500)
                              : GoogleFonts.roboto(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
        Divider(
          thickness: 1,
        )
      ],
    );
  }
}
