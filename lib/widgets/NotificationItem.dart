import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:navras/models/NotificationModel.dart';
import 'package:navras/models/PostModel.dart';
import 'package:navras/pages/CommentsPage.dart';
import 'package:navras/utils/Constants.dart';
import 'package:timeago/timeago.dart' as timeAgo;

// ignore: must_be_immutable
class NotificationItem extends StatefulWidget {
  NotificationModel _notificationModel;

  NotificationItem(this._notificationModel);

  @override
  _NotificationItemState createState() =>
      _NotificationItemState(_notificationModel);
}

class _NotificationItemState extends State<NotificationItem> {
  NotificationModel _notificationModel;
  var date;

  _NotificationItemState(this._notificationModel);

  @override
  void initState() {
    date = new DateTime.fromMillisecondsSinceEpoch(
        widget._notificationModel.timeStamp*1000);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CommentsPage(PostModel(
                    postId: _notificationModel.postId,
                    postOwnerId: _notificationModel.peerId
                  ),
                  false
                )
              )
            );
          },
          title: Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  '${_notificationModel.name} ',
                  maxLines: 1,
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400),
                ),
              ),
              Text(
                '${_notificationModel.title}',
                style: GoogleFonts.roboto(fontWeight: FontWeight.w300),
              ),
            ],
          ),
          leading: CachedNetworkImage(
            imageUrl: Constants.USERS_PROFILES_URL + _notificationModel.userImg,
            width: 60,
            height: 80,
            fit: BoxFit.cover,
          ),
          subtitle: Container(
            padding: EdgeInsets.only(top: 25),
            child: Row(
              children: <Widget>[
                Icon(
                  _notificationModel.title == 'Liked your post'
                      ? LineIcons.thumbs_up
                      : LineIcons.comment,
                  size: 16,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  '${timeAgo.format(date)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        Divider(
          color: Colors.grey,
        )
      ],
    );
  }
}
