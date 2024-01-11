import 'package:alchemy/data/callingcode.dart';
import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/countdown.dart';
import 'package:alchemy/pages/error.dart';
import 'package:alchemy/pages/home.dart';
import 'package:alchemy/pages/login.dart';
import 'package:alchemy/pages/locationrequest.dart';
import 'package:alchemy/pages/noconnection.dart';
import 'package:alchemy/pages/nolocation.dart';
import 'package:alchemy/pages/redlisted.dart';
import 'package:alchemy/pages/signup/intake.dart';
import 'package:alchemy/pages/signup/photos.dart';
import 'package:alchemy/pages/signup/tos.dart';
import 'package:alchemy/pages/tutorial.dart';
import 'package:alchemy/pages/update_required.dart';
import 'package:alchemy/services/auth.dart';
import 'package:alchemy/services/location.dart';
import 'package:alchemy/services/notifications.dart';
import 'package:alchemy/services/requests.dart';
import 'package:alchemy/services/updates.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alchemy/routing.dart';
import 'package:shared_preferences/shared_preferences.dart';

final liveDate = DateTime.utc(2023, 9, 9);

class InitPage extends StatefulWidget {
  const InitPage({super.key});

  @override
  State<InitPage> createState() => _InitPageState();
}

class _InitPageState extends State<InitPage> {
  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: theme.colorScheme.background),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> init() async {
    Logger.info(runtimeType, 'Initializing...');
    final requestsService = RequestsService.instance;
    try {
      final isUpdateRequired =
          await UpdatesService.instance.isUpdateRequired(requestsService);
      if (isUpdateRequired && kIsWeb) {
        Logger.error(runtimeType,
            'Web client is out of date. This should never happen!');
      } else if (isUpdateRequired) {
        replaceRoute(context, UpdateRequiredPage());
        return;
      }
    } on RequestsServiceException catch (e) {
      Logger.error(runtimeType, 'Failed to get app version: $e. Continuing...');
    } on Exception catch (e) {
      Logger.exception(runtimeType, e);
      replaceRoute(context, ErrorPage(message: e.toString()));
      return;
    }

    if (!CallingCode.isLoaded) await CallingCode.loadCallingCodes();

    final authService = AuthService.instance;
    try {
      await authService.initialize(requestsService);
    } on RequestsServiceHttpException catch (e) {
      if (e.status == 404) {
        // Contact does not exist. This will only happen
        // if the user logs in and then their contact is deleted.
        // i.e., this should basically never happen.
        // However, to handle this case, we'll "log out" so that
        // the auth service can resync with the server.
        await AuthService.instance.logout(RequestsService.instance);
      } else {
        Logger.exception(runtimeType, e);
        replaceRoute(context, ErrorPage(message: e.message));
        return;
      }
    } on RequestsServiceException catch (e) {
      Logger.warnException(runtimeType, e);
      replaceRoute(context, const NoConnectionPage());
      return;
    }

    if (!authService.isLoggedIn) {
      replaceRoute(context, const LoginPage());
      return;
    }

    if (authService.contact != null &&
        (authService.contact!.isRedlisted || authService.contact!.age < 18)) {
      replaceRoute(context, const RedlistedPage());
      return;
    }

    final locationService = LocationService.instance;
    try {
      if (!locationService.isInitialized) await locationService.initialize();
    } on LocationServiceInvalidException catch (e) {
      Logger.exception(runtimeType, e);
      replaceRoute(context, ErrorPage(message: e.message));
      return;
    } on LocationServiceTimeoutException catch (e) {
      Logger.warnException(runtimeType, e);
      replaceRoute(context, NoLocationPage());
      return;
    } on LocationServiceException {
      replaceRoute(context, const LocationRequestPage());
      return;
    } on Exception catch (e) {
      Logger.exception(runtimeType, e);
      replaceRoute(context, ErrorPage(message: e.toString()));
      return;
    }

    if (authService.profile == null) {
      replaceRoute(context, const SignupIntakePage());
      return;
    }

    final profile = authService.profile!;
    if (profile.photoUrls.isEmpty) {
      replaceRoute(context, const SignupPhotosPage(profileData: null));
      return;
    }

    if (!authService.contact!.tosAgreed) {
      replaceRoute(context, const SignupTosPage());
      return;
    }

    final now = DateTime.now();
    if (now.isBefore(liveDate)) {
      final notifications = NotificationsService.instance;
      if (!notifications.isInitialized) await notifications.initialize();
      replaceRoute(context, const CountdownPage());
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final isTutorialCompleted = prefs.getBool(tutorialStatusKey) ?? false;
    if (!isTutorialCompleted) {
      replaceRoute(context, const TutorialPage());
      return;
    }

    try {
      Logger.debug(runtimeType, 'Initializing notifications');
      final notifications = NotificationsService.instance;
      Logger.debug(runtimeType, 'Initialized: ${notifications.isInitialized}');
      if (!notifications.isInitialized) {
        Logger.debug(runtimeType, 'Initializing notifications...');
        await notifications.initialize();
        Logger.debug(runtimeType, 'Notifications initialized.');
      }
    } on Exception catch (e) {
      Logger.exception(runtimeType, e);
      replaceRoute(context, ErrorPage(message: e.toString()));
      return;
    }

    replaceRoute(context, const HomePage());
  }
}
