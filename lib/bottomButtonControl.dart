import 'package:YouAudio/theme.dart';
import 'package:flutter/material.dart';

class BottomControl extends StatelessWidget {
  final VoidCallback _play;
  final VoidCallback _previous;
  final VoidCallback _next;
  const BottomControl(this._play, this._previous, this._next);

  @override
  Widget build(BuildContext context) {
    return new Container(
        width: double.infinity,
        child: new Material(
          color: accentColor,
          child:
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

                    new PreviousButton(_previous),

                    new Expanded(child: new Container()),
                    new PlayAndPauseButton(_play),

                    new Expanded(child: new Container()),

                    new NextButton(_next),

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
  final VoidCallback _onTap;
  const NextButton(this._onTap);
  @override
  Widget build(BuildContext context) {
    return new IconButton(
        splashColor: lightAccentColor,
        highlightColor: Colors.transparent,
        icon: new Icon(
            Icons.skip_next,
            color: Colors.white,
            size: 35.0
        ), onPressed: _onTap
    );
  }
}

class PlayAndPauseButton extends StatelessWidget {
  final VoidCallback _onTap;
  const PlayAndPauseButton(this._onTap);
  @override
  Widget build(BuildContext context) {
    return new RawMaterialButton(
      onPressed: _onTap ,
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
  final VoidCallback _onTap;
  PreviousButton(this._onTap);
  @override
  Widget build(BuildContext context) {
    return new IconButton(
        splashColor: lightAccentColor,
        highlightColor: Colors.transparent,
        icon: new Icon(
            Icons.skip_previous,
            color: Colors.white,
            size: 35.0
        ), onPressed: _onTap,
    );
  }
}
