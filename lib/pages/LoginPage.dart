import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:navras/models/GoogleUserModel.dart';
import 'package:navras/utils/Classes.dart';
import 'package:provider/provider.dart';
import 'package:navras/models/UserModel.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/utils/Constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:navras/widgets/bezierContainer.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int currentLoading = 0;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var url = '${Constants.SERVER_URL}user/login';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googlSignIn = new GoogleSignIn();

  _signIn() async {
    final GoogleSignInAccount googleUser = await _googlSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    FirebaseUser userDetails = (await _firebaseAuth.signInWithCredential(credential)).user;
    ProviderDetails providerInfo = new ProviderDetails(userDetails.providerId);

    List<ProviderDetails> providerData = new List<ProviderDetails>();
    providerData.add(providerInfo);

    GoogleUserModel googleUserModel = GoogleUserModel(
      userDetails.displayName,
      userDetails.email,
      userDetails.photoUrl
    );

    Provider.of<AuthProvider>(context, listen: false).setGoogleUserModel(googleUserModel);
  }

  void startLogin(String email, String password) async {
    try {
      var response = await http.post(
        url,
        body: {'email': email.toLowerCase(), 'password': password},
      );
      var jsonResponse = await convert.jsonDecode(response.body);
      bool error = jsonResponse['error'];
      if(error) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('${jsonResponse['data']}'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('close')
                )
              ],
            );
          }
        );
      }
      else {
        var userData = jsonResponse['data'];
        UserModel myModel = UserModel.fromJson(userData);
        //make my model usable to all widgets
        Provider.of<AuthProvider>(context, listen: false).setUserModel(myModel);

        saveData(myModel.userId, myModel.username, myModel.email, passwordController.text);
        await _signIn();
        Navigator.of(context).pushNamed(Constants.HomePageRoute);
      }
    }
    catch (err) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('check your internet connection'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('close')
                )
              ],
            );
          });
    }
    finally {
      setState(() {
        currentLoading = 0;
      });
    }
  }

  void saveData(String userId, String username, String email, password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('user_id', userId);
    sharedPreferences.setString('username', username);
    sharedPreferences.setString('email', email);
    sharedPreferences.setString('password', password);
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }


  Widget _entryField(String title, controller, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(border: InputBorder.none, filled: true)
          )
        ],
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        setState(() {
          currentLoading = 1;
        });
        startLogin(emailController.text.trim(), passwordController.text);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)])),
        child: Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _createAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Don\'t have an account ?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              /*Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignUpPage()));*/
            },
            child: Text(
              'Register',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'V',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xffe46b10),
          ),
          children: [
            TextSpan(
              text: ' Chat',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: ' App',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Email id", emailController),
        _entryField("Password", passwordController, isPassword: true),
      ],
    );
  }

  Widget progress = Container(
    padding: EdgeInsets.symmetric(vertical: 15),
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      backgroundColor: Colors.green,
      strokeWidth: 7,
    ),
  );


  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: SizedBox(),
                ),
                _title(),
                SizedBox(
                  height: 50,
                ),
                _emailPasswordWidget(),
                SizedBox(
                  height: 20,
                ),
                currentLoading == 0 ? _submitButton() : progress,

                SizedBox(
                  height: 45,
                ),
                //_facebookButton(),
                Expanded(
                  flex: 2,
                  child: SizedBox(),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _createAccountLabel(),
          ),
          Positioned(top: 40, left: 0, child: _backButton()),
          Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer())
        ],
      ),
    )));
  }
}
