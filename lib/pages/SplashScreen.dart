import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:navras/models/GoogleUserModel.dart';
import 'package:navras/pages/SignInWithGoogle.dart';
import 'package:navras/utils/Classes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:navras/models/UserModel.dart';
import 'package:navras/pages/WelcomePage.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/providers/Theme_provider.dart';
import 'package:navras/utils/Constants.dart';
import 'dart:convert' as convert;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();

  @override
  void initState() {
    super.initState();
    checkTheme();
    initFilterEffects();
    /*Future.delayed(Duration(milliseconds: 2000), () async {
      _handleGoogleSignIn();
      _handleNavrasSignIn();
    });*/
  }

  _handleGoogleSignIn() async {
    bool isSignedIn = await _googleSignIn.isSignedIn();
    if(isSignedIn) {
      final GoogleSignInAccount googleUser = await _googleSignIn
        .signInSilently(suppressErrors: false)
        .catchError((e) {
          print(e.toString());
        });

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      FirebaseUser userDetails = (await _firebaseAuth.signInWithCredential(credential)).user;
      ProviderDetails providerInfo = new ProviderDetails(userDetails.providerId);

      List<ProviderDetails> providerData = new List<ProviderDetails>();
      providerData.add(providerInfo);

      GoogleUserModel googleUserModel = GoogleUserModel(
        userDetails.displayName, userDetails.email, userDetails.photoUrl
      );

      //SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        Provider.of<AuthProvider>(context, listen: false).setGoogleUserModel(googleUserModel);
      //});
    }
    else {
      //SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SignInWithGoogle()),
          (route) => false
        );
      //});
    }
  }

  _handleNavrasSignIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String email = sharedPreferences.getString('email');
    String password = sharedPreferences.getString('password');

    if (email != null && password != null) {
      startLogin(email, password);
    }
    else {

        Navigator.of(context).pushNamedAndRemoveUntil(
          Constants.LoginPageRoute, (route) => false
        );
    }
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

          Navigator.of(context).pushNamedAndRemoveUntil(
            Constants.LoginPageRoute, (route) => false
          );

      }
      else {
        var userData = jsonResponse['data'];
        UserModel myModel = UserModel.fromJson(userData);
        //make my model usable to all widgets
        Provider.of<AuthProvider>(context, listen: false).setUserModel(myModel);

        print("Login done - going to Home");


          Navigator.of(context).pushNamedAndRemoveUntil(
            Constants.WelcomePageRoute, (route) => false
          );

      }
    }
    catch (err) {
      //case error (No internet connection) move to WelcomePage

        Navigator.of(context).pushNamedAndRemoveUntil(
          Constants.LoginPageRoute,
          (Route<dynamic> route) => false
        );

    }
  }

  @override
  Widget build(BuildContext context) {
    _handleGoogleSignIn();
    _handleNavrasSignIn();
    return Scaffold(
      backgroundColor: Color(0xff181818),
      body: SafeArea(
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(),
                Container(),
                Container(),
                Container(
                  padding: EdgeInsets.all(70),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/logo.jpeg',
                    //height: 200,
                    //width: 200,
                    //fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                /*Text(
                  '',
                  style: GoogleFonts.roboto(
                    fontSize: 20, fontWeight: FontWeight.w600
                  ),
                ),*/
                Container(
                  padding: EdgeInsets.all(15),
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    backgroundColor: Colors.green,
                  )
                )
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
