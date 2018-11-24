import 'package:flutter/material.dart';
import 'package:youtube_podcaster/bottomButtonControl.dart';

class Play extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Expanded(
          // @TODO files list in container
          child: new FileList()
        ),
        new BottomControl()
      ],
    );
  }
}

class FileList extends StatefulWidget {
  const FileList({
    Key key,
  }) : super(key: key);

  @override
  FileListState createState() {
    return new FileListState();
  }
}

class FileListState extends State<FileList> {
  List data;
  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: data == null ? 0 : data.length,
      itemBuilder: (BuildContext context, int index){
       // @TODO list all downloaded files
      },
    );
  }
}


