import 'package:alchemy/data/preferences.dart';
import 'package:alchemy/services/requests.dart';

class PreferencesService {
  static final PreferencesService instance = PreferencesService();

  Future<Preferences> getPreferences(RequestsService requests) async {
    final prefs = await requests.get('/preferences', Preferences.fromJson);
    return prefs!;
  }

  Future<void> setPreferences(Preferences prefs, RequestsService requests) async {
    await requests.put('/preferences', prefs.toJson(), (v) => v);
  }
}
