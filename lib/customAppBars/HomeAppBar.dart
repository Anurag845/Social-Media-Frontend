import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:provider/provider.dart';
import 'package:navras/providers/AppBarProvider.dart';
import 'package:navras/providers/Theme_provider.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  _HomeAppBarState createState() => _HomeAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _HomeAppBarState extends State<HomeAppBar> {
  final double minValue = 8.0;
  final double iconSize = 25.0;
  int index = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    index = Provider.of<AppBarProvider>(context, listen: true).getIndex();
    final themeProvider = Provider.of<ThemeProvider>(context);

//    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//      statusBarColor: themeProvider.getThemeData.backgroundColor,
//      //top bar color
//      statusBarIconBrightness:
//          themeProvider.getThemeData.brightness == Brightness.dark
//              ? Brightness.light
//              : Brightness.dark, //top bar icons
//    ));

    return SafeArea(
      child: Container(
        color: themeProvider.getThemeData.primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(5),
                child: Icon(
                  Icons.android,
                  size: 30,
                ),
              )
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.all(5),
                child: Icon(
                  Icons.search,
                  size: 30,
                ),
              )
            )
                  /*Expanded(
                    flex: 1,
                    child: InkWell(
                        onTap: () {
                          Provider.of<AppBarProvider>(context, listen: false)
                              .setIndex(0);
                        },
                        child: Icon(
                          LineAwesomeIcons.home,
                          color: index == 0
                              ? Colors.blue[600]
                              : themeProvider
                                  .getThemeData.accentIconTheme.color,
                          size: iconSize,
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                        onTap: () {
                          Provider.of<AppBarProvider>(context, listen: false)
                              .setIndex(2);
                        },
                        child: Icon(
                          LineAwesomeIcons.comments,
                          color: index == 2
                              ? Colors.blue[600]
                              : themeProvider
                                  .getThemeData.accentIconTheme.color,
                          size: iconSize,
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                        onTap: () {
                          Provider.of<AppBarProvider>(context, listen: false)
                              .setIndex(3);
                        },
                        child: Icon(
                          FontAwesomeIcons.facebookMessenger,
                          color: index == 3
                              ? Colors.blue[600]
                              : themeProvider
                                  .getThemeData.accentIconTheme.color,
                          size: 21,
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                        onTap: () {
                          Provider.of<AppBarProvider>(context, listen: false)
                              .setIndex(1);
                        },
                        child: Icon(
                          LineAwesomeIcons.bell,
                          color: index == 1
                              ? Colors.blue[600]
                              : themeProvider
                                  .getThemeData.accentIconTheme.color,
                          size: iconSize + 1,
                        )),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                        onTap: () {
                          Provider.of<AppBarProvider>(context, listen: false)
                              .setIndex(4);
                        },
                        child: Icon(
                          LineAwesomeIcons.cog,
                          color: index == 4
                              ? Colors.blue[600]
                              : themeProvider
                                  .getThemeData.accentIconTheme.color,
                          size: 26,
                        )),
                  ),*/
                ],
              ),
            ),

      );
  }
}
