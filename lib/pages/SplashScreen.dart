//created by Hatem Ragap
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lockdown_diaries/utils/Classes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lockdown_diaries/models/UserModel.dart';
import 'package:lockdown_diaries/pages/WelcomePage.dart';
import 'package:lockdown_diaries/providers/AuthProvider.dart';
import 'package:lockdown_diaries/providers/Theme_provider.dart';
import 'package:lockdown_diaries/utils/Constants.dart';
import 'dart:convert' as convert;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkTheme();
    initFilterEffects();
    new Future.delayed(const Duration(milliseconds: 2500), () async {
      //check if email is save to start login if not Navigate to WelcomePage
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String email = sharedPreferences.getString('email');
      String password = sharedPreferences.getString('password');

      //print("Splashscreen:- email " + email + " password " + password);

      if (email != null && password != null) {
        startLogin(email, password);
      }
      else {
        Navigator.of(context).pushNamedAndRemoveUntil(Constants.WelcomePageRoute, (route) => false);
        /*Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => WelcomePage()),
            (Route<dynamic> route) => false);*/
      }
    });
  }

  void startLogin(String email, String password) async {
    // check email and password if succ Move to Home if Not Move to WelcomePage
    var url = '${Constants.SERVER_URL}user/login';

    try {
      var response = await http.post(
        url,
        body: {'email': email, 'password': password},
      );
      var jsonResponse = await convert.jsonDecode(response.body);
      bool error = jsonResponse['error'];

      if (error) {
        Navigator.of(context).pushNamedAndRemoveUntil(Constants.WelcomePageRoute, (route) => false);
        /*Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => WelcomePage()),
            (Route<dynamic> route) => false);*/
      }
      else {
        var userData = jsonResponse['data'];
        UserModel myModel = UserModel.fromJson(userData);
        //make my model usable to all widgets
        Provider.of<AuthProvider>(context, listen: false).userModel = myModel;

        print("Login done - going to Home");
        Navigator.of(context).pushNamedAndRemoveUntil(Constants.HomePageRoute, (route) => false);

        /*Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => Home()),
            (Route<dynamic> route) => false);*/
      }
    }
    catch (err) {
      //case error (No internet connection) move to WelcomePage
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => WelcomePage()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    //splash screen deign
    return Scaffold(
      backgroundColor: Color(0xff181818),
      body: SafeArea(
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2
                )
              ],
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xfffbb448), Color(0xffe46b10)]
              )
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(),
                Container(),
                Container(),
                Container(
                  child: Image.asset(
                    'assets/images/logo2.png',
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'please wait while check login',
                  style: GoogleFonts.roboto(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Container(
                    padding: EdgeInsets.all(15),
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      backgroundColor: Colors.green,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void checkTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool val = preferences.getBool('theme') ?? true;
    Provider.of<ThemeProvider>(context, listen: false).setThemeData = val;
  }

  void initFilterEffects() {
    Constants.filters.add(
      Filter("f1","Original",Colors.transparent,Colors.transparent)
    );
    Constants.filters.add(
      Filter("f2","Vintage",Colors.white,Colors.black)
    );
    Constants.filters.add(
      Filter("f3","Red",Colors.red,Colors.red)
    );
    Constants.filters.add(
      Filter("f4","Green",Colors.green,Colors.green)
    );
    Constants.filters.add(
      Filter("f5","Yellow",Colors.yellow,Colors.yellow)
    );
    Constants.filters.add(
      Filter("f6","Blue",Colors.blue,Colors.blue)
    );
    Constants.filters.add(
      Filter("f7","Brown",Colors.brown,Colors.brown)
    );
    Constants.filters.add(
      Filter("f8","Grey",Colors.blueGrey,Colors.grey)
    );
    Constants.filters.add(
      Filter("f9","Pink",Colors.pink,Colors.pink)
    );
    print("Length of filters in init is " + Constants.filters.length.toString());
  }
}
