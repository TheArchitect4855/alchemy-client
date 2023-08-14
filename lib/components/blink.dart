import 'dart:async';
import 'package:flutter/material.dart';

class Blink extends StatefulWidget {
  final Duration interval;
  final Widget child;

  const Blink({required this.interval, required this.child, super.key});

  @override
  State<StatefulWidget> createState() => _BlinkState();
}

class _BlinkState extends State<Blink> {
  late final Timer _timer;
  bool _isVisible = true;
  Size? _childSize;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
        widget.interval,
        (_) => setState(() {
              _isVisible = !_isVisible;
            }));

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          _childSize = context.size;
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (_childSize == null) return widget.child;
    return SizedBox(
      width: _childSize!.width,
      height: _childSize!.height,
      child: _isVisible ? widget.child : null,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
