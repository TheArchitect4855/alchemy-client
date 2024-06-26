import 'package:alchemy/components/blink.dart';
import 'package:alchemy/components/floating_text.dart';
import 'package:alchemy/components/home_scaffold.dart';
import 'package:alchemy/components/profile_interact_buttons.dart';
import 'package:alchemy/components/profilestack.dart';
import 'package:alchemy/components/tappy_hand.dart';
import 'package:alchemy/components/tutorial_swipe_animation.dart';
import 'package:alchemy/data/profile_interaction.dart';
import 'package:alchemy/data/tutorial.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/tutorial_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'init.dart';

const tutorialStatusKey = 'SHOWN_TUTORIAL_V2';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<StatefulWidget> createState() => _TutorialPageState();
}

enum _TutorialState {
  intro(_TutorialState.photos1),
  photos1(_TutorialState.photos2),
  photos2(_TutorialState.info1),
  info1(_TutorialState.info2),
  info2(_TutorialState.interact1),
  interact1(_TutorialState.interact2),
  interact2(_TutorialState.interact3),
  interact3(_TutorialState.interact4),
  interact4(_TutorialState.interact5),
  interact5(_TutorialState.like),
  like(_TutorialState.swipe),
  swipe(_TutorialState.outro),
  outro(null);

  const _TutorialState(this.next);
  final _TutorialState? next;
}

class _TutorialPageState extends State<TutorialPage> {
  late final Ticker _animationTicker;
  late final Future<TutorialData> _dataFuture;
  final _infoButtonKey = GlobalKey(debugLabel: 'Profile View Info Button');
  final _likeButtonKey = GlobalKey(debugLabel: 'Profile View Like Button');
  var _infoButtonPosition = Offset.zero;
  var _likeButtonPosition = Offset.zero;
  var _likeButtonSize = Size.zero;
  var _state = _TutorialState.intro;

  @override
  void initState() {
    super.initState();
    _animationTicker = Ticker((elapsed) {
      final infoButtonPosition = (_infoButtonKey.currentContext?.findRenderObject() as RenderBox?)?.localToGlobal(Offset.zero);

      final likeButtonBox = _likeButtonKey.currentContext?.findRenderObject() as RenderBox?;
      final likeButtonPosition = likeButtonBox?.localToGlobal(Offset.zero);
      if (infoButtonPosition != null || likeButtonPosition != null) {
        setState(() {
          _infoButtonPosition = infoButtonPosition ?? _infoButtonPosition;
          _likeButtonPosition = likeButtonPosition ?? _likeButtonPosition;
          _likeButtonSize = likeButtonBox?.size ?? _likeButtonSize;
        });
      }
    });

    _dataFuture = TutorialData.load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LayoutBuilder(builder: (context, constraints) => _buildTutorial(context, constraints, snapshot.data!));
        } else if (snapshot.hasError) {
          return Padding(
              padding: const EdgeInsets.all(16), child: Text('Error: ${snapshot.error}', style: theme.textTheme.bodyMedium!.apply(color: Colors.red)));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildTutorial(BuildContext context, BoxConstraints constraints, TutorialData data) {
    final theme = Theme.of(context);
    final home = HomeScaffold(
      onWillPop: () async => false,
      body: ProfileStack(
        infoButtonKey: _infoButtonKey,
        likeButtonKey: _likeButtonKey,
        profiles: [data.profile],
        onRefresh: null,
        onPopProfile: (profile, interactions) => _nextState(),
        onInteract: (v) {
          if (_state == _TutorialState.like && v.isNotEmpty) {
            _nextState();
            return true;
          } else {
            return false;
          }
        },
        onPhotoChanged: () {
          if (_state == _TutorialState.photos1 || _state == _TutorialState.photos2) {
            _nextState();
            return true;
          } else {
            return false;
          }
        },
        onPressDetails: () {
          if (_state == _TutorialState.info1) {
            _nextState();
          }

          return false;
        },
      ),
      currentIndex: 0,
      messageNotificationBadge: 0,
      onNavTapped: null,
      onSettingsPressed: null,
    );

    final style = theme.textTheme.bodyLarge!.apply(color: Colors.white);
    final List<Widget> stack;
    switch (_state) {
      case _TutorialState.intro:
        stack = [
          home,
          _uiBlocker(data.dialogue['intro']!, style),
        ];
        break;
      case _TutorialState.photos1:
        stack = [
          home,
          _tappyText(data.dialogue['photos-1']!, style, constraints, CrossAxisAlignment.end, right: 32, bottom: 256),
        ];
        break;
      case _TutorialState.photos2:
        stack = [
          home,
          _tappyText(data.dialogue['photos-2']!, style, constraints, CrossAxisAlignment.start, left: 32, bottom: 256),
        ];
        break;
      case _TutorialState.info1:
        stack = [
          home,
          Positioned(
              top: _infoButtonPosition.dy - 2,
              left: _infoButtonPosition.dx + 4,
              width: 40,
              height: 40,
              child: IgnorePointer(
                child: Blink(interval: const Duration(milliseconds: 500), child: Image.asset('assets/tutorial/flash.png')),
              )),
          Positioned(
            bottom: constraints.maxHeight - _infoButtonPosition.dy,
            left: 16,
            width: _infoButtonPosition.dx * 2,
            child: FloatingText(data.dialogue['info-1']!, style, TextAlign.center),
          )
        ];
      case _TutorialState.info2:
        stack = [home];
        break;
      case _TutorialState.interact1:
        stack = _profileInteractStage(constraints, style, home, data, 'interact-1', null);
        break;
      case _TutorialState.interact2:
        stack = _profileInteractStage(constraints, style, home, data, 'interact-2', 0);
        break;
      case _TutorialState.interact3:
        stack = _profileInteractStage(constraints, style, home, data, 'interact-3', 1);
      case _TutorialState.interact4:
        stack = _profileInteractStage(constraints, style, home, data, 'interact-4', 2);
      case _TutorialState.interact5:
        stack = _profileInteractStage(constraints, style, home, data, 'interact-5', null);
        break;
      case _TutorialState.like:
        stack = [
          home,
          Positioned(
            left: _likeButtonPosition.dx + 16,
            top: _likeButtonPosition.dy + 16,
            child: const TappyHand(size: 32),
          ),
          Positioned(
            bottom: constraints.maxHeight - _likeButtonPosition.dy,
            right: 32,
            width: _likeButtonPosition.dx,
            child: FloatingText(data.dialogue['like']!, style, TextAlign.right),
          ),
        ];
        break;
      case _TutorialState.swipe:
        stack = [
          home,
          Positioned(
            top: 256,
            bottom: 256,
            left: 16,
            right: 16,
            child: Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/tutorial/up-arrow.png'),
                FloatingText(data.dialogue['swipe']!, style, TextAlign.center),
              ],
            )),
          ),
          TutorialSwipeAnimation(constraints, padding: const EdgeInsets.symmetric(vertical: 256, horizontal: 16)),
        ];
        break;
      case _TutorialState.outro:
        stack = [
          home,
          _uiBlocker(data.dialogue['outro']!, style),
        ];
        break;
      default:
        throw UnimplementedError();
    }

    return Stack(
      fit: StackFit.expand,
      children: stack,
    );
  }

  @override
  void dispose() {
    _animationTicker.dispose();
    super.dispose();
  }

  Widget _uiBlocker(String text, TextStyle style) => Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: GestureDetector(
          onTap: _nextState,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            color: const Color(0xbf000000),
            child: Text(text, textAlign: TextAlign.center, style: style.apply(color: Colors.white)),
          ),
        ),
      );

  TextAlign _getAlignment(double? left, double? right, double? top, double? bottom) {
    if (left != null && right != null) {
      return TextAlign.center;
    } else if (left != null) {
      return TextAlign.left;
    } else if (right != null) {
      return TextAlign.right;
    } else {
      return TextAlign.center;
    }
  }

  void _nextState() {
    if (_state.next == null) {
      SharedPreferences.getInstance().then((v) => v.setBool(tutorialStatusKey, true));
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const InitPage()), (_) => false);
    }

    setState(() {
      _state = _state.next!;
      if (_state == _TutorialState.info1 && !_animationTicker.isActive) {
        _animationTicker.start();
      } else if (_state != _TutorialState.info1 && _animationTicker.isActive) {
        _animationTicker.stop();
      }

      if (_state == _TutorialState.info2) _showTutorialProfile();
    });
  }

  List<Widget> _profileInteractStage(
    BoxConstraints constraints,
    TextStyle floatingTextStyle,
    Widget home,
    TutorialData data,
    String dialogueKey,
    int? index
  ) {
    return [
      home,
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: ColoredBox(
          color: Colors.black54,
          child: GestureDetector(onTap: () => _nextState()),
        ),
      ),
      Positioned(
        left: _likeButtonPosition.dx,
        top: _likeButtonPosition.dy,
        width: _likeButtonSize.width,
        height: _likeButtonSize.height,
        child: ProfileInteractButtons(
          profile: data.profile,
          interactions: index == null ? const {} : { ProfileInteraction.values[index] },
          onInteract: null,
        ),
      ),
      // Positioned(
      //   left: _likeButtonPosition.dx,
      //   top: _likeButtonPosition.dy,
      //   width: _likeButtonSize.width,
      //   height: _likeButtonSize.height,
      //   child: DecoratedBox(decoration: BoxDecoration(
      //     border: Border.all(color: Colors.white, width: 2),
      //     borderRadius: BorderRadius.circular(4),
      //   )),
      // ),
      Positioned(
        left: _likeButtonPosition.dx - _likeButtonSize.width / 2,
        bottom: constraints.maxHeight - _likeButtonPosition.dy + 4,
        width: _likeButtonSize.width * 1.5,
        child: FloatingText(data.dialogue[dialogueKey]!, floatingTextStyle, TextAlign.right),
      ),
    ];
  }

  void _showTutorialProfile() async {
    final data = await _dataFuture;
    if (mounted) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => TutorialProfilePage(data)));
      _nextState();
    } else {
      Logger.error(runtimeType, 'WIDGET WAS UNMOUNTED');
    }
  }

  Widget _tappyText(String text, TextStyle baseStyle, BoxConstraints constraints, CrossAxisAlignment crossAxisAlignment,
      {double? left, double? right, double? top, double? bottom}) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: ConstrainedBox(
        constraints: constraints.deflate(EdgeInsets.fromLTRB((left ?? 0) * 2, (top ?? 0) * 2, (right ?? 0) * 2, (bottom ?? 0) * 2).flipped).loosen(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            const TappyHand(),
            FloatingText(text, baseStyle, _getAlignment(left, right, top, bottom)),
          ],
        ),
      ),
    );
  }
}
