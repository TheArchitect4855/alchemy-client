import 'package:alchemy/components/floating_text.dart';
import 'package:alchemy/data/tutorial.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../components/blink.dart';

class TutorialProfilePage extends StatefulWidget {
  final TutorialData data;

  const TutorialProfilePage(this.data, {super.key});

  @override
  State<StatefulWidget> createState() => _TutorialProfilePageState();
}

class _TutorialProfilePageState extends State<TutorialProfilePage> {
  late final Ticker _animationTicker;
  final _backButtonKey = GlobalKey(debugLabel: 'Back Button Widget');
  var _backButtonPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animationTicker = Ticker((elapsed) {
      final backButtonPosition = (_backButtonKey.currentContext?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero);
      if (backButtonPosition != null) {
        setState(() {
          _backButtonPosition = backButtonPosition;
        });
      }
    });

    _animationTicker.start();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium!;
    return Stack(
      fit: StackFit.expand,
      children: [
        ProfilePage(
          widget.data.profile,
          currentPhoto: 0,
          isLiked: false,
          onLike: null,
          onPhotoChanged: (i) => Logger.info(runtimeType, 'ON PHOTO CHANGED: $i'),
          backButtonKey: _backButtonKey,
        ),
        Positioned(
          top: _backButtonPosition.dy - 2,
          left: _backButtonPosition.dx + 4,
          width: 40,
          height: 40,
          child: IgnorePointer(
            child: Blink(interval: const Duration(milliseconds: 500), child: Image.asset('assets/tutorial/flash.png')),
          ),
        ),
        Positioned(
          top: _backButtonPosition.dy - 12,
          left: 32,
          width: _backButtonPosition.dx + 64,
          child: FloatingText(widget.data.dialogue['info-2']!, style, TextAlign.right),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationTicker.dispose();
    super.dispose();
  }
}
