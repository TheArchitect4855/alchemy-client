import 'package:alchemy/components/noprofiles.dart';
import 'package:alchemy/components/profileview.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/pages/profile.dart';
import 'package:alchemy/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const dragAnimationSpeed = 7;
const flyoutVelocityThreshold = 3;
const flyoutPositionThreshold = 0.5;

class ExplorePage extends StatefulWidget {
  final int currentProfile;
  final Future<List<Profile>> profilesFuture;
  final void Function(Profile profile, bool isLiked) popProfile;

  const ExplorePage({required this.currentProfile, required this.profilesFuture, required this.popProfile, super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

enum _ProfileAnimationState {
  none,
  dragging,
  flyout,
}

class _ExplorePageState extends State<ExplorePage> {
  late final Ticker _animationTicker;
  late int _lastTick;
  int _currentProfilePhoto = 0;
  bool _isCurrentProfileLiked = false;
  Offset _dragOffset = Offset.zero;
  Velocity _flyoutVelocity = Velocity.zero;
  _ProfileAnimationState _profileAnimationState = _ProfileAnimationState.none;
  Profile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _animationTicker = Ticker(_onAnimationTick);
    _lastTick = 0;

    _animationTicker.start();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: widget.profilesFuture,
    builder: (context, snapshot) {
      final theme = Theme.of(context);
      if (snapshot.hasData) {
        return _buildProfilesView(context, snapshot.data!);
      } else if (snapshot.hasError) {
        return Center(child: Column(children: [
          const Text('Error getting potential matches:', textAlign: TextAlign.center),
          Text(snapshot.error?.toString() ?? 'No further information', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium!.apply(color: theme.colorScheme.error)),
        ]));
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    },
  );

  @override
  void dispose() {
    _animationTicker.dispose();
    super.dispose();
  }

  Widget _buildProfilesView(BuildContext context, List<Profile> profiles) {
    if (widget.currentProfile >= profiles.length) {
      final profile = AuthService.instance.profile!;
      return NoProfiles(imageUrl: profile.photoUrls[0]);
    }

    Widget under;
    if (widget.currentProfile + 1 < profiles.length) {
      under = ProfileView(
        profiles[widget.currentProfile + 1],
        isLiked: false,
        currentPhoto: 0,
        onPressDetails: null,
        onLike: null,
        onPhotoChanged: null,
      );
    } else {
      final profile = AuthService.instance.profile!;
      under = NoProfiles(imageUrl: profile.photoUrls[0]);
    }

    _currentProfile = profiles[widget.currentProfile];
    return Stack(
      fit: StackFit.expand,
      children: [
        under,
        Positioned(
          left: _dragOffset.dx,
          right: -_dragOffset.dx,
          top: _dragOffset.dy,
          bottom: -_dragOffset.dy,
          child: GestureDetector(
            onVerticalDragStart: (_) => setState(() {
              _profileAnimationState = _ProfileAnimationState.dragging;
            }),
            onVerticalDragUpdate: (details) => setState(() {
              _dragOffset += details.delta;
            }),
            onVerticalDragEnd: (details) => setState(() {
              final screenSize = MediaQuery.of(context).size;
              final scaledVelocity = details.primaryVelocity! / screenSize.height;
              final scaledPosition = _dragOffset.dy / screenSize.height;
              if (scaledVelocity < -flyoutVelocityThreshold) {
                _profileAnimationState = _ProfileAnimationState.flyout;
                _flyoutVelocity = details.velocity;
              } else if (scaledPosition < -flyoutPositionThreshold) {
                _profileAnimationState = _ProfileAnimationState.flyout;
                _flyoutVelocity = Velocity(pixelsPerSecond: Offset(0, -flyoutVelocityThreshold * screenSize.height));
              } else {
                _profileAnimationState = _ProfileAnimationState.none;
              }
            }),
            onVerticalDragCancel: () => setState(() {
              _profileAnimationState = _ProfileAnimationState.none;
            }),
            child: ProfileView(
              _currentProfile!,
              isLiked: _isCurrentProfileLiked,
              currentPhoto: _currentProfilePhoto,
              onLike: (value) => setState(() {
                _isCurrentProfileLiked = value;
              }),
              onPhotoChanged: (value) => setState(() {
                _currentProfilePhoto = value;
              }),
              onPressDetails: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(
                _currentProfile!,
                isLiked: _isCurrentProfileLiked,
                currentPhoto: _currentProfilePhoto,
                onLike: (v) => setState(() {
                  _isCurrentProfileLiked = v;
                }),
                onPhotoChanged: (v) => setState(() {
                  _currentProfilePhoto = v;
                }),
              ))),
            ),
          ),
        ),
      ],
    );
  }

  void _onAnimationTick(Duration elapsed) {
    final dt = (elapsed.inMicroseconds - _lastTick) * 1e-6;
    if (_profileAnimationState == _ProfileAnimationState.none) {
      // Spring back to zero
      final v = _dragOffset.distance * dragAnimationSpeed * dt;
      var x = _dragOffset.dx - _dragOffset.dx.sign * v;
      if (x.abs() < v) x = 0;

      var y = _dragOffset.dy - _dragOffset.dy.sign * v;
      if (y.abs() < v) y = 0;

      setState(() {
        _lastTick = elapsed.inMicroseconds;
        _dragOffset = Offset(x, y);
      });
    } else if (_profileAnimationState == _ProfileAnimationState.flyout) {
      final screenSize = MediaQuery.of(context).size;
      if (_dragOffset.dy < -screenSize.height) {
        _popProfile();
      } else {
        setState(() {
          _dragOffset += _flyoutVelocity.pixelsPerSecond.scale(0, dt);
          _lastTick = elapsed.inMicroseconds;
        });
      }
    } else {
      setState(() {
        _lastTick = elapsed.inMicroseconds;
      });
    }
  }

  void _popProfile() {
    widget.popProfile(_currentProfile!, _isCurrentProfileLiked);
    setState(() {
      _currentProfilePhoto = 0;
      _isCurrentProfileLiked = false;
      _dragOffset = Offset.zero;
      _flyoutVelocity = Velocity.zero;
      _profileAnimationState = _ProfileAnimationState.none;
    });
  }
}
