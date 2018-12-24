import 'dart:io';

import 'package:YouAudio/FilesSingleton.dart';
import 'package:YouAudio/YoutubeToAudio.dart';
import 'package:YouAudio/theme.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:YouAudio/main.dart';

var apiKey = "AIzaSyBKdwbjbsGdHyNPS0q3J6cffOsUSfiqCx4";

class SearchList extends StatefulWidget {
  SearchList({Key key}) : super(key: key);

  @override
  _SearchListState createState() => new _SearchListState();

}

class _SearchListState extends State<SearchList>
    with SingleTickerProviderStateMixin {
  List<FileSystemEntity> files = new FilesSingleton().files;
  Widget appBarTitle = new Text(
    "",
    style: new TextStyle(color: Colors.white),
  );
  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = new TextEditingController();

  bool _value = false;
  String _searchText = "";
  TabController controller;
  Future<List> foundVideos;
  Future<List> foundChannels;
  Downloader downloader;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 3);
    init();
    foundVideos = search(_searchText, "video");
    foundChannels = search(_searchText, "channel");
    downloader = new Downloader();
  }

  _SearchListState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        setState(() {
          _searchText = _searchQuery.text;
          foundVideos = search(_searchText, "video");
          foundChannels = search(_searchText, "channel");
        });
      }
    });
  }

  void init() {
    file();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: key,
        appBar: buildBar(context),
        body: new TabBarView(controller: controller, children: <Widget>[
          buildListView(),
          buildVideoList(), //View for searching youtube videos
          buildChannelList()
        ]));
  }

  //builds view that present youtube videos
  Container buildVideoList() {
    return new Container(
        child: FutureBuilder<List>(
            future: foundVideos,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List content = snapshot.data;
                return new Container(
                    child: new ListView.builder(
                        itemCount: content.length,
                        itemExtent: 80.0,
                        itemBuilder: (BuildContext context, int index) {
                          //some titles were extremely long so i made a quick fix
                          if (content[index].title.length > 36) {
                            content[index].title =
                                content[index].title.substring(0, 36) + "...";
                          }
                          return ListTile(
                              leading: Image.network(
                                content[index].thumbnail,
                                width: MediaQuery.of(context).size.width * 0.2,
                              ),
                              onLongPress: () {
                                print("Open link to video " +
                                    content[index].videoId);
                              },
                              title: RichText(
                                  text: new TextSpan(
                                text: '${content[index].title}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black),
                              )),
                              subtitle: RichText(
                                  text: new TextSpan(
                                text: '${content[index].channelTitle}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.blueGrey),
                              )),
                              trailing: IconButton(
                                  icon: Icon(Icons.file_download),
                                  onPressed: () {
                                    downloader.getAndDownloadYoutubeAudio(
                                        content[index].videoId);
                                  }));
                        }));
              } else {
                return Text("${snapshot.error}");
              }
              //return CircularProgressIndicator(); dont now why i cant place this here
            }));
  }

  void _valueChanged(bool value) => setState(() => _value = value);

  //builds view that present youtube videos
  Container buildChannelList() {
    return new Container(
        child: FutureBuilder<List>(
            future: foundChannels,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List content = snapshot.data;
                //print(content[0].title);
                return new Container(
                    child: new ListView.builder(
                        itemCount: content.length,
                        itemExtent: 150.0,
                        itemBuilder: (BuildContext context, int index) {
                          //some titles were extremly long so i made a quick fix
                          if (content[index].title.length > 25) {
                            content[index].title =
                                content[index].title.substring(0, 25) + "...";
                          }

                          return ListTile(
                              leading: Image.network(content[index].thumbnail),
                              title: RichText(
                                  text: new TextSpan(
                                text: '${content[index].title}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.black),
                              )),
                              trailing: Checkbox(
                                  value: _value, onChanged: _valueChanged));
                        }));
              } else {
                return Text("${snapshot.error}");
              }
              //return CircularProgressIndicator(); dont now why i cant place this here
            }));
  }

  ListView buildListView() {
    return new ListView(
      padding: new EdgeInsets.symmetric(vertical: 8.0),
      children: _buildSearchList(),
    );
  }
  Widget _buildListTile(String path,int index){
     return new ListTile(
         title: new Text(path.split('/').last.split('.').first),
         onTap: () =>
           Navigator.push(context, new MaterialPageRoute(
           builder: (BuildContext context) => new MyTabs(index))
           )
       ,
     );
  }
  List<Widget> _buildSearchList() {
    List<ListItem> _searchList = List();
    if(_searchText.isEmpty) {
      for (int i = 0; i < files.length; i++) {
          _searchList.add(new ListItem(i, files[i].path));
        }
    } else {
      for (int i = 0; i < files.length; i++) {
        String name = files.elementAt(i).path.split('/').last.split('.').first;
        if (name.toLowerCase().contains(_searchText.toLowerCase())) {
          _searchList.add(new ListItem(i, name));

        }
      }

    }
    List<Widget> listTiles = new List();
    for(int i = 0; i < _searchList.length; i++){
       listTiles.add(_buildListTile(_searchList[i].name,_searchList[i].index));
    }
    return  listTiles;
  }

  file() async {
    bool status =
        await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
    while (!status) {
      await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
      status = await SimplePermissions.checkPermission(
          Permission.ReadExternalStorage);
    }
    Directory dir = await getExternalStorageDirectory();
    dir = new Directory(dir.path + '/Yaudio');
    dir
        .list(recursive: true, followLinks: false)
        .toList()
        .then((list) => setState(() {
              files = list;
            }));
  }

  Widget buildBar(BuildContext context) {
    return new AppBar(
      backgroundColor: accentColor,
      centerTitle: true,
      title: this.appBarTitle = new TextField(
        autofocus: true,
        controller: _searchQuery,
        style: new TextStyle(
          color: Colors.white,
        ),
        decoration: new InputDecoration(
            prefixIcon: new Icon(Icons.search, color: Colors.white),
            hintText: "Search...",
            hintStyle: new TextStyle(color: Colors.white)),
      ),
      //search button that recalls the youtube api and fetches result
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            _SearchListState();
            print(_searchText);
            setState(() {
              foundVideos = search(_searchText, "video");
              foundChannels = search(_searchText, "channel");
            });
          },
        ),
      ],
      bottom: new TabBar(controller: controller, tabs: <Tab>[
        new Tab(text: 'Local'),
        new Tab(text: 'Videos'),
        new Tab(text: 'Channel'),
      ]),
    );
  }
}

class ChildItem extends StatelessWidget {
  final String name;

  ChildItem(this.name);

  @override
  Widget build(BuildContext context) {
    //print(index);
    return new ListTile(title: new Text(this.name));
  }
}

//For searching youtube videos
//q: search string
//returns Future list of video classes from search result
Future<List> search(String search, String type) async {
  var url =
      'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$search&maxResults=20&key=$apiKey&type=$type';
  var response = await http
      .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

  List<Video> videos = new List();

  if (response.statusCode == 200) {
    Map<String, dynamic> subsInfo = json.decode(response.body);
    List videoList = subsInfo['items'];
    for (var video in videoList) {
      if (video["snippet"]["liveBroadcastContent"] == "none") {
        videos.add(new Video(
            video["id"]["videoId"],
            video["snippet"]["title"],
            video["snippet"]["thumbnails"]["default"]["url"],
            video["snippet"]["channelTitle"]));
      }
    }
    return videos;
  } else {
    throw Exception('Failed to load post');
  }
}

// Holds important information of a video
class Video {
  String videoId;
  String title;
  String thumbnail;
  String channelTitle;

  Video(
    this.videoId,
    this.title,
    this.thumbnail,
    this.channelTitle,
  );
}

class ListItem{
  final int index;
  final String name;
  ListItem(this.index, this.name);
}
