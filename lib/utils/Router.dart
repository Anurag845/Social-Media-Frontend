import 'package:flutter/material.dart';
import 'package:lockdown_diaries/pages/CreatePost.dart';
import 'package:lockdown_diaries/pages/Home.dart';
import 'package:lockdown_diaries/pages/LoginPage.dart';
import 'package:lockdown_diaries/pages/Photo.dart';
import 'package:lockdown_diaries/pages/PhotoEditor.dart';
import 'package:lockdown_diaries/pages/SplashScreen.dart';
import 'package:lockdown_diaries/pages/WelcomePage.dart';
import 'package:lockdown_diaries/utils/Constants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Constants.HomePageRoute:
      return MaterialPageRoute(builder: (context) => Home());
    case Constants.SplashScreenRoute:
      return MaterialPageRoute(builder: (context) => SplashScreen());
    case Constants.WelcomePageRoute:
      return MaterialPageRoute(builder: (context) => WelcomePage());
    case Constants.LoginPageRoute:
      return MaterialPageRoute(builder: (context) => LoginPage());
    case Constants.CreatePostPageRoute:
      return MaterialPageRoute(builder: (context) => CreatePost());
    case Constants.PhotoPageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => Photo(argument));
    case Constants.PhotoEditorPageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => Cropper(argument));
    default:
      return MaterialPageRoute(builder: (context) => Home());
  }
}