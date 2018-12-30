import 'package:YouAudio/dataModel/video.dart';
import 'package:flutter/material.dart';

class ChannelPage extends StatefulWidget {
  final String id;

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
      videos.add(new Video('Video 1', true, 'Author 1'));
      videos.add(new Video('Video 2', false, 'Author 1'));
      videos.add(new Video('Video 3', false, 'Author 2'));
      videos.add(new Video('Video 3', false, 'Author 2'));
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Navigator.of(context).pop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: ListView.builder(
          itemCount: videos != null ? videos.length : 0,
          itemBuilder: (context, position) {
            return ListTile(
                title: RichText(
                  text: new TextSpan(
                    text: '${videos[position].title}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),
                trailing: videos[position].downloaded
                    ? new IconButton(
                    icon: new Icon(Icons.file_download), onPressed: null)
                    : new IconButton(
                    icon: new Icon(Icons.play_arrow), onPressed: null));
          },
        ));
  }
}
