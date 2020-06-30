import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lockdown_diaries/providers/CategoryProvider.dart';
import 'package:lockdown_diaries/providers/GroupProvider.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:lockdown_diaries/pages/SplashScreen.dart';
import 'package:lockdown_diaries/utils/Router.dart' as router;
import 'package:lockdown_diaries/providers/AppBarProvider.dart';
import 'package:lockdown_diaries/providers/AuthProvider.dart';
import 'package:lockdown_diaries/providers/ConverstionProvider.dart';
import 'package:lockdown_diaries/providers/DateProvider.dart';
import 'package:lockdown_diaries/providers/NotificationProvider.dart';
import 'package:lockdown_diaries/providers/PostProvider.dart';
import 'package:lockdown_diaries/providers/Theme_provider.dart';
import 'package:lockdown_diaries/utils/Constants.dart';

void main() {
  //set up providers
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize(getAppId());
  runApp(OverlaySupport(
    child: MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider(isLightTheme: true)),
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
