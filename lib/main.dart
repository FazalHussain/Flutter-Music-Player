import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/circleclipper.dart';
import 'package:flutter_app/models/songs.dart';
import 'package:flutter_app/theme/theme.dart';
import 'package:flutter_app/widgets/bottomcontrol.dart';
import 'package:fluttery/gestures.dart';
import 'package:fluttery_audio/fluttery_audio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  double _seekPercent;

  @override
  Widget build(BuildContext context) {
    return Audio(
      audioUrl: demoPlaylist.songs[0].audioUrl,
      playbackState: PlaybackState.paused,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          //leading is used to customize toolbar
          leading: new IconButton(
              icon: new Icon(Icons.arrow_back),
              color: const Color(0XFFDDDDDD),
              onPressed: () {
                //Todo 1: Back on Press
              }),

          title: Text(''),
          //Action is used to place list of widget right side of toolbar
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.menu),
                color: const Color(0XFFDDDDDD),
                onPressed: () {
                  //Todo 2: Menu on Press
                }),
          ],
        ),
        body: new Column(
          children: <Widget>[
            //seekbar

            new Expanded(
              child: AudioComponent(
                updateMe: [
                  WatchableAudioProperties.audioPlayhead,
                  WatchableAudioProperties.audioSeeking
                ],
                playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {
                  double playbackProgress = 0.0;
                  if (player.audioLength != null && player.position != null) {
                    playbackProgress = player.position.inMilliseconds /
                        player.audioLength.inMilliseconds;
                  }

                  _seekPercent = player.isSeeking ? _seekPercent : null;
                  return new RadialGestureDetector(
                      progress: playbackProgress,
                      seekBarPercent: _seekPercent,
                      onSeekRequested: (double seekPercent) {
                        setState(() {
                          _seekPercent = seekPercent;
                        });

                        final seekMilis = (player.audioLength.inMilliseconds * seekPercent).round();
                        player.seek(new Duration(microseconds: seekMilis));
                      },
                  );
                },
                  child: RadialGestureDetector()
              )
            ),

            // visualizer
            new Container(
              width: double.infinity, // occupy the full width
              height: 125.0,
            ),
            //controls, music name and artist name UI
            new BottomControls()
          ],
        ),
      ),
    );
  }
}

class RadialGestureDetector extends StatefulWidget {

   double seekBarPercent;
   double progress;
   Function(double) onSeekRequested;

   RadialGestureDetector({
     this.progress = 0.0,
     this.seekBarPercent = 0.0,
     this.onSeekRequested
   });

  @override
  _RadialGestureDetectorState createState() => _RadialGestureDetectorState();
}

class _RadialGestureDetectorState extends State<RadialGestureDetector> {

  double _progress = 0.0;
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _currentDragPercent;


  /// The framework will call this method exactly once for each [State] object
  /// it creates.
  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
  }


  /// Called whenever the widget configuration changes
  @override
  void didUpdateWidget(RadialGestureDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _progress = widget.progress;
  }

  _onDragStart(PolarCoord startCoord) {
    // Save the start drag coordinate & percentage in variable
    _startDragCoord = startCoord;
    _startDragPercent = _progress;

  }

  _onDragUpdate(PolarCoord updateCoord) {
    //Calculate the drag angle
    final dragAngle = updateCoord.angle - _startDragCoord.angle;
    //calculate the drag percent by dividing the drag
    // angle with the radion in the circle i.e 2 * pi
    final dragPercent = dragAngle / (2 * pi);

    // set the state to update current drag percent and mod
    // it by 1.0 so the percent will not be more than 100

    setState(() =>_currentDragPercent = (_startDragPercent + dragPercent) % 1.0);

  }

  _onDragEnd() {

    if (widget.onSeekRequested != null) {
      widget.onSeekRequested(_currentDragPercent);
    }

    setState(() {
      _currentDragPercent = null;
      _startDragCoord = null;
      _startDragPercent = 0.0;

    });
  }

  @override
  Widget build(BuildContext context) {

    double thumbPosition = _progress;

    if (_currentDragPercent != null) {
      thumbPosition = _currentDragPercent;
    } else if (widget.seekBarPercent != null) {
      thumbPosition = widget.seekBarPercent;
    }

    // TODO: implement build
    return new RadialDragGestureDetector(
      onRadialDragStart: _onDragStart,
      onRadialDragUpdate: _onDragUpdate,
      onRadialDragEnd: _onDragEnd,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Center(
          child: new Container(
            width: 140.0,
            height: 140.0,
            child: new RadialProgressBar(
              trackColor: const Color(0xFFDDDDDD),
              progressColor: accentColor,
              progressPercent: _progress,
              thumbPosition: thumbPosition,
              thumbColor: lightAccentColor,
              innerPadding: EdgeInsets.all(10.0),
              child: ClipOval(
                clipper: new CircleClipper(),
                child: new Image.network(
                  demoPlaylist.songs[0].albumArtUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class RadialProgressBar extends StatefulWidget {
  double trackWidth;
  Color trackColor;
  double progressWidth;
  Color progressColor;
  double progressPercent;
  double thumbSize;
  Color thumbColor;
  double thumbPosition;
  EdgeInsets innerPadding;
  EdgeInsets outerPadding;
  Widget child;

  RadialProgressBar(
      {this.trackWidth = 3.0,
      this.trackColor = Colors.grey,
      this.progressWidth = 5.0,
      this.progressPercent = 0.0,
      this.progressColor = Colors.black,
      this.thumbSize = 10.0,
      this.thumbColor = Colors.black,
      this.thumbPosition = 0.0,
      this.innerPadding = const EdgeInsets.all(0.0),
      this.outerPadding = const EdgeInsets.all(0.0),
      this.child});

  @override
  State<StatefulWidget> createState() => _RadialProgressbarState();
}

class _RadialProgressbarState extends State<RadialProgressBar> {

  EdgeInsets _insetForPainter() {
    // Make room for the painted track, progress, and thumb. We divide by 2.0
    // because we want to flush painting against the track
    final outerThickness = max(widget.trackWidth,
        max(widget.progressWidth, widget.thumbSize));
    return EdgeInsets.all(outerThickness);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: widget.outerPadding,
      child: new CustomPaint(
        foregroundPainter: new RadialSeekbarPainter(
          trackWidth: widget.trackWidth,
          trackColor: widget.trackColor,
          progressWidth: widget.progressWidth,
          progressColor: widget.progressColor,
          progressPercent: widget.progressPercent,
          thumbColor: widget.thumbColor,
          thumbSize: widget.thumbSize,
          thumbPosition: widget.thumbPosition,
        ),
        child: Padding(
          padding: _insetForPainter() + widget.innerPadding,
          child: widget.child,
        ),
      ),
    );
  }
}



class RadialSeekbarPainter extends CustomPainter {
  double trackWidth;
  Paint trackPaint;
  double progressWidth;
  double progressPercent;
  Paint progressPaint;
  double thumbSize;
  double thumbPosition;
  Paint thumbPaint;

  /*
   * Constructor
   * .. is used to return the paint object in the same line after applying properties
   */
  RadialSeekbarPainter(
      {@required this.trackWidth,
      @required trackColor,
      @required this.progressWidth,
      @required this.progressPercent,
      @required progressColor,
      @required this.thumbSize,
      @required thumbColor,
      @required this.thumbPosition})
      : trackPaint = new Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackWidth,
        progressPaint = new Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = progressWidth
          ..strokeCap = StrokeCap.round,
        thumbPaint = new Paint()
          ..color = thumbColor
          ..style = PaintingStyle.fill
          ..strokeWidth = trackWidth;

  @override
  void paint(Canvas canvas, Size size) {

    final outerThickness = max(trackWidth, max(progressWidth, thumbSize));
    Size constraintSize = new Size(
      size.width - outerThickness,
      size.height - outerThickness
    );

    //track paint
    final center = new Offset(size.width / 2, size.height / 2);
    final radius = min(constraintSize.width, constraintSize.height) / 2;
    canvas.drawCircle(center, radius, trackPaint);

    //progress paint

    double startAngle =
        -pi / 2; // At the top of the circle the angle would be negative pi / 2
    double progressAngle = pi * 2 * progressPercent;
    canvas.drawArc(new Rect.fromCircle(
        center: center,
        radius: radius
    ),
        startAngle,
        progressAngle,
        false,
        progressPaint
    );

    //Thumb paint.
    final double thumbAngle = 2 * pi * thumbPosition - (pi / 2);
    final double thumbX = cos(thumbAngle) * radius;
    final double thumbY = sin(thumbAngle) * radius;
    final thumbCenter = new Offset(thumbX, thumbY) + center;
    final double thumbRadius = thumbSize / 2.0;
    canvas.drawCircle(thumbCenter, thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
