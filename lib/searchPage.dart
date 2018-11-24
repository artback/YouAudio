import 'package:flutter/material.dart';
import 'package:youtube_podcaster/theme.dart';

class SearchList extends StatefulWidget {
  SearchList({ Key key }) : super(key: key);
  @override
  _SearchListState createState() => new _SearchListState();

}

class _SearchListState extends State<SearchList>
{
  Widget appBarTitle = new Text("", style: new TextStyle(color: Colors.white),);
  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = new TextEditingController();
  List<String> _list;
  String _searchText = "";


  @override
  void initState() {
    super.initState();

    init();

  }
  _SearchListState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      }
      else {
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
      body: new ListView(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        children:  _buildSearchList(),
      ),
    );
  }


  List<ChildItem> _buildSearchList() {
    if (_searchText.isEmpty) {
      return _list.map((contact) => new ChildItem(contact))
          .toList();
    }
    else {
      List<String> _searchList = List();
      for (int i = 0; i < _list.length; i++) {
        String  name = _list.elementAt(i);
        if (name.toLowerCase().contains(_searchText.toLowerCase())) {
          _searchList.add(name);
        }
      }
      return _searchList.map((contact) => new ChildItem(contact))
          .toList();
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
              hintStyle: new TextStyle(color: Colors.white)
          ),
        )
    );
  }

}

class ChildItem extends StatelessWidget {
  final String name;
  ChildItem(this.name);
  @override
  Widget build(BuildContext context) {
    return new ListTile(title: new Text(this.name));
  }

}

