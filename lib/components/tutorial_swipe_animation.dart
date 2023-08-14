import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TutorialSwipeAnimation extends StatefulWidget {
  final BoxConstraints constraints;
  final EdgeInsets padding;

  const TutorialSwipeAnimation(this.constraints, {this.padding = EdgeInsets.zero, super.key});

  @override
  State<StatefulWidget> createState() => _TutorialSwipeAnimationState();
}

const _pointerHeight = 128.0;

class _TutorialSwipeAnimationState extends State<TutorialSwipeAnimation> {
  late final Ticker _animationTicker;
  var _offset = 0.0;
  var _resetTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _animationTicker = Ticker(_animationTick);
    _animationTicker.start();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.padding.left,
      right: widget.padding.right,
      top: _offset,
      child: IgnorePointer(
          child: Center(
        child: Image.asset('assets/tutorial/hand-tap.png', height: _pointerHeight),
      )),
    );
  }

  @override
  void dispose() {
    _animationTicker.dispose();
    super.dispose();
  }

  void _animationTick(Duration elapsed) {
    final t = (elapsed.inMilliseconds - _resetTime.inMilliseconds) / 1000.0;
    setState(() {
      _offset = lerpDouble(widget.constraints.maxHeight - widget.padding.bottom, widget.padding.top - _pointerHeight, t)!;
      if (t >= 1) _resetTime = elapsed;
    });
  }
}
