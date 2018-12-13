import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
typedef listCallback = List<FileSystemEntity> Function();
class FileList extends StatefulWidget {
  const FileList({
    Key key,
  }) : super(key: key);

  @override
  FileListState createState() {
    return new FileListState();
  }
}

class FileListState extends State<FileList> {
  List<FileSystemEntity> files = new List();

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
  }
}
