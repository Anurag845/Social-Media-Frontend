import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:navras/models/GoogleUserModel.dart';
import 'package:navras/pages/CreateProfile.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/utils/Classes.dart';
import 'package:navras/utils/Constants.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class SignInWithGoogle extends StatefulWidget {
  @override
  _SignInWithGoogleState createState() => _SignInWithGoogleState();
}

class _SignInWithGoogleState extends State<SignInWithGoogle> {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  GoogleSignInAccount _googleUser;
  UserDetails _userDetails;

  _signIn() async {
    _googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await _googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    FirebaseUser userDetails = (await _firebaseAuth.signInWithCredential(credential)).user;
    ProviderDetails providerInfo = new ProviderDetails(userDetails.providerId);

    List<ProviderDetails> providerData = new List<ProviderDetails>();
    providerData.add(providerInfo);

    _userDetails = UserDetails(userDetails.photoUrl,userDetails.email,userDetails.displayName);
  }

  _checkIfExists(String email) async {
    var response = await http.post(
      "${Constants.SERVER_URL}user/checkIfExists",
      body: {'email': email}
    );
    var jsonResponse = convert.jsonDecode(response.body);
    bool error = jsonResponse['error'];
    if(!error) {
      bool exists = jsonResponse['exists'];
      print(exists);
      if(exists) {
        Navigator.of(context).pushReplacementNamed(
          Constants.LoginPageRoute
        );
      }
      else {
        Navigator.of(context).pushReplacementNamed(
          Constants.CreateProfilePageRoute, arguments: _userDetails
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 40,
          child: SignInButton(
            Buttons.Google,
            text: "Sign in with Google",
            onPressed: () async {
              await _signIn();

              await _checkIfExists(_googleUser.email);
            }
          ),
        )
      ),
    );
  }
}