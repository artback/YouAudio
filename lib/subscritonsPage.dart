import 'package:YouAudio/channelPage.dart';
import 'package:flutter/material.dart';

class Subscriptions extends StatefulWidget {

  @override
  SubscriptionsState createState() {
    return new SubscriptionsState();
  }
}

class SubscriptionsState extends State<Subscriptions> {
  final List<Post> items = new List();
  @override
  void initState() {
    super.initState();
    setState(() {
      items.add(new Post(
        2,
        'Mychannel 1',
        'est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\n nqui aperiam non debitis possimus qui neque nisi nulla',
      ));
      items.add(new Post(
        3,
        'His channel 5',
        'et iusto sed quo iure\nvoluptatem occaecati omnis eligendi aut ad\nvoluptatem doloribus vel accusantium quis pariatur\nmolestiae porro eius odio et labore et velit aut',
      ));
      items.add(new Post(
        4,
        'His Channel 2543',
        'ullam et saepe reiciendis voluptatem adipisci\nsit amet autem assumenda provident rerum\n elit',
      ));
    });
  }
  @override
  Widget build(BuildContext context) {
    return new Container(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, position) {
            return ListTile(
                title: RichText(
                    text: new TextSpan(
                    text:'${items[position].title}',
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.black),
                    ),
                ),
                subtitle: Text('${items[position].body}'),
                trailing: new Checkbox(value: false, onChanged: null),
                onTap: () => Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) =>
                        new ChannelPage(items[position].id)
                ),
                ),
            );
          },
        )
    );
  }
}


class Post {
  final int id;
  final String title;
  final String body;

  Post(this.id, this.title, this.body);
}
