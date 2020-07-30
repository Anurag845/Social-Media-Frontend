import 'package:flutter/material.dart';
import 'package:navras/customAppBars/HomeAppBar.dart';
import 'package:navras/models/GoogleUserModel.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/utils/Constants.dart';
import 'package:provider/provider.dart';
import 'package:navras/providers/Theme_provider.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  GoogleUserModel _googleUserModel;

  @override
  void initState() {
    super.initState();
    _googleUserModel = Provider.of<AuthProvider>(context, listen: false).googleUserModel;
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: HomeAppBar(),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              InkWell(
                child: Icon(
                  Icons.home,
                  color: Colors.grey,
                  size: 26,
                ),
                onTap: () {

                },
              ),
              InkWell(
                child: Icon(
                  Icons.group,
                  color: Colors.grey,
                  size: 26,
                ),
                onTap: () {

                },
              ),
              Spacer(),
              InkWell(
                child: Icon(
                  Icons.notifications,
                  color: Colors.grey,
                  size: 26,
                ),
                onTap: () {

                },
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 94),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(_googleUserModel.photoUrl),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          )
        ],
      )
    );
  }
}