
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

class FilesSingleton{
  static final FilesSingleton _singleton = new FilesSingleton._internal();
  List<FileSystemEntity> files = new List();
  factory FilesSingleton() {
    return _singleton;
  }


  Future file() async {
    bool status =
    await SimplePermissions.checkPermission(Permission.ReadExternalStorage);
    while (!status) {
      await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
      status = await SimplePermissions.checkPermission(
          Permission.ReadExternalStorage);
    }
    Directory dir = await getExternalStorageDirectory();
    String downloadLocation = dir.path + '/Yaudio';
    dir = Directory(downloadLocation);
    return dir
        .list(recursive: true, followLinks: false)
        .toList()
        .then((list) => files = list);
  }
  FilesSingleton._internal(){
    file();
  }
}