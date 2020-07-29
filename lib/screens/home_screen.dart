import 'dart:html';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/login.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/balmoral_tilt.jpg"),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: FractionalOffset.topLeft,
                end: FractionalOffset.bottomRight,
                colors: [
              Color(0x0888ff).withOpacity(0.9),
              Color(0x030aff).withOpacity(0.9),
            ],
                stops: [
              0.0,
              1.0
            ])),
      ),
      LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            print('small');
            return HomeSmall();
          } else {
            print('big');
            return HomeLarge();
          }
        },
      ),
    ]);
  }
}

class HomeLarge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 36, bottom: 36),
      child: Row(
        children: [
          Expanded(flex: 1, child: Container()),
          Expanded(
              flex: 8,
              child: Column(
                children: [
                  Expanded(flex: 3, child: Container()),
                  Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                              fit: FlexFit.tight,
                              child: Container(
                                margin: EdgeInsets.only(top: 15, right: 25),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Drum Score Editor',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Helvetica Neue',
                                          fontSize: 36,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.w300,
                                          height: 2,
                                          letterSpacing: -0.25),
                                    ),
                                    Text(
                                      'Drum Score Editor is free software for drum scores in the pipe band world. Runs on macOS, Windows and Linux - happy scoring!',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Helvetica Neue',
                                          fontSize: 16,
                                          decoration: TextDecoration.none,
                                          fontWeight: FontWeight.w200,
                                          height: 1.75),
                                    ),
                                  ],
                                ),
                              )),
                          Image.asset('assets/logo.png',
                              width: 300, height: 300, fit: BoxFit.cover),
                        ],
                      )),
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.topCenter,
                      margin: EdgeInsets.only(top: 25),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AuthButton(),
                            FlatButton(
                                onPressed: () {}, child: Text('Download')),
                            FlatButton(
                                onPressed: () {}, child: Text('More Info')),
                            FlatButton(
                                onPressed: () {}, child: Text('Licensing')),
                          ]),
                    ),
                  ),
                ],
              )),
          Expanded(flex: 1, child: Container()),
        ],
      ),
    );
  }
}

class HomeSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthButton();
  }
}

class AuthButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Login>(builder: (context, login, child) {
      return FlatButton(
          onPressed: () {
            print('button pressed');
            if (login.isLoggedIn) {
              login.logout();
            } else {
              login.authenticate();
            }
          },
          child: Text(
            login.isLoggedIn ? 'Sign Out' : 'Sign In',
          ));
    });
  }
}
