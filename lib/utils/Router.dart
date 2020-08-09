import 'package:flutter/material.dart';
import 'package:navras/pages/CaptureTalentVideo.dart';
import 'package:navras/pages/CreatePost.dart';
import 'package:navras/pages/CreateProfile.dart';
import 'package:navras/pages/ExpressList.dart';
import 'package:navras/pages/Home.dart';
import 'package:navras/pages/Location.dart';
import 'package:navras/pages/LoginPage.dart';
import 'package:navras/pages/Memory.dart';
import 'package:navras/pages/Moment.dart';
import 'package:navras/pages/MomentPreview.dart';
import 'package:navras/pages/PhotoEditor.dart';
import 'package:navras/pages/SignInWithGoogle.dart';
import 'package:navras/pages/SplashScreen.dart';
import 'package:navras/pages/TalentVideoPreview.dart';
import 'package:navras/pages/VideoEffectsPage.dart';
import 'package:navras/pages/WelcomePage.dart';
import 'package:navras/utils/Classes.dart';
import 'package:navras/utils/Constants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Constants.GoogleSignInPageRoute:
      return MaterialPageRoute(builder: (context) => SignInWithGoogle());
    case Constants.CreateProfilePageRoute:
      final UserDetails args = settings.arguments;
      return MaterialPageRoute(builder: (context) => CreateProfile(args));
    case Constants.ExpressListPageRoute:
      return MaterialPageRoute(builder: (context) => ExpressList());
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
    case Constants.MomentPreviewPageRoute:
      final PhotoEffectArgs args = settings.arguments;
      return MaterialPageRoute(builder: (context) => MomentPreview(args.imagePath,args.filter));
    case Constants.MemoryPageRoute:
      return MaterialPageRoute(builder: (context) => Memory());
    case Constants.CaptureTalentPageRoute:
      return MaterialPageRoute(builder: (context) => CameraExampleHome());
    case Constants.TalentPreviewPageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => TalentVideoPreview(argument));
    case Constants.PhotoEditorPageRoute:
      final PhotoEffectArgs args = settings.arguments;
      return MaterialPageRoute(builder: (context) => Cropper(args.imagePath,args.filter));
    case Constants.VideoEffectsPageRoute:
      var argument = settings.arguments;
      return MaterialPageRoute(builder: (context) => ControllerStreamUsagePage(argument));
    case Constants.LocationPageRoute:
      return MaterialPageRoute(builder: (context) => Location());
    default:
      return MaterialPageRoute(builder: (context) => Home());
  }
}