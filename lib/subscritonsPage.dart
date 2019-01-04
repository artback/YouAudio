import 'package:YouAudio/channelPage.dart';

import 'package:YouAudio/dataModel/subscribtions.dart';
import 'package:YouAudio/jsonSubsribtions.dart';import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:YouAudio/main.dart';

//my own ChannelId and apiKey  find out your own if you wanna try
//login implementation should give ous a way to access a users ChannelId and apiKey
var channelID = "UCo2t0ix-2JT06o_RmqCQ";
var apiKey = "AIzaSyBKdwbjbsGdHyNPS0q3J6cffOsUSfiqCx4";
var subApi =
    "https://www.googleapis.com/youtube/v3/subscriptions?part=snippet&channelId=$channelID&maxResults=20&key=$apiKey";

//variables for writing/reading from file

class SubscriptionsPage extends StatefulWidget {
  @override
  SubscriptionsPageState createState() {
    return new SubscriptionsPageState();
  }
}

class SubscriptionsPageState extends State<SubscriptionsPage> {
  List<Sub> mySubs = new List();


  //give decoded json string and it will write that to file
  @override
  void initState() {
    super.initState();
    //@TODO save data to the array
    getData(subApi);
  }
  _getSubs(){
      getSubscribtionsFromFile().then((value) {
        if(this.mounted) {
          setState(() {
            mySubs = value;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    _getSubs();
    return new Container(
                  child:
                  new Scaffold(
                  body: new ListView.builder(
                          itemCount: mySubs != null ? mySubs.length : 0  ,
                          itemBuilder: (BuildContext context, int index) {
                            return Slidable(
                             delegate: new SlidableDrawerDelegate(),
                             actionExtentRatio: 0.2,
                            child: ListTile(
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
                                    writeToFile(mySubs);
                                  }),
                              onTap: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) =>  new MyTabs(new ChannelPage(mySubs[index].channelId),1))
                                );
                              },
                            ),
                            actions: <Widget>[
                            new IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red.shade900,
                            icon: Icons.delete,
                            onTap: () =>  delete(index),
                            ),
                            ],
                            );
                          }),
    )
    );
  }

  delete(position) {
    deleteFromFile(mySubs[position]);
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
          x["snippet"]["title"],
          x["snippet"]["resourceId"]["channelId"],
          x["snippet"]["thumbnails"]["default"]["url"],
          false,
          x["snippet"]["description"]
      ));
    }

  }
  return items;
}

