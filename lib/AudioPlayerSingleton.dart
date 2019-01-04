import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:YouAudio/FilesSingleton.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:media_notification/media_notification.dart';
import 'package:simple_permissions/simple_permissions.dart';

enum PlayerState { stopped, playing, paused }
class AudioPlayerSingleton{

  PlayerState playerState;
  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;
  AudioPlayer audioPlayer = new AudioPlayer();
  List<FileSystemEntity> files;
  bool changing = false;

  get currentPlaying => files.isNotEmpty ?
      files[current].path.split('/').last.split('.').first.split('|').first : '';

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
  Future delete(int index) async {
    bool status = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);
    while (!status) {
      await SimplePermissions.requestPermission(
          Permission.WriteExternalStorage);
      status = await SimplePermissions.checkPermission(
          Permission.WriteExternalStorage);
    }
   if(current != null) {
     if (current >= index) {
       current -= 1 % files.length;
       if(current == -1){
         current = 0;
       }
       print(current);
       play(current);
     }
   }

   FileSystemEntity remove = this.files[index];
   this.files.removeAt(index);
   remove.delete();
   if(files.isEmpty){
     current = null;
     audioPlayer.stop();
     hide();
   }
  }

  void play(int index) async {
    if(files == null){
      files =  await new FilesSingleton().file();
    }
    changing = true;
    await audioPlayer.stop();
    playerState = PlayerState.playing;
    if(files.length > 0) {
      await audioPlayer.play(files[index].path);
      current = index;
      show(currentPlayingShorted);
    }else{
     current = null;
     hide();
    }
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
  AudioPlayerSingleton._internal(){
    initNotification();
  }

}