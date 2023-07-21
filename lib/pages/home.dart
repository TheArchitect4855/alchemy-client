import 'package:alchemy/components/number_badge.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/edit_profile.dart';
import 'package:alchemy/pages/explore.dart';
import 'package:alchemy/pages/matches.dart';
import 'package:alchemy/pages/preferences.dart';
import 'package:alchemy/services/explore.dart';
import 'package:alchemy/services/location.dart';
import 'package:alchemy/services/match.dart';
import 'package:alchemy/services/requests.dart';
import 'package:alchemy/snackbar_util.dart';
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
  int _currentProfile = 0;
  int _numUnreadConversations = 0;

  @override
  void initState() {
    super.initState();
    _profilesFuture = ExploreService.instance.getPotentialMatches(
        LocationService.instance, RequestsService.instance);
    _profilesLastRefresh = DateTime.now();
    _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget currentView;
    switch (_currentIndex) {
      case 0:
        currentView = ExplorePage(
          profilesFuture: _profilesFuture,
          currentProfile: _currentProfile,
          popProfile: _onPopProfile,
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

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset('assets/icon-crop.png'),
        ),
        title: Text('alchemy',
            style: theme.textTheme.titleLarge!
                .apply(color: theme.colorScheme.primary)),
        actions: [
          IconButton(
            color: Colors.black38,
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PreferencesPage())),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: currentView,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
            activeIcon: Icon(Icons.explore),
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
            activeIcon: Icon(Icons.account_circle),
          ),
          BottomNavigationBarItem(
            icon: _numUnreadConversations > 0
                ? NumberBadge(
                    number: _numUnreadConversations,
                    child: const Icon(Icons.message_outlined))
                : const Icon(Icons.message_outlined),
            label: 'Messages',
            activeIcon: const Icon(Icons.message),
          ),
        ],
        onTap: (v) => setState(() {
          final elapsed = DateTime.now().difference(_profilesLastRefresh);
          if (elapsed.inMinutes > 5) _refreshProfiles();
          _currentIndex = v;
        }),
        currentIndex: _currentIndex,
        useLegacyColorScheme: false,
      ),
    );
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

  void _onPopProfile(Profile profile, bool isLiked) async {
    setState(() {
      _currentProfile += 1;
    });

    if (!isLiked) return;

    try {
      await ExploreService.instance
          .likeProfile(profile, RequestsService.instance);
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
