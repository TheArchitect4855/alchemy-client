import 'package:alchemy/components/profileview.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/data/profile_interaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../pages/profile.dart';
import '../services/auth.dart';
import 'noprofiles.dart';

const dragAnimationSpeed = 7;
const flyoutVelocityThreshold = 3;
const flyoutPositionThreshold = 0.5;

class ProfileStack extends StatefulWidget {
  final List<Profile> profiles;
  final void Function(Profile profile, Set<ProfileInteraction> interactions) onPopProfile;
  final Key? infoButtonKey;
  final Key? likeButtonKey;
  final bool Function(Set<ProfileInteraction>)? onInteract;
  final bool Function()? onPhotoChanged;
  final bool Function()? onPressDetails;

  const ProfileStack(
      {required this.profiles,
      required this.onPopProfile,
      this.onInteract,
      this.onPhotoChanged,
      this.onPressDetails,
      this.infoButtonKey,
      this.likeButtonKey,
      super.key});

  @override
  State<StatefulWidget> createState() => _ProfileStackState();
}

enum _ProfileAnimationState {
  none,
  dragging,
  flyout,
}

class _ProfileStackState extends State<ProfileStack> {
  late final Ticker _animationTicker;
  late int _lastTick;
  int _currentProfilePhoto = 0;
  Offset _dragOffset = Offset.zero;
  Velocity _flyoutVelocity = Velocity.zero;
  Set<ProfileInteraction> _currentProfileInteractions = {};
  _ProfileAnimationState _profileAnimationState = _ProfileAnimationState.none;

  @override
  void initState() {
    super.initState();
    _animationTicker = Ticker(_onAnimationTick);
    _lastTick = 0;

    _animationTicker.start();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profiles.isEmpty) {
      final profile = AuthService.instance.profile!;
      return NoProfiles(imageUrl: profile.photoUrls[0]);
    }

    Widget under;
    if (widget.profiles.length > 1) {
      under = ProfileView(
        widget.profiles[1],
        interactions: const {},
        currentPhoto: 0,
        onInteract: null,
        onPressDetails: null,
        onPhotoChanged: null,
      );
    } else {
      final profile = AuthService.instance.profile!;
      under = NoProfiles(imageUrl: profile.photoUrls[0]);
    }

    final profile = widget.profiles[0];
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
              profile,
              infoButtonKey: widget.infoButtonKey,
              likeButtonKey: widget.likeButtonKey,
              interactions: _currentProfileInteractions,
              currentPhoto: _currentProfilePhoto,
              onInteract: (v) {
                if (widget.onInteract != null && !widget.onInteract!(v)) return;
                setState(() {
                  _currentProfileInteractions = v;
                });
              },
              onPhotoChanged: _setPhoto,
              onPressDetails: () {
                if (widget.onPressDetails != null && !widget.onPressDetails!()) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // TODO: Update profile page
                    builder: (_) => ProfilePage(
                      profile,
                      isLiked: _currentProfileInteractions.contains(ProfileInteraction.kiss),
                      currentPhoto: _currentProfilePhoto,
                      onLike: (v) => setState(() {
                        if (v) {
                          _currentProfileInteractions.add(ProfileInteraction.kiss);
                        } else {
                          _currentProfileInteractions.remove(ProfileInteraction.kiss);
                        }
                      }),
                      onPhotoChanged: _setPhoto,
                    )));
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationTicker.dispose();
    super.dispose();
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
    widget.onPopProfile(widget.profiles[0], _currentProfileInteractions);
    setState(() {
      _currentProfilePhoto = 0;
      _currentProfileInteractions.clear();
      _dragOffset = Offset.zero;
      _flyoutVelocity = Velocity.zero;
      _profileAnimationState = _ProfileAnimationState.none;
    });
  }

  void _setPhoto(int photo) {
    if (widget.onPhotoChanged != null && !widget.onPhotoChanged!()) return;
    setState(() {
      _currentProfilePhoto = photo;
    });
  }
}
