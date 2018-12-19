import 'package:YouAudio/theme.dart';
import 'package:flutter/material.dart';

//import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'dart:io';



var apiKey   = "AIzaSyBKdwbjbsGdHyNPS0q3J6cffOsUSfiqCx4";

class SearchList extends StatefulWidget {
  SearchList({Key key}) : super(key: key);
  @override
  _SearchListState createState() => new _SearchListState();
}

class _SearchListState extends State<SearchList>
    with SingleTickerProviderStateMixin {
  Widget appBarTitle = new Text(
    "",
    style: new TextStyle(color: Colors.white),
  );
  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = new TextEditingController();
  List<String> _list;
  String _searchText = "";
  TabController controller;
  Future<List> foundVideos;

  @override
  void initState() {
    super.initState();
    controller = new TabController(vsync: this, length: 3);
    init();
    foundVideos = search(_searchText);
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
        });
      }
    });
  }
  void init() {
    _list = List();
    _list.add("Video 1");
    _list.add("Video 2");
    _list.add("Video 3");
    _list.add("Video 4");
    _list.add("Video 5");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: key,
        appBar: buildBar(context),
        body: new TabBarView(controller: controller, children: <Widget>[
          buildListView(),
          buildVideoList(), //View for searching youtube videos
          buildListView()
        ]));
  }

  //builds view that present youtube videos
  Container buildVideoList() {
    return new Container (
      child: FutureBuilder<List>(
          future: foundVideos,
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
                      if(content[index].title.length > 25) {
                        content[index].title = content[index].title.substring(0, 25) + "...";
                      }

                      return ListTile(
                        leading: Image.network(content[index].thumbnail),

                        title: RichText(
                            text: new TextSpan(
                              text: '${content[index].title}',
                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black),
                            )
                        ),

                      trailing: IconButton(
                          icon: Icon(Icons.file_download),
                          onPressed: () {
                            //add download function here
                            print("downloading " + content[index].title);
                          }

                      )
                      );
                    }
              )
              );

            } else {
              return Text("${snapshot.error}");
            }
            //return CircularProgressIndicator(); dont now why i cant place this here
          }
      )
    );
  }

  ListView buildListView() {
    return new ListView(
      padding: new EdgeInsets.symmetric(vertical: 8.0),
      children: _buildSearchList(),
    );
  }

  List<ChildItem> _buildSearchList() {
    if (_searchText.isEmpty) {
      return _list.map((contact) => new ChildItem(contact)).toList();
    } else {
      List<String> _searchList = List();
      for (int i = 0; i < _list.length; i++) {
        String name = _list.elementAt(i);
        if (name.toLowerCase().contains(_searchText.toLowerCase())) {
          _searchList.add(name);
        }
      }
      return _searchList.map((contact) => new ChildItem(contact)).toList();
    }
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
              foundVideos = search(_searchText);
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
Future<List> search(String q) async {
  var url = 'https://www.googleapis.com/youtube/v3/search?part=snippet&q=${q}&maxResults=20&key=${apiKey}';
  var response = await http.get(
      Uri.encodeFull(url),
      headers: {
        "Accept": "application/json"
      }
  );

  List<Video> videos = new List();

  if (response.statusCode == 200) {
    Map<String, dynamic> subsInfo = json.decode(response.body);
    List videoList = subsInfo['items'];
    for(var x in videoList) {

      videos.add(new Video(x["id"]["videoId"],
          x["snippet"]["title"],
          x["snippet"]["thumbnails"]["default"]["url"]
      ));
      //print(x["id"]["videoId"]);
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

  Video(this.videoId,
      this.title,
      this.thumbnail,
      );
}


