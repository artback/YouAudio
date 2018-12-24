import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:YouAudio/FilesSingleton.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:media_notification/media_notification.dart';

enum PlayerState { stopped, playing, paused }
class AudioPlayerSingleton{

  PlayerState playerState;
  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;
  AudioPlayer audioPlayer = new AudioPlayer();
  List<FileSystemEntity> files ;
  bool changing = false;

  get currentPlaying =>
      files[current].path.split('/').last.split('.').first.split('|').first;

  get currentPlayingShorted => currentPlaying.substring(
      0, 35 > currentPlaying.length ? currentPlaying.length : 35);


  int current;

  Future<void> hide() async {
    await MediaNotification.hide();
  }

  Future<void> show(title) async {
    await MediaNotification.show(title: title, author: null);
  }

  void playRandom() {
    Random random = new Random();
    play(random.nextInt(files.length));
  }

  void play(int index) async {
    changing = true;
    await audioPlayer.stop();
    playerState = PlayerState.playing;
    await audioPlayer.play(files[index].path);
    current = index;
    show(currentPlayingShorted);
    changing = false;
  }

  Future previous() async {
    while (changing) {
      await new Future.delayed(const Duration(seconds: 5), () => "1");
    }
    play((current - 1) % files.length);
  }

  Future next() async {
    while (changing) {
      await new Future.delayed(const Duration(seconds: 5), () => "1");
    }
    play((current + 1) % files.length);
  }

  Future<void> pause() async {
    if (isPlaying) {
      await audioPlayer.pause();
      playerState = PlayerState.paused;
      hide();
    } else if (isPaused) {
      playerState = PlayerState.playing;
      show(currentPlayingShorted);
      await audioPlayer.play(files[current].path);
    }
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

    MediaNotification.setListener('select', () {});
  }
  static final AudioPlayerSingleton _singleton = new AudioPlayerSingleton._internal();

  factory AudioPlayerSingleton() {
    return _singleton;
  }
  void setFiles(){

  }
  AudioPlayerSingleton._internal(){
    new FilesSingleton().file().then((file )=>
      this.files = file
    );
    initNotification();
  }

}