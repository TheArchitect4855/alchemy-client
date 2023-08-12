import 'package:alchemy/data/match.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/services/location.dart';
import 'package:alchemy/services/requests.dart';

class ExploreService {
  static final ExploreService instance = ExploreService();

  Future<List<Profile>> getPotentialMatches(
      LocationService location, RequestsService requests) async {
    final loc = await location.getLocation();
    final locName = await location.getLocationName(loc);
    final response =
        await requests.get('/explore', _profilesBuilder, urlParams: {
      'lat': loc.latitude.toString(),
      'lon': loc.longitude.toString(),
      'locName': locName,
    });

    return response!;
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

  List<Profile> _profilesBuilder(Map<String, dynamic> values) {
    final list = values['profiles'] as List<dynamic>;
    return list.map((v) => Profile.fromJson(v)).toList();
  }
}
