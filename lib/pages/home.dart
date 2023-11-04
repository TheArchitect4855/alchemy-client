import 'package:alchemy/components/home_scaffold.dart';
import 'package:alchemy/components/profilestack.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/edit_profile.dart';
import 'package:alchemy/pages/matches.dart';
import 'package:alchemy/pages/noconnection.dart';
import 'package:alchemy/pages/preferences.dart';
import 'package:alchemy/routing.dart';
import 'package:alchemy/services/explore.dart';
import 'package:alchemy/services/match.dart';
import 'package:alchemy/services/notifications.dart';
import 'package:alchemy/services/requests.dart';
import 'package:alchemy/snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:alchemy/data/match.dart';
import '../services/location.dart';

const _matchLoadMaxRetries = 3;
const _timeoutRetryCooldown = Duration(seconds: 10);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final FcmNotificationsService? _notificationsService;
  late Future<List<Match>> _matchesFuture;
  final List<int> _history = [];
  int _currentIndex = 0;
  List<Profile>? _exploreProfiles;
  int _exploreProfileIndex = 0;
  int _numUnreadConversations = 0;
  int _matchLoadRetryCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (NotificationsService.instance is FcmNotificationsService) {
      _notificationsService =
          NotificationsService.instance as FcmNotificationsService;
    } else {
      _notificationsService = null;
    }

    _notificationsService?.addOnMessageListener(_onMessage);
    _notificationsService?.addOnMessageOpenedAppListener(_onMessageOpenedApp);
    _updateExploreProfiles();
    _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentView;
    switch (_currentIndex) {
      case 0:
        if (_exploreProfiles == null) {
          currentView = const Center(child: CircularProgressIndicator());
        } else {
          currentView = ProfileStack(
            profiles: _exploreProfiles!.sublist(_exploreProfileIndex),
            onPopProfile: _onPopProfile,
            onRefresh: _exploreProfiles!.isEmpty ? null : () => setState(() {
              _exploreProfileIndex = 0;
            }),
          );
        }

        break;
      case 1:
        currentView = const EditProfilePage();
        break;
      case 2:
        currentView = MatchesPage(
          _matchesFuture,
          onUpdate: _loadMatches,
        );
        break;
      default:
        throw UnimplementedError();
    }

    return HomeScaffold(
      body: currentView,
      currentIndex: _currentIndex,
      messageNotificationBadge: _numUnreadConversations,
      onNavTapped: (v) {
        _history.add(_currentIndex);
        _setNav(v);
      },
      onSettingsPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PreferencesPage()))
          .then((v) => _updateExploreProfiles()),
      onWillPop: () async {
        if (_history.isEmpty) return true;

        final last = _history.removeLast();
        _setNav(last);
        return false;
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationsService?.removeOnMessageListener(_onMessage);
    _notificationsService
        ?.removeOnMessageOpenedAppListener(_onMessageOpenedApp);
    super.dispose();
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _updateExploreProfiles();
  }

  void _loadMatches() async {
    try {
      _matchesFuture =
          MatchService.instance.getMatches(RequestsService.instance);

      final matches = await _matchesFuture;
      setState(() {
        _numUnreadConversations = matches.fold(0, (p, e) {
          if (e.numUnread > 0) return p + 1;
          return p;
        });
      });
    } on RequestsServiceHttpException catch (e) {
      Logger.exception(runtimeType, e);
    } on RequestsServiceException catch (e) {
      Logger.warnException(runtimeType, e);

      // If there was a client exception, wait a bit and try again
      if (_matchLoadRetryCount < _matchLoadMaxRetries) {
        _matchLoadRetryCount += 1;
        await Future.delayed(_timeoutRetryCooldown);
        _loadMatches();
      } else if (mounted) {
        replaceRoute(context, const NoConnectionPage());
      } else {
        Logger.error(runtimeType, 'Context was unmounted while handling network error: $e');
      }
    } on Exception catch (e) {
      Logger.exception(runtimeType, e);
    }
  }

  void _onMessage(RemoteMessage message) {
    if (message.data['kind'] == 'match-message') {
      _loadMatches();
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    Logger.debug(runtimeType, 'on message opened app: ${message.data}');
    if (message.data['kind'] == 'match-message') {
      _loadMatches();
      setState(() {
        _currentIndex = 2;
      });
    }
  }

  void _onPopProfile(Profile profile, bool isLiked) async {
    setState(() {
      _exploreProfileIndex += 1;
    });

    if (!isLiked) return;

    try {
      final match = await ExploreService.instance
          .likeProfile(profile, RequestsService.instance);

      if (match != null) {
        _matchesFuture.then((value) => setState(() {
              value.add(match);
              _numUnreadConversations += 1;
            }));
      }
    } on Exception catch (e) {
      Logger.warnException(runtimeType, e);
      textSnackbar(context, 'Error liking profile');
    }
  }

  void _setNav(int index) {
    setState(() {
      if (index == 0) _updateExploreProfiles();
      _currentIndex = index;
    });
  }

  void _updateExploreProfiles() {
    _exploreProfiles = ExploreService.instance
        .getPotentialMatches(LocationService.instance, RequestsService.instance,
            onChanged: (profiles) => setState(() {
                  _exploreProfiles = profiles;
                  _exploreProfileIndex = 0;
                }));
  }
}
