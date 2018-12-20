import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:YouAudio/theme.dart';
import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:media_notification/media_notification.dart';
enum _PlayerState { stopped, playing, paused }
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
  AudioPlayer audioPlayer = new AudioPlayer();

  get isPlaying => playerState == _PlayerState.playing;

  get isPaused => playerState == _PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  get currentPlaying =>
      files[current].path.split('/').last.split('.').first.split('|').first;

  get currentPlayingShorted => currentPlaying.substring(
      0, 35 > currentPlaying.length ? currentPlaying.length : 35);
  bool changing = false;
  _PlayerState playerState;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  int current;

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }
  void playRandom(){
    Random random = new Random();
    play(random.nextInt(files.length));
  }
  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = _PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }
  void initNotification() {
    MediaNotification.setListener('pause', () {
        pause();
    });

    MediaNotification.setListener('play', () {
      pause();
    });

    MediaNotification.setListener('next', () {
      next();
    });

    MediaNotification.setListener('prev', () {
      previous();
    });

    MediaNotification.setListener('select', () {

    });
  }
  file() async{
    bool status = await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
    while(!status){
      await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
      status = await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
    }
    Directory dir = Directory('/storage/emulated/0/Yaudio');
    dir.list(recursive: true, followLinks: false)
        .toList()
        .then((list) => setState(() {
      files = list;
    }));
  }
  Future<void> hide() async {
      await MediaNotification.hide();
  }

  Future<void> show(title) async {
      await MediaNotification.show(title: title, author: null);
  }
  @override
  void initState() {
    super.initState();
    file();
    initAudioPlayer();
    initNotification();
  }

  void play(int index) async {
    changing = true;
    setState(() {
      duration = null;
    });
    if (isPlaying) {
      await audioPlayer.stop();
    }
    await audioPlayer.play(files[index].path);
    setState(() => playerState = _PlayerState.playing);
    setState(() => current = index);
    show(currentPlayingShorted);
    changing = false;
  }

  Future previous() async {
    while(changing){
      await new Future.delayed(const Duration(seconds: 5), () => "1");
    }
    play((current - 1) % files.length);
  }

  Future next() async {
    while(changing){
      await new Future.delayed(const Duration(seconds: 5), () => "1");
    }
    play((current + 1) % files.length);
  }

  Future<void> pause() async {
    if (isPlaying) {
      await audioPlayer.pause();
      setState(() => playerState = _PlayerState.paused);
      hide();
    } else if(isPaused) {
      await audioPlayer.play(files[current].path);
      setState(() => playerState = _PlayerState.playing);
      show(currentPlayingShorted);
    }
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
              onTap: () => play(position),
            );
          },
        ))),
        new Container(
            width: double.infinity,
            child: new Material(
                color: accentColor,
                child: new Column(
                  children: <Widget>[
                    duration == null
                        ? new Container()
                        : new Slider(
                        value: position?.inMilliseconds?.toDouble() ??
                            0.0,
                        onChanged: (double value) => audioPlayer
                            .seek((value / 1000).roundToDouble()),
                        activeColor: Colors.white,
                        min: 0.0,
                        max: duration.inMilliseconds.toDouble()),
                    new Padding(
                      padding: const EdgeInsets.only(top: 0.0, bottom: 12.0),
                      child: new Column(
                        children: <Widget>[
                          new RichText(
                              text: new TextSpan(text: '', children: [
                            new TextSpan(
                              text:
                                  current != null ? '$currentPlayingShorted ' : '',
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  height: 2),
                            ),
                          ])),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RichText(
                               text:
                               new TextSpan(
                                 text: position != null
                                     ? "${positionText ?? ''} / ${durationText ?? ''}"
                                     : duration != null ? durationText : '',
                                 style: new TextStyle(
                                     color: Colors.white.withOpacity(0.75),
                                     fontSize: 12.0,
                                     fontWeight: FontWeight.bold,
                                     letterSpacing: 1.0,
                                     height: 1.0),
                               ),
                              )
                            ],
                          ),
                          new Padding(padding: EdgeInsets.only(bottom: 10)),
                          new Row(
                            children: <Widget>[
                              new Expanded(child: new Container()),
                              new PreviousButton(previous),
                              new Expanded(child: new Container()),
                              new RawMaterialButton(
                                onPressed: pause,
                                shape: new CircleBorder(),
                                fillColor: Colors.white,
                                splashColor: lightAccentColor,
                                highlightColor:
                                    lightAccentColor.withOpacity(0.5),
                                elevation: 10.0,
                                highlightElevation: 5.0,
                                child: new Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: new Icon(
                                        isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: darkAccentColor,
                                        size: 35.0)),
                              ),
                              new Expanded(child: new Container()),
                              new NextButton(next),
                              new Expanded(child: new Container()),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )))
      ],
    );
  }
}

class NextButton extends StatelessWidget {
  final VoidCallback _onTap;

  const NextButton(this._onTap);

  @override
  Widget build(BuildContext context) {
    return new IconButton(
        splashColor: lightAccentColor,
        highlightColor: Colors.transparent,
        icon: new Icon(Icons.skip_next, color: Colors.white, size: 35.0),
        onPressed: _onTap
    );
  }
}

class PreviousButton extends StatelessWidget {
  final VoidCallback _onTap;

  PreviousButton(this._onTap);

  @override
  Widget build(BuildContext context) {
    return new IconButton(
      splashColor: lightAccentColor,
      highlightColor: Colors.transparent,
      icon: new Icon(Icons.skip_previous, color: Colors.white, size: 35.0),
      onPressed: _onTap,
    );
  }
}
