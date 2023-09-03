import 'package:alchemy/data/match.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/services/location.dart';
import 'package:alchemy/services/requests.dart';

class ExploreService {
  static final ExploreService instance = ExploreService();

  List<Profile>? _potentialMatches;
  DateTime? _potentialMatchesTs;
  bool _isLoading = false;

  List<Profile>? getPotentialMatches(
    LocationService location,
    RequestsService requests, {
    void Function(List<Profile> profiles)? onChanged,
  }) {
    Logger.debug(runtimeType, 'Getting potential matches...');
    final shouldRefresh = _potentialMatches == null ||
        DateTime.now().difference(_potentialMatchesTs!).inMinutes >= 5;
    if (shouldRefresh && !_isLoading) {
      _isLoading = true;
      _refreshPotentialMatches(location, requests, onChanged);
    }

    return _potentialMatches;
  }

  Future<Match?> likeProfile(Profile profile, RequestsService requests) async {
    final match = await requests.post(
        '/likes',
        {
          'target': profile.uid,
        },
        (v) => v['match'] as Map<String, dynamic>?);

    return match == null ? null : Match.fromJson(match);
  }

  void markProfilesDirty() {
    _potentialMatches = null;
  }

  List<Profile> _profilesBuilder(Map<String, dynamic> values) {
    final list = values['profiles'] as List<dynamic>;
    return list.map((v) => Profile.fromJson(v)).toList();
  }

  Future<void> _refreshPotentialMatches(LocationService location,
      RequestsService requests, void Function(List<Profile>)? onChanged) async {
    Logger.info(runtimeType, 'Refreshing potential matches...');
    final loc = await location.getLocation();
    final locName = await location.getLocationName(loc);
    final response =
        await requests.get('/explore', _profilesBuilder, urlParams: {
      'lat': loc.latitude.toString(),
      'lon': loc.longitude.toString(),
      'locName': locName,
    });

    _potentialMatchesTs = DateTime.now();
    _potentialMatches = response!;
    _isLoading = false;
    if (onChanged != null) onChanged(_potentialMatches!);
  }
}
