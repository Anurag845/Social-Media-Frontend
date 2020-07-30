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

class SignInWithGoogle extends StatefulWidget {
  @override
  _SignInWithGoogleState createState() => _SignInWithGoogleState();
}

class _SignInWithGoogleState extends State<SignInWithGoogle> {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googlSignIn = new GoogleSignIn();

  _signIn() async {
    final GoogleSignInAccount googleUser = await _googlSignIn.signIn();
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
      userDetails.displayName,
      userDetails.email,
      userDetails.photoUrl
    );

    Provider.of<AuthProvider>(context, listen: false).setGoogleUserModel(googleUserModel);
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

              //check if email exists in the db and if it does not ->

              /*Navigator.of(context).pushReplacementNamed(
                Constants.CreateProfilePageRoute
              );*/

              //if email exists in db move to login screen

              Navigator.of(context).pushReplacementNamed(
                Constants.LoginPageRoute
              );

            }
          ),
        )
      ),
    );
  }
}