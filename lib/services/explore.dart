import 'dart:async';

import 'package:alchemy/data/match.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/data/profile_interaction.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/services/location.dart';
import 'package:alchemy/services/requests.dart';

class ExploreService {
  static final ExploreService instance = ExploreService();

  List<Profile>? _potentialMatches;
  DateTime? _potentialMatchesTs;
  bool _isLoading = false;
  Future<List<Profile>>? _profilesFuture;

  List<Profile>? getPotentialMatches(
    LocationService location,
    RequestsService requests, {
    void Function(List<Profile> profiles)? onChanged,
  }) {
    Logger.debug(runtimeType, 'Getting potential matches...');
    if (_shouldRefresh() && !_isLoading) {
      _isLoading = true;
      _refreshPotentialMatches(location, requests, onChanged);
    }

    return _potentialMatches;
  }

  Future<List<Profile>> getPotentialMatchesAsync(LocationService location, RequestsService requests) {
    if (_profilesFuture == null) {
      _isLoading = true;
      return _refreshPotentialMatches(location, requests, null);
    } else {
      return _profilesFuture!;
    }
  }

  Future<Match?> likeProfile(Profile profile, Set<ProfileInteraction> interactions, RequestsService requests) async {
    final match = await requests.post(
        '/likes',
        {
          'target': profile.uid,
          'interactions': interactions.map((e) => e.relationshipInterest).toList(),
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

  Future<List<Profile>> _refreshPotentialMatches(LocationService location,
      RequestsService requests, void Function(List<Profile>)? onChanged) async {
    Logger.info(runtimeType, 'Refreshing potential matches...');
    final loc = await location.getLocation();
    final locName = await location.getLocationName(loc);
    _profilesFuture = requests.get('/explore', _profilesBuilder, urlParams: {
      'lat': loc.latitude.toString(),
      'lon': loc.longitude.toString(),
      'locName': locName,
    }).then((e) => e!);

    final response = await _profilesFuture;
    _potentialMatchesTs = DateTime.now();
    _potentialMatches = response!;
    _isLoading = false;
    if (onChanged != null) onChanged(_potentialMatches!);
    return response;
  }

  bool _shouldRefresh() => _potentialMatches == null || DateTime.now().difference(_potentialMatchesTs!).inMinutes >= 5;
}
