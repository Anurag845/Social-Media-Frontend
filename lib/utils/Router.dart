import 'package:flutter/material.dart';
import 'package:lockdown_diaries/pages/CaptureTalentVideo.dart';
import 'package:lockdown_diaries/pages/CreatePost.dart';
import 'package:lockdown_diaries/pages/Home.dart';
import 'package:lockdown_diaries/pages/Location.dart';
import 'package:lockdown_diaries/pages/LoginPage.dart';
import 'package:lockdown_diaries/pages/Memory.dart';
import 'package:lockdown_diaries/pages/Moment.dart';
import 'package:lockdown_diaries/pages/PhotoEditor.dart';
import 'package:lockdown_diaries/pages/SplashScreen.dart';
import 'package:lockdown_diaries/pages/TalentVideoPreview.dart';
import 'package:lockdown_diaries/pages/VideoEffectsPage.dart';
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
    case Constants.MomentPageRoute:
      return MaterialPageRoute(builder: (context) => Moment());
    case Constants.MemoryPageRoute:
      return MaterialPageRoute(builder: (context) => Memory());
    case Constants.CaptureTalentPageRoute:
      return MaterialPageRoute(builder: (context) => CameraExampleHome());
    case Constants.TalentPreviewPageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => TalentVideoPreview(argument));
    case Constants.PhotoEditorPageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => Cropper(argument));
    case Constants.VideoEffectsPageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => ControllerStreamUsagePage(argument));
    case Constants.LocationPageRoute:
      return MaterialPageRoute(builder: (context) => Location());
    default:
      return MaterialPageRoute(builder: (context) => Home());
  }
}