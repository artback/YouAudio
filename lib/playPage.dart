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
          '2',
          'Video 1',
          'est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\n nqui aperiam non debitis possimus qui neque nisi nulla',
          true,
          'Author 1'
      ));
      videos.add(new Video(
          '3',
          'Video 2',
          'et iusto sed quo iure\nvoluptatem occaecati omnis eligendi aut ad\nvoluptatem doloribus vel accusantium quis pariatur\nmolestiae porro eius odio et labore et velit aut',
          false,
          'Author 2'
      ));
      videos.add(new Video(
          '4',
          'Video 3',
          'ullam et saepe reiciendis voluptatem adipisci\nsit amet autem assumenda provident rerum\n elit',
          false,
          'Author 2'
      ));
      videos.add(new Video(
          '4',
          'Video 3',
          'ullam et saepe reiciendis voluptatem adipisci\nsit amet autem assumenda provident rerum\n elit',
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


