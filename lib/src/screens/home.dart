import 'dart:math';

import 'package:flutter/material.dart';

import '../songs.dart';
import '../theme.dart';
import '../widgets/bottom_controls.dart';
import '../widgets/radial_drag_gesture_detector.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(''),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
          color: const Color(
            0xffdddddd,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
            color: const Color(
              0xffdddddd,
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Seek bar
          Expanded(
            child: RadialSeekBar(),
          ),

          // Visualizer
          Container(
            width: double.infinity,
            height: 125.0,
          ),

          // Song title, artist name, and controls
          new BottomControls()
        ],
      ),
    );
  }
}

class RadialSeekBar extends StatefulWidget {
  final double seekPercent;

  RadialSeekBar({this.seekPercent = 0.0});

  @override
  _RadialSeekBarState createState() {
    return new _RadialSeekBarState();
  }
}

class _RadialSeekBarState extends State<RadialSeekBar> {
  double _seekPercent = 0.11;
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _currentDragPercent;

  @override
  void initState() {
    super.initState();
    _seekPercent = widget.seekPercent;
  }

  @override
  void didUpdateWidget(RadialSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _seekPercent = widget.seekPercent;
  }

  void _onDragStart(PolarCoord coord) {
    _startDragCoord = coord;
    _startDragPercent = _seekPercent;
  }

  void _onDragUpdate(PolarCoord coord) {
    final dragAngle = coord.angle - _startDragCoord.angle;
    final dragPercent = dragAngle / (2 * pi);

    setState(() {
      _currentDragPercent = (_startDragPercent + dragPercent) % 1.0;
    });
  }

  void _onDragEnd() {
    setState(() {
      _seekPercent = _currentDragPercent;
      _currentDragPercent = null;
      _startDragCoord = null;
      _startDragPercent = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RadialDragGestureDetector(
      onRadialDragStart: _onDragStart,
      onRadialDragUpdate: _onDragUpdate,
      onRadialDragEnd: _onDragEnd,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 140.0,
            height: 140.0,
            child: RadialProgressBar(
              trackColor: const Color(0xffdddddd),
              progressPercent: _currentDragPercent ?? _seekPercent,
              progressColor: accentColor,
              thumbPosition: _currentDragPercent ?? _seekPercent,
              thumbColor: lightAccentColor,
              innerPadding: const EdgeInsets.all(10.0),
              child: ClipOval(
                clipper: CircleClipper(),
                child: Image.network(
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
  final double trackWidth;
  final Color trackColor;
  final double progressWidth;
  final Color progressColor;
  final double progressPercent;
  final double thumbSize;
  final Color thumbColor;
  final double thumbPosition;
  final EdgeInsets outerPadding;
  final EdgeInsets innerPadding;
  final Widget child;

  RadialProgressBar(
      {this.trackWidth = 3.0,
      this.trackColor = Colors.grey,
      this.progressWidth = 5.0,
      this.progressPercent = 0.0,
      this.progressColor = Colors.black,
      this.thumbSize = 10.0,
      this.thumbColor = Colors.black,
      this.thumbPosition = 0.0,
      this.outerPadding = const EdgeInsets.all(0.0),
      this.innerPadding = const EdgeInsets.all(0.0),
      this.child});

  @override
  _RadialProgressBarState createState() => _RadialProgressBarState();
}

class _RadialProgressBarState extends State<RadialProgressBar> {
  EdgeInsets _insetsForPainter() {
    final outerThickness = max(
          widget.trackWidth,
          max(
            widget.progressWidth,
            widget.thumbSize,
          ),
        ) /
        2.0;
    return EdgeInsets.all(outerThickness);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.outerPadding,
      child: CustomPaint(
        foregroundPainter: RadialSeekBarPainter(
          trackWidth: widget.trackWidth,
          trackColor: widget.trackColor,
          progressWidth: widget.progressWidth,
          progressColor: widget.progressColor,
          progressPercent: widget.progressPercent,
          thumbSize: widget.thumbSize,
          thumbColor: widget.thumbColor,
          thumbPosition: widget.thumbPosition,
        ),
        child: Padding(
          padding: _insetsForPainter() + widget.innerPadding,
          child: widget.child,
        ),
      ),
    );
  }
}

class RadialSeekBarPainter extends CustomPainter {
  final double trackWidth;
  final Paint trackPaint;
  final double progressWidth;
  final double progressPercent;
  final Paint progressPaint;
  final double thumbSize;
  final Paint thumbPaint;
  final double thumbPosition;

  RadialSeekBarPainter(
      {@required this.trackWidth,
      @required trackColor,
      @required this.progressWidth,
      @required progressColor,
      @required this.progressPercent,
      @required this.thumbSize,
      @required thumbColor,
      @required this.thumbPosition})
      : trackPaint = Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackWidth,
        progressPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = progressWidth
          ..strokeCap = StrokeCap.round,
        thumbPaint = Paint()
          ..color = thumbColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final outerThinkness = max(trackWidth, max(progressWidth, thumbSize));
    final constrainedSize = Size(
      size.width - outerThinkness,
      size.height - outerThinkness,
    );

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(constrainedSize.width, constrainedSize.height) / 2;

    // Paint track
    canvas.drawCircle(center, radius, trackPaint);

    // Paint progress
    final progressAngle = 2 * pi * progressPercent;
    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -pi / 2,
      progressAngle,
      false,
      progressPaint,
    );

    // Paint thumb
    final thumbAngle = 2 * pi * thumbPosition - (pi / 2);
    final thumbX = cos(thumbAngle) * radius;
    final thumbY = sin(thumbAngle) * radius;
    final thumbCenter = Offset(thumbX, thumbY) + center;
    final thumbRadius = thumbSize / 2.0;
    canvas.drawCircle(thumbCenter, thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
