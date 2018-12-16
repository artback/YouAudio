//import 'package:YouAudio/channelPage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

//clean up and deviding code would be good but it works for now
//could probably break up Sub class to other file
//could break up write to file functions to own class


//my own ChannelId and apiKey  find out your own if you wanna try
//login implementation should give ous a way to access a users ChannelId and apiKey
var channelID = "UCo2fdNt0ix-2JT06o_RmqCQ";
var apiKey    = "AIzaSyBKdwbjbsGdHyNPS0q3J6cffOsUSfiqCx4";
var subApi    = "https://www.googleapis.com/youtube/v3/subscriptions?part=snippet&channelId=${channelID}&maxResults=20&key=${apiKey}";

//varibles for writing/reading from file
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
  Future<List> subscribers;

  //create file to folder if file already exist it will delete old(i think atleast during my
  // testing that what i got out of it)
  void createFile() {
    print("Creating file!");
    File file = new File(dir.path + "/" + fileName);
    //print(dir.path + "/" + fileName);
    file.createSync();
    fileExists = true;
  }

  //give decoded json string and it will write that to file
  void writeToFile(String subs) {
    print("Writing to file!");
    if (fileExists) {
      print("File exists");
      jsonFile.writeAsStringSync(subs);
    } else {
      print("File does not exist!");
      createFile();
    }
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
    print(fileContent);
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
        this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
      }

      //subscribers = getData(subApi);
    });
  }


  @override
  Widget build(BuildContext context) {
    return new Container(
      child: FutureBuilder<List>(
          future: subscribers,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List content = snapshot.data;
              return new Column(
                children: <Widget>[
                  new Expanded(
                    // @TODO files list in container
                      child: new ListView.builder(
                          itemCount: content.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: RichText(
                                  text: new TextSpan(
                                    text: '${content[index].title}',
                                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black),
                                  )
                              ),

                              //subtitle: Text('content[index]["snippet"]["description"]'), if we want to add description add here
                              trailing: new Checkbox(
                                  value: content[index].checked,
                                  //on press change checked value to true/false
                                  onChanged: (bool value) {
                                    setState(() {
                                      content[index].checked = value;
                                    });
                                  }
                              ),
                            );
                          }
                      )
                  ),
                  new RaisedButton(
                    child: new Text("Save"),
                    onPressed: (){
                      //add subs to dicts then to list becouse thats the only way that
                      //I found worked when trying to convert it to json for file
                      //create file(if file already exist its deleted) and write to it
                      var mySubscribers = [];
                      for(var x in content) {
                        var temp = {};
                        if(x.checked) {
                          temp["id"] = x.id;
                          temp["title"] = x.title;
                          temp["description"] = x.description;
                          temp["channelId"] = x.channelId;
                          temp["img"] = x.img;

                          mySubscribers.add(temp);
                        }
                      }
                      //print(json.encode({"all": mySubscribers}));
                      createFile();
                      writeToFile(json.encode({"all": mySubscribers}));
                    },
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          }
      ),
    );
  }
}


/*List<Sub> getSubsmerged(List<Sub> notOld, List old)  {

  for(var i in old) {
    for(var x in notOld){
      if(i["id"] == x.id) {
        x.checked = true;
        print("----");
        //print(i["title"]);
        //print("----");
      }
    }
  }

  return notOld;
}*/

//feteches api write it to sub list
//takes fetched json and checks it with fetched subs to see of they already exists in file(could be broken out)
//return List with all subs
Future<List> getData(String url) async {
  var response = await http.get(
      Uri.encodeFull(url),
      headers: {
          "Accept": "application/json"
      }
  );

  if (response.statusCode == 200) {

    Map<String, dynamic> subsInfo = json.decode(response.body);
    List subsList = subsInfo['items'];
    List<Sub> items = new List();

    //could combine the two for loops below but this works

    //add all found subbed accounts from api to a list
    for (var x in subsList) {
      items.add(new Sub(
        x["id"],
        x["snippet"]["title"],
        x["snippet"]["description"],
        x["snippet"]["channelId"],
        x["snippet"]["thumbnails"]["default"]["url"],
        false
      ));
    }

    //check if any of subbed acounts already is chosen by user if so add checked to true
    for(var i in fileContent["all"]) {
      for(var x in items){
        if(i["id"] == x.id) {
          x.checked = true;
        }
      }
    }

    return items;
  } else {
    throw Exception('Failed to load post');
  }
}

class Sub {
  String id;
  String title;
  String description;
  String channelId;
  String img;
  bool checked;


  Sub(this.id,
      this.title,
      this.description,
      this.channelId,
      this.img,
      this.checked
      );
}