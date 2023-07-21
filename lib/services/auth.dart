import 'package:alchemy/data/contact.dart';
import 'package:alchemy/data/phonenumber.dart';
import 'package:alchemy/data/profile.dart';
import 'package:alchemy/jwt.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/services/location.dart';
import 'package:alchemy/services/requests.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const authTokenKey = 'authtoken';

enum LoginCodeChannel {
  sms,
  whatsapp,
}

class AuthService {
  static const int maxTags = 25; // Maximum interests/neurodiversities
  static final AuthService instance = AuthService();

  bool get isLoggedIn => _isLoggedIn;
  Contact? get contact => _contact;
  Profile? get profile => _profile;

  final FlutterSecureStorage _storage;
  bool _isLoggedIn = false;
  Contact? _contact;
  Profile? _profile;

  AuthService() : _storage = const FlutterSecureStorage();

  Future<void> agreeTos(RequestsService requests) async {
    final token = await requests.put(
        '/contact',
        {
          'agreeTos': true,
        },
        (v) => v['token'] as String);

    await _setAuthToken(token!, requests);
  }

  Future<Contact> createContact(DateTime dob, RequestsService requests) async {
    if (_contact != null) throw StateError('contact already exists');
    if (!_isLoggedIn) throw StateError('not logged in');
    final token = await requests.post('/contact',
        {'dob': dob.toUtc().toIso8601String()}, (v) => v['token'] as String);
    await _setAuthToken(token!, requests);
    return _contact!;
  }

  Future<Profile> createProfile(
      String name,
      String? bio,
      String gender,
      Set<String> relationshipInterests,
      Set<String> neurodiversities,
      Set<String> interests,
      String? pronouns,
      LocationService location,
      RequestsService requests,
      {required bool isTransgender}) async {
    if (!_isLoggedIn) throw StateError('not logged in');
    if (_contact == null) throw StateError('no contact');

    if (name.isEmpty || name.length > 128) throw ArgumentError('invalid name');
    if (bio != null && (bio.isEmpty || bio.length > 1024)) {
      throw ArgumentError('invalid bio');
    }

    if (gender.isEmpty || gender.length > 16) {
      throw ArgumentError('invalid gender');
    }

    if (relationshipInterests.isEmpty) {
      throw ArgumentError('must have at least one relationship interest');
    }

    final loc = await location.getLocation();
    var locName = await location.getLocationName(loc) ?? 'Unknown Location';
    if (locName.length > 32) locName = '${locName.substring(0, 30)}...';

    _profile = await requests.post(
        '/profile',
        {
          'name': name,
          'bio': bio ?? '',
          'gender': gender,
          'isTransgender': isTransgender,
          'photoUrls': [],
          'relationshipInterests': relationshipInterests.toList(),
          'neurodiversities': neurodiversities.toList(),
          'interests': interests.toList(),
          'pronouns': pronouns,
          'locLat': loc.latitude,
          'locLon': loc.longitude,
          'locName': locName,
        },
        Profile.fromJson);

    return _profile!;
  }

  Future<Profile> updateProfile(
      String name,
      String bio,
      String gender,
      Set<String> relationshipInterests,
      Set<String> neurodiversities,
      Set<String> interests,
      String? pronouns,
      RequestsService requests) async {
    _profile = (await requests.put(
        '/profile',
        {
          'name': name,
          'bio': bio,
          'gender': gender,
          'relationshipInterests':
              relationshipInterests.map((e) => e.toLowerCase()).toList(),
          'neurodiversities': neurodiversities.toList(),
          'interests': interests.toList(),
          'pronouns':
              (pronouns == null || pronouns.trim().isEmpty) ? null : pronouns,
        },
        Profile.fromJson))!;

    return _profile!;
  }

  Future<void> deleteProfile(RequestsService requests) async {
    await requests.delete('/profile', (v) => v);
    await logout(requests);
  }

  Future<void> initialize(RequestsService requests) async {
    final authToken = await _storage.read(key: authTokenKey);
    Logger.debug(runtimeType, 'Auth token: $authToken');
    if (authToken == null) return;

    requests.setAuthToken(authToken);
    await _tryGetUserData(authToken, requests);
  }

  Future<bool> isAppAvailableInArea(
      LocationService location, RequestsService requests) async {
    final loc = await location.getLocation();
    final available = (await requests
        .get('/availability', (v) => v['available'] as bool, urlParams: {
      'lat': loc.latitude.toString(),
      'lon': loc.longitude.toString(),
    }))!;

    return available;
  }

  Future<void> requestLoginCode(PhoneNumber phone, LoginCodeChannel channel,
      RequestsService requests) async {
    await requests.get('/login', (_) => null,
        urlParams: {'phone': phone.toString(), 'channel': channel.name});
  }

  Future<void> login(
      PhoneNumber phone, String code, RequestsService requests) async {
    final token = (await requests.post(
        '/login',
        {'code': code, 'phone': phone.toString()},
        (v) => v['token'] as String))!;
    Logger.debug(runtimeType, 'Auth token: $token');
    await _setAuthToken(token, requests);
    await _tryGetUserData(token, requests);
  }

  Future<void> logout(RequestsService requests) async {
    _isLoggedIn = false;
    _contact = null;
    _profile = null;
    requests.setAuthToken('');
    await _storage.delete(key: authTokenKey);
  }

  Future<void> _setAuthToken(String token, RequestsService requests) async {
    await _storage.write(key: authTokenKey, value: token);
    requests.setAuthToken(token);

    final jwt = Jwt.decode(token)?.payload;
    if (jwt == null) {
      _isLoggedIn = false;
      Logger.warn(runtimeType, 'Invalid auth token: $token');
      return;
    }

    if (DateTime.now().millisecondsSinceEpoch > jwt['exp']) {
      _isLoggedIn = false;
      return;
    }

    if (jwt['sub'] != null &&
        jwt['phn'] != null &&
        jwt['dob'] != null &&
        jwt['flg'] != null) {
      final dob = DateTime.fromMicrosecondsSinceEpoch(jwt['dob']);
      final flags =
          (jwt['flg'] as String).split('').map((e) => e == '1').toList();
      _contact = Contact(jwt['sub'], dob, flags[0], flags[1]);
    } else {
      return;
    }
  }

  Future<void> _tryGetUserData(
      String authToken, RequestsService requests) async {
    _isLoggedIn = true;
    _contact = null;
    _profile = null;

    var jwt = Jwt.decode(authToken)?.payload;
    if (jwt == null) {
      _isLoggedIn = false;
      Logger.warn(runtimeType, 'Invalid auth token: $authToken');
      return;
    }

    if (DateTime.now().millisecondsSinceEpoch > jwt['exp']) {
      _isLoggedIn = false;
      return;
    }

    try {
      final token =
          (await requests.get('/login/update', (v) => v['token'] as String))!;
      requests.setAuthToken(token);
      jwt = Jwt.decode(token)?.payload;
    } on RequestsServiceHttpException catch (e) {
      if (e.status != 404) {
        rethrow; // 404 means we have no contact. This is actually fine.
      }
    }

    if (jwt?['sub'] != null &&
        jwt?['phn'] != null &&
        jwt?['dob'] != null &&
        jwt?['flg'] != null) {
      final dob = DateTime.fromMillisecondsSinceEpoch(jwt!['dob']);
      final flags =
          (jwt['flg'] as String).split('').map((e) => e == '1').toList();
      _contact = Contact(jwt['sub'], dob, flags[0], flags[1]);
    } else {
      return;
    }

    try {
      _profile = await requests.get('/profile', Profile.fromJson);
    } on RequestsServiceHttpException catch (e) {
      if (e.status == 401) {
        // Invalid token
        _isLoggedIn = false;
        return;
      } else if (e.status == 404) {
        // No profile
        return;
      } else {
        rethrow;
      }
    }
  }
}
