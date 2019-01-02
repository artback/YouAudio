import 'package:YouAudio/YoutubeToAudio.dart';
import 'package:YouAudio/settingsPage.dart';

import 'package:flutter/material.dart';
import 'package:YouAudio/playPage.dart';
import 'package:YouAudio/searchPage.dart';
import 'package:YouAudio/subscritonsPage.dart';
import 'package:YouAudio/theme.dart';
import 'package:flutter/services.dart';
import 'package:youtube_extractor/youtube_extractor.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

var extractor = YouTubeExtractor();

void main() {
  runApp(new MaterialApp(
    title: 'YouAudio',
    debugShowCheckedModeBanner: false,
    home: new MyTabs(),
    routes: <String, WidgetBuilder>{
      '/search': (BuildContext context) => new SearchList(),
      '/play': (BuildContext context) => new Play(),
      '/main': (BuildContext context) => new MyTabs(),
      '/settings': (BuildContext context) => new Settings(),
    },
  ));
}

class MyTabs extends StatefulWidget { // ignore: must_be_immutable
  int index;
  MyTabs([this.index]);
  @override
  MyTabsState createState() => new MyTabsState();
}

class MyTabsState extends State<MyTabs> with TickerProviderStateMixin {
  static const platform = const MethodChannel('app.channel.shared.data');
  TabController controller;
  Downloader downloader;
  Play play;
  Future<GoogleSignInAuthentication> googleSignInAuth;


  getSharedText() async {
    String sharedData = await platform.invokeMethod("getSharedText");
    if(sharedData != null) {
      downloader.getAndDownloadYoutubeAudio(sharedData);
    }
  }

  GoogleSignInAccount currentUser;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/youtube.readonly',
      'https://www.googleapis.com/auth/youtube',
      'email',
    ],
  );

  @override
  void initState() {
    super.initState();
    getSharedText();
    controller = new TabController(vsync: this, length: 3);
    downloader = new Downloader();
    _googleSignIn.signInSilently().then((GoogleSignInAccount account) {
      if (account == null) {
        _handleSignIn();
      }
      setState(() {
        currentUser = account;
        googleSignInAuth = currentUser.authentication;
        print("------------");
        print(currentUser);
        getsubs(googleSignInAuth);
      });
    }).catchError((e) => print(e));
    controller = new TabController(vsync: this, length: 3);
    play = new Play(widget.index);
    widget.index = null;

    //subscribers = getData(subApi);
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
                icon: new Icon(Icons.menu),
                color: const Color(0xFFDDDDDD),
                onPressed: () => Navigator.of(context).pushNamed('/settings')),
          ],
          bottom: new TabBar(controller: controller, tabs: <Tab>[
            new Tab(text: 'Play'),
            new Tab(text: 'Subscriptions'),
          ]),
        ),
        body: new TabBarView(
            controller: controller,
            children: <Widget>[play, new SubscriptionsPage()]
        ));
  }
}


void getData(String url) async {

  print(url);
  var response = await http
      .get(Uri.encodeFull(url), headers: {
        "Accept": "application/json",
      });

  if (response.statusCode == 200) {
    print(".........................");
    print(response.body);
    print(".........................");
  } else {
    print("cccccccccccccccccccccccccccccccc");
    throw Exception('Failed to load post');
  }

}

void getsubs(Future<GoogleSignInAuthentication> test) async {
  GoogleSignInAuthentication user = await test;

  //print(user.accessToken);

  String me = 'https://www.googleapis.com/youtube/v3/subscriptions?part=snippet%2CcontentDetails&mine=true&key=${user.accessToken}';

  //feth attempt doesnt work
  //getData(me, user.accessToken);
}