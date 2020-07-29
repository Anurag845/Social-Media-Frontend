import 'package:flutter/material.dart';
import 'package:navras/customAppBars/HomeAppBar.dart';

class ExpressList extends StatefulWidget {
  @override
  _ExpressListState createState() => _ExpressListState();
}

class _ExpressListState extends State<ExpressList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: ListView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(10),
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
            padding: EdgeInsets.all(10),
            child: Text(
              "Express Yourself",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)
            ),
            margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              leading: Icon(
                Icons.videocam,
                color: Colors.red,
                size: 40,
              ),
              title: Text("Record a video"),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)
            ),
            margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              leading: Icon(
                Icons.photo_library,
                color: Colors.blue,
                size: 40,
              ),
              title: Text("Create a photo story"),
            ),
          ),
          Card(
            color: Colors.white,
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)
            ),
            margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
            child: ListTile(
              contentPadding: EdgeInsets.all(10),
              leading: Icon(
                Icons.edit,
                color: Colors.black,
                size: 40,
              ),
              title: Text("Say something"),
            ),
          )
        ],
      )
    );
  }
}