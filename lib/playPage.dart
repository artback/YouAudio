import 'package:YouAudio/bottomButtonControl.dart';
import 'package:YouAudio/dataModel/video.dart';
import 'package:flutter/material.dart';

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
  final List<Video> videos = new List();
  @override
  void initState() {
    super.initState();
    setState(() {
      videos.add(new Video(
          'Video 1',
          true,
          'Author 1'
      ));
      videos.add(new Video(
          'Video 2',
          false,
          'Author 2'
      ));
      videos.add(new Video(
          'Video 3',
          false,
          'Author 2'
      ));
      videos.add(new Video(
          'Video 3',
          false,
          'Author 2'
      ));
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Container
      (
      child: ListView.builder(
        itemCount: videos == null ? 0 : videos.length,
        itemBuilder: (BuildContext context, int position) {
          return ListTile(
            title: RichText(
              text: new TextSpan(
                text: '${videos[position].name}',
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


