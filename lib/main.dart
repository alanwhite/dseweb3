import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:js' as js;

import 'screens/home_screen.dart';
import 'providers/login.dart';
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = false;
  // print('in main');
  var uri = Uri.tryParse(js.context['location']['href']);
  // print(uri);
  var _login = Login(uri);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => _login),
  ], child: DSEWebApp()));
}

class DSEWebApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // print('in DSEWebApp');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.white,
          accentColor: Colors.white,
          // secondaryHeaderColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // accentColor: colors.white,
          textTheme: TextTheme(button: TextStyle(fontWeight: FontWeight.w400)),
          buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.accent,
              padding: EdgeInsets.all(20.0),
              minWidth: 100,
              colorScheme: Theme.of(context)
                  .colorScheme
                  .copyWith(secondary: Colors.white),
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Colors.white,
                      width: 1.0,
                      style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(5.0)))),
      routes: {
        '/': (context) => HomeScreen(),
        '/downloads': (context) => HomeScreen(),
        '/info': (context) => HomeScreen(),
        '/licenses': (context) => HomeScreen(),
      },
    );
  }
}
