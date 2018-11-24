import 'package:YouAudio/theme.dart';
import 'package:flutter/material.dart';

class BottomControl extends StatelessWidget {
  const BottomControl({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
        width: double.infinity,
        child: new Material(
          color: accentColor,
          child:
            //@TODO add an seekbar
            new Padding(
            padding: const EdgeInsets.only(top:30.0,bottom: 40.0),
            child: new Column(
              children: <Widget>[
                new RichText(
                    text: new TextSpan(text: '', children: [
                      new TextSpan(
                        text: 'Video Title\n',
                        style: new TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4.0,
                            height: 1.5),
                      ),
                      new TextSpan(
                        text: 'Channel Name\n',
                        style: new TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3.0,
                            height: 1.5),
                      ),
                    ])),
                new Row(
                  children: <Widget>[
                    new Expanded(child: new Container()),

                    new PreviousButton(),

                    new Expanded(child: new Container()),
                    new PlayAndPauseButton(),

                    new Expanded(child: new Container()),

                    new NextButton(),

                    new Expanded(child: new Container()),

                  ],
                )
              ],
            ),
          ),
        )
    );
  }
}

class NextButton extends StatelessWidget {
  const NextButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new IconButton(
        splashColor: lightAccentColor,
        highlightColor: Colors.transparent,
        icon: new Icon(
            Icons.skip_next,
            color: Colors.white,
            size: 35.0
        ), onPressed: (){
      //@TODO fix
    });
  }
}

class PlayAndPauseButton extends StatelessWidget {
  const PlayAndPauseButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new RawMaterialButton(
      onPressed: (){
        // @Todo
      },
      shape: new CircleBorder(),
      fillColor: Colors.white,
      splashColor: lightAccentColor,
      highlightColor: lightAccentColor.withOpacity(0.5),
      elevation: 10.0,
      highlightElevation: 5.0,
      child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Icon(
              Icons.play_arrow,
              color: darkAccentColor,
              size: 35.0
          )
      ),
    );
  }
}

class PreviousButton extends StatelessWidget {
  const PreviousButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new IconButton(
        splashColor: lightAccentColor,
        highlightColor: Colors.transparent,
        icon: new Icon(
            Icons.skip_previous,
            color: Colors.white,
            size: 35.0
        ), onPressed: (){
      //@TODO fix
    });
  }
}
