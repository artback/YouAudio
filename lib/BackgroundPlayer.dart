import 'dart:async';

import 'package:YouAudio/FilesSingleton.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:audio_service/audio_service.dart';

MediaItem mediaItem =
MediaItem(id: '1', album: 'Sample Album', title: 'Sample Title');
void myBackgroundTask() {
  Completer completer = Completer();
  MyAudioPlayer player = MyAudioPlayer();


  AudioServiceBackground.run(
    onStart: () async {
      // Keep the background environment alive
      // Until we're finished playing...
      player.play();
      await completer.future;
    },
    onStop: () {
      player._audioPlayer.stop();
      completer.complete();
    },
    onClick: (MediaButton button) {
      player.pause();
    },

  );
}
class MyAudioPlayer {
  bool changing = false;
  AudioPlayer _audioPlayer = new AudioPlayer();
  FilesSingleton singleton = FilesSingleton();
  get files => singleton.files;
  bool _playing = true;
  Completer _completer = Completer();

  Future<void> run() async {
    AudioServiceBackground.setMediaItem(mediaItem);

    var playerStateSubscription = _audioPlayer.onPlayerStateChanged
        .where((state) => state == AudioPlayerState.COMPLETED)
        .listen((state) {
      stop();
    });
    play();
    await _completer.future;
    playerStateSubscription.cancel();
  }
  Future<void> pause() async {
      await _audioPlayer.pause();
  }
  void play() async {
    changing = true;
    await _audioPlayer.stop();
    await _audioPlayer.play(files[0]);
    AudioServiceBackground.setState(
      controls: [pauseControl, stopControl],
      state: PlaybackState.playing,
    );
    changing = false;
  }


  playPause() {
      if (_playing)
        pause();
      else
        play();
  }


  void stop() {
    _audioPlayer.stop();
  }
}

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

