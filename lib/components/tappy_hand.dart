import 'dart:async';

import 'package:flutter/material.dart';

class TappyHand extends StatefulWidget {
  final double size;

  const TappyHand({this.size = 64, super.key});

  @override
  State<StatefulWidget> createState() => _TappyHandState();
}

enum _TapState {
  up,
  down,
}

class _TappyHandState extends State<TappyHand> {
  late final Timer _tapTimer;
  _TapState _state = _TapState.up;

  @override
  void initState() {
    super.initState();
    _tapTimer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) => setState(() {
              switch (_state) {
                case _TapState.up:
                  _state = _TapState.down;
                  break;
                case _TapState.down:
                  _state = _TapState.up;
                  break;
              }
            }));
  }

  @override
  Widget build(BuildContext context) {
    String image;
    switch (_state) {
      case _TapState.down:
        image = 'assets/tutorial/hand-tap.png';
        break;
      case _TapState.up:
        image = 'assets/tutorial/hand-point.png';
        break;
    }

    return IgnorePointer(
      child: SizedBox(
        width: widget.size * 2,
        height: widget.size * 2,
        child: Image.asset(image),
      ),
    );
  }

  @override
  void dispose() {
    _tapTimer.cancel();
    super.dispose();
  }
}
