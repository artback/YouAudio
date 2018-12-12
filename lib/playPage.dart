import 'dart:io';

import 'package:YouAudio/bottomButtonControl.dart';
import 'package:YouAudio/dataModel/video.dart';
import 'package:YouAudio/permission.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';

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
  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;

  List<FileSystemEntity> files = new List();
  @override
  void initState() {
    super.initState();
    file() {
      Directory dir = Directory('/storage/emulated/0/Yaudio');
      dir.list(recursive: true, followLinks: false).toList().then((list) =>
          setState(() {
            files = list;
          }));
    }
    checkOrActivatePermission(Permission.ReadExternalStorage)
        .whenComplete(() => file());
  }
  @override
  Widget build(BuildContext context) {
    return new Container
      (
      child: ListView.builder(
        itemCount: files == null ? 0 : files.length,
        itemBuilder: (BuildContext context, int position) {
          return ListTile(
            title: RichText(
              text: new TextSpan(
                text: '${files[position].path.split('/').last.split('.').first}',
                style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black),
              ),
            ),
          );
        },
      )
    );
  }
}


