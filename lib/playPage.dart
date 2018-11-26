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
          true
      ));
      videos.add(new Video(
          '3',
          'Video 2',
          'et iusto sed quo iure\nvoluptatem occaecati omnis eligendi aut ad\nvoluptatem doloribus vel accusantium quis pariatur\nmolestiae porro eius odio et labore et velit aut',
          true
      ));
      videos.add(new Video(
          '4',
          'Video 3',
          'ullam et saepe reiciendis voluptatem adipisci\nsit amet autem assumenda provident rerum\n elit',
          true
      ));
      videos.add(new Video(
          '4',
          'Video 3',
          'ullam et saepe reiciendis voluptatem adipisci\nsit amet autem assumenda provident rerum\n elit',
          true
      ));
    });
  }
  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: data == null ? 0 : data.length,
      itemBuilder: (BuildContext context, int position){
        return ListTile(
            title: RichText(
            text: new TextSpan(
            text:'${videos[position].name}',
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black),
        ),
        ),
        subtitle: Text('${videos[position].description}'),
        );
      },
    );
  }
}


