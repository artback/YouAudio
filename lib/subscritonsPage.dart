import 'package:YouAudio/channelPage.dart';
import 'package:flutter/material.dart';


import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

var channelID = "UCo2fdNt0ix-2JT06o_RmqCQ";
var apiKey    = "AIzaSyBKdwbjbsGdHyNPS0q3J6cffOsUSfiqCx4";
var subApi    = "https://www.googleapis.com/youtube/v3/subscriptions?part=snippet&channelId=${channelID}&maxResults=20&key=${apiKey}";



class SubscriptionsPage extends StatefulWidget {

  @override
  SubscriptionsPageState createState() {
    return new SubscriptionsPageState();
  }

}



class SubscriptionsPageState extends State<SubscriptionsPage> {
  Future<List> subscribers;


  @override
  void initState() {
    super.initState();
    subscribers = getData(subApi);
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: FutureBuilder<List>(
          future: subscribers,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List content = snapshot.data;

              return  new ListView.builder(
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
                       onChanged: (bool value) {
                         // add to change in save file on removed/added subs
                         setState(() {
                           content[index].checked = value;
                         });
                       }
                     ),
                   );
                  }
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



//testing http
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


    //Just for debugging
    for(var x in items) {
      print(x.title);
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