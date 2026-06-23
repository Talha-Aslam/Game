import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

import 'providers/notification_provider.dart';

class MafiaAtCityApp extends StatelessWidget {
  const MafiaAtCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MAFIA AT CITY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      scaffoldMessengerKey: globalsnackBarKey,
    );
  }
}
