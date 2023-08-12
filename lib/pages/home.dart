import 'package:alchemy/components/home_scaffold.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/edit_profile.dart';
import 'package:alchemy/pages/explore.dart';
import 'package:alchemy/pages/matches.dart';
import 'package:alchemy/pages/preferences.dart';
import 'package:alchemy/services/explore.dart';
import 'package:alchemy/services/location.dart';
import 'package:alchemy/services/match.dart';
import 'package:alchemy/services/notifications.dart';
import 'package:alchemy/services/requests.dart';
import 'package:alchemy/snackbar_util.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:alchemy/data/match.dart';

const timeoutRetryCooldown = Duration(seconds: 30);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Profile>> _profilesFuture;
  late DateTime _profilesLastRefresh;
  late Future<List<Match>> _matchesFuture;
  int _currentIndex = 0;
  int _numUnreadConversations = 0;

  @override
  void initState() {
    super.initState();
    NotificationsService.instance.addOnMessageListener(_onMessage);
    NotificationsService.instance.addOnMessageOpenedAppListener(_onMessageOpenedApp);
    _profilesFuture = ExploreService.instance.getPotentialMatches(
        LocationService.instance, RequestsService.instance);
    _profilesLastRefresh = DateTime.now();
    _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentView;
    switch (_currentIndex) {
      case 0:
        currentView = ExplorePage(
          profilesFuture: _profilesFuture,
          onPopProfile: _onPopProfile,
        );
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
      onNavTapped: (v) => setState(() {
          final elapsed = DateTime.now().difference(_profilesLastRefresh);
          if (elapsed.inMinutes > 5) _refreshProfiles();
          _currentIndex = v;
      }),
      onSettingsPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PreferencesPage())),
    );
  }

  @override
  void dispose() {
    NotificationsService.instance.removeOnMessageListener(_onMessage);
    NotificationsService.instance.removeOnMessageOpenedAppListener(_onMessageOpenedApp);
    super.dispose();
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
      await Future.delayed(timeoutRetryCooldown);
      _loadMatches();
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

  void _refreshProfiles() async {
    Logger.info(runtimeType, 'Refreshing explore profiles');
    setState(() {
      _profilesLastRefresh = DateTime.now();
      _profilesFuture = ExploreService.instance.getPotentialMatches(
          LocationService.instance, RequestsService.instance);
    });
  }
}
