import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    //googleUser = _googleSignIn.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: HomeAppBar(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Icon(
                      Icons.home,
                      color: Colors.grey,
                      size: 30,
                    ),
                    onTap: () {

                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Icon(
                      Icons.group,
                      color: Colors.grey,
                      size: 30,
                    ),
                    onTap: () {

                    },
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Icon(
                      Icons.notifications,
                      color: Colors.grey,
                      size: 30,
                    ),
                    onTap: () {

                    },
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(25, 20, 25, 20),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 50,
                    width: 50,
                    padding: EdgeInsets.all(0),
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(_googleUserModel.photoUrl),
                      backgroundColor: Colors.blue,
                    ),
                    //child: GoogleUserCircleAvatar(identity: googleUser),
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text(
                        "Welcome, " + _googleUserModel.userName,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    )
                  )
                ],
              ),
            ),
            Card(
              elevation: 3.0,
              color: Colors.lightBlue,
              margin: EdgeInsets.fromLTRB(25, 10, 25, 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Influence of Sun in finance",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Not a favourable period for finances, you may also incur " +
                      "losses and physical suffering.",
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(5, 30, 5, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              child: Text(
                                'Express',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 16.0
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  Constants.ExpressListPageRoute
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              child: Text(
                                'Get Inspiration',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 16.0
                                ),
                              ),
                              onTap: () {

                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                child: ActionChip(
                  elevation: 6.0,
                  padding: EdgeInsets.all(3.0),
                  avatar: CircleAvatar(
                    backgroundColor: Colors.green[60],
                    child: Icon(Icons.school),
                  ),
                  label: Text('Discover'),
                  onPressed: () {

                  },
                  backgroundColor: Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                      width: 1,
                      color: Colors.grey,
                    )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                child: ActionChip(
                  elevation: 6.0,
                  padding: EdgeInsets.all(3.0),
                  avatar: CircleAvatar(
                    backgroundColor: Colors.green[60],
                    child: Icon(Icons.school),
                  ),
                  label: Text('Education'),
                  onPressed: () {

                  },
                  backgroundColor: Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                      width: 1,
                      color: Colors.grey,
                    )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                child: ActionChip(
                  elevation: 6.0,
                  padding: EdgeInsets.all(3.0),
                  avatar: CircleAvatar(
                    backgroundColor: Colors.green[60],
                    child: Icon(Icons.school),
                  ),
                  label: Text('Entertainment'),
                  onPressed: () {

                  },
                  backgroundColor: Colors.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                      width: 1,
                      color: Colors.grey,
                    )
                  ),
                ),
              )
            ]
          )
        )
      ),
    );
  }
}