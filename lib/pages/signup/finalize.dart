import 'package:alchemy/logger.dart';
import 'package:alchemy/pages/error.dart';
import 'package:alchemy/pages/init.dart';
import 'package:alchemy/pages/noconnection.dart';
import 'package:alchemy/routing.dart';
import 'package:alchemy/services/auth.dart';
import 'package:alchemy/services/requests.dart';
import 'package:flutter/material.dart';

class SignupFinalizePage extends StatefulWidget {
  const SignupFinalizePage({super.key});

  @override
  State<StatefulWidget> createState() => _SignupFinalizePageState();
}

class _SignupFinalizePageState extends State<SignupFinalizePage> {
  @override
  void initState() {
    super.initState();
    _finalize();
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));

  void _finalize() async {
    try {
      await AuthService.instance.agreeTos(RequestsService.instance);

      if (mounted) {
        replaceRoute(context, const InitPage());
      } else {
        Logger.error(runtimeType, 'Context was unmounted!');
      }
    } on RequestsServiceHttpException catch (e) {
      Logger.exception(runtimeType, e);
      replaceRoute(context, ErrorPage(message: e.toString()));
    } on RequestsServiceException catch (e) {
      Logger.warnException(runtimeType, e);
      replaceRoute(context, const NoConnectionPage());
    }
  }
}
