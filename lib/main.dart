import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:YouAudio/playPage.dart';
import 'package:YouAudio/searchPage.dart';
import 'package:YouAudio/subscritonsPage.dart';
import 'package:YouAudio/theme.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:http/http.dart" as http;

void main() {
  runApp(new MaterialApp(
    title: 'YouAudio',
    debugShowCheckedModeBanner: false,
    home: new MyTabs(),
    routes: <String, WidgetBuilder>{
      '/search': (BuildContext context) => new SearchList(),
    },
  ));
}

class MyTabs extends StatefulWidget {
  @override
  MyTabsState createState() => new MyTabsState();
}

class MyTabsState extends State<MyTabs> with SingleTickerProviderStateMixin {
  TabController controller;
  GoogleSignInAccount _currentUser;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/youtube.readonly',
    ],
  );

  @override
  void initState() {
    super.initState();
    _googleSignIn.signInSilently().then((GoogleSignInAccount account) {
      if(account == null) {
        _handleSignIn();
      }
    });
    controller = new TabController(vsync: this, length: 3);
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print("Something went wrong: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: accentColor,
          leading: new IconButton(
              icon: new Icon(Icons.search),
              color: const Color(0xFFDDDDDD),
              onPressed: () => Navigator.of(context).pushNamed('/search')),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(
                Icons.menu,
              ),
              color: const Color(0xFFDDDDDD),
              onPressed: () {},
            ),
          ],
          bottom: new TabBar(controller: controller, tabs: <Tab>[
            new Tab(text: 'Play'),
            new Tab(text: 'Subscriptions'),
          ]),
        ),
        body: new TabBarView(
            controller: controller,
            children: <Widget>[new Play(), new SubscriptionsPage()]));
  }
}
