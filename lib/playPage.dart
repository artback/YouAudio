import 'dart:async';

import 'package:YouAudio/AudioPlayerSingleton.dart';
import 'package:YouAudio/FilesSingleton.dart';
import 'package:YouAudio/theme.dart';
import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';


class Play extends StatefulWidget {
  int index;
  Play([this.index]);
  @override
  PlayState createState() {
    return new PlayState();
  }
}

class PlayState extends State<Play> {

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;
  Duration duration;
  Duration position;
  AudioPlayerSingleton audioPlayerSingleton =  new AudioPlayerSingleton();
  get audio => audioPlayerSingleton.audioPlayer;


  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';



  int current;

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    super.dispose();
  }


  void initAudioPlayer() {
    _positionSubscription = audio.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    _audioPlayerStateSubscription =
        audio.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            setState(() => duration = audio.duration);
          } else if (s == AudioPlayerState.STOPPED) {
            duration= null;
            setState(() {
              position = duration;
            });
        } else if (s == AudioPlayerState.COMPLETED){
            audioPlayerSingleton.next();
        }
        }, onError: (msg) {
          setState(() {
            audioPlayerSingleton.playerState = PlayerState.stopped;
            duration = new Duration(seconds: 0);
            position = new Duration(seconds: 0);
          });
        });
  }
  @override
  void initState() {
    super.initState();
    if(audioPlayerSingleton.isPlaying){
     setState(() {
      duration = audio.duration;
     });
    }
    new FilesSingleton().file().then((files) =>
    setState((){
      audioPlayerSingleton.files = files;
    })
    );
    if(widget.index != null){
      audioPlayerSingleton.play(widget.index);
      widget.index = null;
    }
    initAudioPlayer();
  }


  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Expanded(
            // @TODO files list in container
            child: new Container(
                child: ListView.builder(
          itemCount: audioPlayerSingleton.files == null ? 0 : audioPlayerSingleton.files.length,
          itemBuilder: (BuildContext context, int position) {
            String title =
                audioPlayerSingleton.files[position].path.split('/').last.split('.').first;
            if (title.length >= 72) title = title.substring(0, 72) + "...";
            return Dismissible(
                key: Key(audioPlayerSingleton.files[position].path),
                onDismissed: (direction) {
                  setState(() {
                    audioPlayerSingleton.delete(position);
                  });
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text("$title deleted")));
                },
                background: Container(
                  color: Colors.redAccent,
                ),
                child: ListTile(
                  title: RichText(
                    text: new TextSpan(
                      text: '$title',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black),
                    ),
                  ),
                  onTap: () => audioPlayerSingleton.play(position),
                ));
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
                            value: position?.inMilliseconds?.toDouble() ?? 0.0,
                            onChanged: (double value) => audio
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
                              text: audioPlayerSingleton.current != null
                                  ? '${audioPlayerSingleton.currentPlayingShorted} '
                                  : '',
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
                                text: new TextSpan(
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
                              new PreviousButton(audioPlayerSingleton.previous),
                              new Expanded(child: new Container()),
                              new RawMaterialButton(
                                onPressed: (){
                                  audioPlayerSingleton.pause();
                                  setState(() {
                                    audioPlayerSingleton.playerState = audioPlayerSingleton.playerState;
                                  });
                                },
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
                                        audioPlayerSingleton.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: darkAccentColor,
                                        size: 35.0)),
                              ),
                              new Expanded(child: new Container()),
                              new NextButton(audioPlayerSingleton.next),
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
        onPressed: _onTap);
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
