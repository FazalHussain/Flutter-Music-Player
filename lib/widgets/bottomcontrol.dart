import 'package:flutter/material.dart';
import 'package:flutter_app/theme/theme.dart';
import 'package:fluttery_audio/fluttery_audio.dart';

class BottomControls extends StatelessWidget {
  const BottomControls({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: double.infinity,
      child: Material(
        color: accentColor,
        shadowColor: const Color(0x44000000),
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0, bottom: 50.0),
          child: new Column(
            children: <Widget>[
              new MusicInformation(),
              // Controls
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: new Row(
                  children: <Widget>[
                    new Expanded(child: Container()),

                    new PreviousButton(),

                    new Expanded(child: Container()),

                    new PlayButton(),

                    new Expanded(child: Container()),

                    new NextButton(),

                    new Expanded(child: Container())

                  ],
                ),
              )
            ],
          ),
        ),
      ),
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
        icon: Icon(Icons.skip_next),
        color: Colors.white,
        iconSize: 35.0,
        onPressed: () {
          // Todo 3: Previus Button Press Event
        });
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AudioComponent(

      updateMe: [
        WatchableAudioProperties.audioPlayerState
      ],
      playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {

        IconData icon = Icons.play_arrow;
        Color buttonColor = lightAccentColor;
        Function onPressed;


        if (player.state == AudioPlayerState.playing) {
          icon = Icons.pause;
          onPressed = player.pause;
          buttonColor = Colors.white;
        } else if (player.state == AudioPlayerState.paused ||
        player.state == AudioPlayerState.completed) {
          icon = Icons.play_arrow;
          onPressed = player.play;
          buttonColor = Colors.white;
        }


        return new RawMaterialButton(
          shape: new CircleBorder(),
          fillColor: buttonColor,
          splashColor: accentColor,
          highlightColor: accentColor.withOpacity(0.5),
          elevation: 10.0,
          highlightElevation: 5.0,
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Icon(
              icon,
              color: darkAccentColor,
              size: 35.0,
            ),
          ),
        );
      },
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
        icon: Icon(Icons.skip_previous),
        color: Colors.white,
        iconSize: 35.0,
        onPressed: () {
          // Todo 3: Previus Button Press Event
        });
  }
}

class MusicInformation extends StatelessWidget {
  const MusicInformation({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: new TextSpan(text: '', children: [
        new TextSpan(
            text: "Song Title\n",
            style: new TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 4.0,
                height: 1.5)),
        new TextSpan(
            text: "Artist Name",
            style: new TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontSize: 12.0,
                letterSpacing: 3.0,
                height: 1.5))
      ]),
    );
  }
}