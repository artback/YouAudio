import 'dart:io';

import 'package:YouAudio/bottomButtonControl.dart';
import 'package:YouAudio/permission.dart';
import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:simple_permissions/simple_permissions.dart';

enum PlayerState { stopped, playing, paused }

class Play extends StatefulWidget {
  @override
  PlayState createState() {
    return new PlayState();
  }
}

class PlayState extends State<Play> {
  Duration duration;
  Duration position;
  List<FileSystemEntity> files = new List();
  BottomControl bottomControl;
  AudioPlayer audioPlayer = new AudioPlayer();
  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;
  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';
  var playerState;


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
    bottomControl = BottomControl(null, null, null);
  }

  AudioPlayer audioPlugin = new AudioPlayer();

  void play(int index) async {
      if(isPlaying){
        await audioPlayer.stop();
      }
      await audioPlayer.play(files[index].path);
      setState(() => playerState = PlayerState.playing);
  }

  Future<void> pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Expanded(
            // @TODO files list in container
            child: new Container(
                child: ListView.builder(
          itemCount: files == null ? 0 : files.length,
          itemBuilder: (BuildContext context, int position) {
            return ListTile(
              title: RichText(
                text: new TextSpan(
                  text:
                      '${files[position].path.split('/').last.split('.').first}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black),
                ),
              ),
              onTap: ()  => play(position),
            );
          },
        ))),
        bottomControl
      ],
    );
  }
}
