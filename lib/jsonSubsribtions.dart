import 'dart:convert';
import 'dart:io';

import 'package:YouAudio/dataModel/subscribtions.dart';
import 'package:path_provider/path_provider.dart';
String fileName = "chosenSubscribers.json";
File _jsonFile;
Directory _dir;
bool fileExists = false;
Map<String, dynamic> fileContent;

Future<List<Sub>> getSubscribtionsFromFile() async {
  List<Sub> mySubs = new List<Sub>();
  _dir = await getApplicationDocumentsDirectory();
    _jsonFile = new File(_dir.path + "/" + fileName);
    fileExists = _jsonFile.existsSync();
    if (fileExists) {
      String file = _jsonFile.readAsStringSync();
      if(file.isNotEmpty) {
        fileContent = json.decode(_jsonFile.readAsStringSync());
        List filec = fileContent.values.first;
        filec.forEach((sub) =>
            mySubs.add(new Sub(
                sub['title'], sub['channelId'], sub['img'], sub['checked'],
                sub['description'])));
        print(mySubs);
      }
    } else {
      createFile();
      mySubs = await getSubscribtionsFromFile();
    }
  return mySubs;
}
void createFile() async{
  _dir = await getApplicationDocumentsDirectory();
  File file = new File(_dir.path + "/" + fileName);
  file.createSync();
  fileExists = true;
}
void writeToFile(List<Sub> subs) {
  var mySubscribers = [];
  for (Sub x in subs) {
    var temp = {};
    temp["title"] = x.title;
    //temp["description"] = x.description;
    temp["channelId"] = x.channelId;
    temp["img"] = x.img;
    temp["checked"] = x.checked;
    mySubscribers.add(temp);
  }
  _writeToFile(json.encode({"all": mySubscribers}));

}
Future addToFile(List<Sub> subs) async {
  List<Sub> mySubs = await getSubscribtionsFromFile();
  List<String> ids = mySubs.map((sub) => sub.channelId).toList();
  ifContains(Sub sub){
    if(!ids.contains(sub.channelId)){
      mySubs.add(sub);
    }
  }
  print(mySubs.length);
  subs.forEach(ifContains);
  writeToFile(mySubs);
}
void _writeToFile(String subs) {
  if (!fileExists) {
    createFile();
  }
  _jsonFile.writeAsStringSync(subs);
}
