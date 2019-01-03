import 'package:YouAudio/channelPage.dart';

import 'package:YouAudio/dataModel/subscribtions.dart';import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:YouAudio/main.dart';

//my own ChannelId and apiKey  find out your own if you wanna try
//login implementation should give ous a way to access a users ChannelId and apiKey
var channelID = "UCo2t0ix-2JT06o_RmqCQ";
var apiKey = "AIzaSyBKdwbjbsGdHyNPS0q3J6cffOsUSfiqCx4";
var subApi =
    "https://www.googleapis.com/youtube/v3/subscriptions?part=snippet&channelId=$channelID&maxResults=20&key=$apiKey";

//variables for writing/reading from file
File jsonFile;
Directory dir;
String fileName = "chosenSubscribers.json";
bool fileExists = false;
Map<String, dynamic> fileContent;

class SubscriptionsPage extends StatefulWidget {
  @override
  SubscriptionsPageState createState() {
    return new SubscriptionsPageState();
  }
}

class SubscriptionsPageState extends State<SubscriptionsPage> {
  Future<List<Sub>> subscribers;
  List<Sub> mySubs = new List();

  void createFile() {
    print("Creating file!");
    File file = new File(dir.path + "/" + fileName);
    file.createSync();
    fileExists = true;
  }

  //give decoded json string and it will write that to file
  void writeToFile(String subs) {
    print("Writing to file!");
    if (fileExists) {
      jsonFile.writeAsStringSync(subs);
    } else {
      createFile();
    }
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
  }
  @override
  void initState() {
    super.initState();
    subscribers = getData(subApi);
    //get json from to map(string, dynamic) variable if file exist
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists) {
          fileContent = json.decode(jsonFile.readAsStringSync());
          List filec = fileContent.values.first;
          filec.forEach((sub) => mySubs.add(new Sub(sub['id'], sub['title'], sub['description'], sub['channelId'], sub['img'], sub['checked'])));
          setState(() { mySubs = mySubs;});
      }else{
        createFile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
                  child:
                  new Scaffold(
                  body: new ListView.builder(
                          itemCount: mySubs != null ? mySubs.length : 0  ,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: RichText(
                                text: new TextSpan(
                                text: '${mySubs[index].title}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black),
                              )),
                              trailing: new Checkbox(
                                  value: mySubs[index].checked != null ? mySubs[index].checked : false,
                                  //on press change checked value to true/false
                                  onChanged: (bool value) {
                                    setState(() {
                                      mySubs[index].checked = value;
                                    });
                                  }),
                              onTap: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) =>  new MyTabs(new ChannelPage(mySubs[index].channelId),1))
                                );
                              },
                            );
                          }),
                  floatingActionButton: new FloatingActionButton(
                    child: new Icon(Icons.save),
                    onPressed: () {
                      var mySubscribers = [];
                      for (Sub x in mySubs) {
                        var temp = {};
                          temp["id"] = x.id;
                          temp["title"] = x.title;
                          temp["description"] = x.description;
                          temp["channelId"] = x.channelId;
                          temp["img"] = x.img;
                          temp["checked"] = x.checked;
                          mySubscribers.add(temp);
                      }
                      writeToFile(json.encode({"all": mySubscribers}));
                    },
                  )
    )
    );
  }
}


//fetches api write it to sub list
//takes fetched json and checks it with fetched subs to see of they already exists in file(could be broken out)
//return List with all subs
Future<List<Sub>> getData(String url) async {
  http.Response response = await http
      .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
  List<Sub> items = new List();
  if (response.statusCode == 200) {
    Map<String, dynamic> subsInfo = json.decode(response.body);
    List subsList = subsInfo['items'];

    //could combine the two for loops below but this works

    //add all found subbed accounts from api to a list
    for (var x in subsList) {
      items.add(new Sub(
          x["id"],
          x["snippet"]["title"],
          x["snippet"]["description"],
          x["snippet"]["resourceId"]["channelId"],
          x["snippet"]["thumbnails"]["default"]["url"],
          false));
    }

    //check if any of subbed accounts already is chosen by user if so add checked to true
    if (fileContent != null) {
      for (var i in fileContent["all"]) {
        for (Sub x in items) {
          if (i["id"] == x.id) {
            x.checked = true;
          }
        }
      }
    }
  }
  return items;
}

