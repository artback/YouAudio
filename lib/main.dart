import 'package:YouAudio/YoutubeToAudio.dart';
import 'package:flutter/material.dart';
import 'package:YouAudio/playPage.dart';
import 'package:YouAudio/searchPage.dart';
import 'package:YouAudio/subscritonsPage.dart';
import 'package:YouAudio/theme.dart';
import 'package:flutter/services.dart';
import 'package:simple_permissions/simple_permissions.dart';

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
  static const platform = const MethodChannel('app.channel.shared.data');
  TabController controller;
  Downloader downloader;

  @override
  void initState() {
    super.initState();
    getSharedText();
    controller = new TabController(vsync: this, length: 3);
    downloader = new Downloader();
  }

  getSharedText() async {
    getPermission(status) {
      if (!status)
        SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    }

    var sharedData = await platform.invokeMethod("getSharedText");
    if (sharedData != null) {
      SimplePermissions.checkPermission(Permission.WriteExternalStorage)
          .then((status) => getPermission(status))
          .whenComplete(
              () => downloader.getAndDownloadYoutubeAudio(sharedData));
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
