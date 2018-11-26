import 'package:YouAudio/dataModel/video.dart';
import 'package:YouAudio/theme.dart';
import 'package:flutter/material.dart';

class ChannelPage extends StatefulWidget {
  final int id;
  ChannelPage(this.id);
  @override
  ChannelPageState createState() {
    return new ChannelPageState();
  }
}

class ChannelPageState extends State<ChannelPage> {
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
        false
      ));
      videos.add(new Video(
        '4',
        'Video 3',
        'ullam et saepe reiciendis voluptatem adipisci\nsit amet autem assumenda provident rerum\n elit',
        false
      ));
      videos.add(new Video(
          '4',
          'Video 3',
              'ullam et saepe reiciendis voluptatem adipisci\nsit amet autem assumenda provident rerum\n elit',
          false
      ));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new AppBar(
        backgroundColor: accentColor,
        leading: new IconButton(
        icon: new Icon(Icons.arrow_back),
        onPressed: (){
         Navigator.pop(context);
        },
        )
        ),
      body: new Container(
          child: ListView.builder(
            itemCount: videos != null ? videos.length : 0,
            itemBuilder: (context, position) {
              return ListTile(
                title: RichText(
                  text: new TextSpan(
                    text:'${videos[position].name}',
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black),
                  ),
                ),
                subtitle: Text('${videos[position].description}'),
                trailing: videos[position].downloaded ?
                new IconButton(icon: new Icon(Icons.file_download), onPressed: null) :
                new IconButton(icon: new Icon(Icons.playlist_play), onPressed: null)
              );
            },
          )
      ),
    );
  }
}


