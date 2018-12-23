
import 'package:YouAudio/BackgroundPlayer.dart';
import 'package:YouAudio/FilesSingleton.dart';
import 'package:YouAudio/theme.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';


class Play extends StatefulWidget {
  int index;
  Play([this.index]);

  @override
  PlayState createState() {
    return new PlayState();
  }
}

class PlayState extends State<Play> with WidgetsBindingObserver {
  FilesSingleton singleton = FilesSingleton();
  get files => singleton.files;
  Duration duration;
  Duration position;
  PlaybackState state;
  get isPlaying => state == PlaybackState.playing;
  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  get currentPlayingShorted => "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    connect();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        connect();
        break;
      case AppLifecycleState.paused:
        AudioService.disconnect();
        break;
      default:
        break;
    }
  }

  void connect() {
    AudioService.connect(
      onPlaybackStateChanged: (state, position, speed, updateTime) {
        setState(() {
          this.position = new Duration(seconds:  position);
          this.state = state;
        });
      },
    );
  }




  Widget build(BuildContext context) {
    return new Scaffold(
    body: new Column(
      children: <Widget>[
        new Expanded(
            // @TODO files list in container
            child: new Container(
                child: ListView.builder(
          itemCount: files == null ? 0 : files.length,
          itemBuilder: (BuildContext context, int position) {
            String title =
                files[position].path.split('/').last.split('.').first;
            if (title.length >= 72) title = title.substring(0, 72) + "...";
            return Dismissible(
                key: Key(singleton.files[position].path),
                onDismissed: (direction) {
                  files[position].delete();
                  setState(() {
                    files.removeAt(position);
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
                  onTap: () => play(),
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
                            onChanged: (double value) => AudioService.seekTo(value.round()) ,
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
                              text: !isPlaying
                                  ? '$currentPlayingShorted '
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
                              new PreviousButton(AudioService.skipToPrevious),
                              new Expanded(child: new Container()),
                              new PlayButton(AudioService.pause,isPlaying: isPlaying),
                              new Expanded(child: new Container()),
                              new NextButton(AudioService.skipToNext),
                              new Expanded(child: new Container()),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )))
      ],
    )
    );
  }
  play() {
    if (state == PlaybackState.paused) {
      AudioService.play();
    } else {
      AudioService.start(
        backgroundTask: _backgroundAudioPlayerTask,
        //backgroundTask: _backgroundTextToSpeechTask,
        resumeOnClick: true,
        notificationChannelName: 'Audio Service Demo',
        notificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/ic_launcher',
        queue: [mediaItem],
      );
    }
  }
}

class PlayButton extends StatelessWidget {
  final VoidCallback _onTap;
  const PlayButton(this._onTap,{@required this.isPlaying});

  final bool isPlaying;
  @override
  Widget build(BuildContext context) {
    return new RawMaterialButton(
      onPressed: () => {
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
              isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              color: darkAccentColor,
              size: 35.0)),
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
void _backgroundAudioPlayerTask() async {
  MyAudioPlayer player = MyAudioPlayer();
  AudioServiceBackground.run(
    onStart: player.run,
    onPlay: player.play,
    onPause: player.playPause,
    onStop: player.stop,
    onClick: (MediaButton button) => player.playPause(),
  );
}
