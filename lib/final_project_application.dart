import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umrahapp/views/authentication/auth_bloc/auth_bloc.dart';
import 'package:umrahapp/views/notifications/notification_bloc/notification_bloc.dart';
import 'package:umrahapp/views/splash/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FinalProjectApplication extends StatefulWidget {
  const FinalProjectApplication({super.key});

  @override
  State<FinalProjectApplication> createState() =>
      _FinalProjectApplicationState();
}

class _FinalProjectApplicationState extends State<FinalProjectApplication> {
  @override
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is SuccessNotificationState &&
              state.newNotifications.isNotEmpty) {
            final notification = state.newNotifications.first;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.notifications, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        notification.message,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: const [Locale('ar', 'AE'), Locale('en', 'US')],

          locale: const Locale('ar', 'AE'),

          theme: ThemeData(
            colorScheme: ColorScheme.highContrastLight(
              primary: const Color.fromRGBO(24, 100, 66, 1),
              secondary: const Color.fromRGBO(0, 0, 0, 0.5),
              inverseSurface: const Color.fromRGBO(230, 226, 228, 0.6),
              onPrimary: const Color.fromRGBO(24, 100, 66, 1),
            ),
            fontFamily: 'Poppins',
            textTheme: TextTheme(
              headlineSmall: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
              bodySmall: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              labelSmall: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              headlineLarge: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              titleSmall: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.secondary,
              ),
              titleMedium: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xff131313),
              ),
              titleLarge: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xff131313),
              ),
              labelMedium: const TextStyle(
                color: Color(0x80000000),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              bodyMedium: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          home: SplashScreen(),
        ),
      ),
    );
  }
}
