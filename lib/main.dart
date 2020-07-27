import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navras/providers/CategoryProvider.dart';
import 'package:navras/providers/GroupProvider.dart';
import 'package:navras/providers/ShaderMaskProvider.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:navras/pages/SplashScreen.dart';
import 'package:navras/utils/Router.dart' as router;
import 'package:navras/providers/AppBarProvider.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/providers/ConverstionProvider.dart';
import 'package:navras/providers/DateProvider.dart';
import 'package:navras/providers/NotificationProvider.dart';
import 'package:navras/providers/PostProvider.dart';
import 'package:navras/providers/Theme_provider.dart';
import 'package:navras/utils/Constants.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  //set up providers
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  Admob.initialize(getAppId());
  runApp(OverlaySupport(
    child: MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(isLightTheme: true)
      ),
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => DateProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => AppBarProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => NotificationProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => PostProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => ConversionProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => GroupProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => CategoryProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => ShaderMaskProvider(),
      )
    ], child: MyApp()),
  ));
}
String getAppId() {
  if (Platform.isIOS) {
    return Constants.ADMOB_APP_ID_IOS;
  } else if (Platform.isAndroid) {
    return Constants.ADMOB_APP_ID_ANDROID;
  }
  return null;
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //set up theme provider with listen true to rebuild app when theme change
    //by default listen is true
    final themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: themeProvider.getThemeData.backgroundColor,
      statusBarIconBrightness:
      themeProvider.getThemeData.brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark
      )
    );
    return MaterialApp(
      theme: themeProvider.getThemeData,
      home: SplashScreen(),
      title: 'v chat app',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.generateRoute,
      initialRoute: Constants.SplashScreenRoute
    );
  }
}
