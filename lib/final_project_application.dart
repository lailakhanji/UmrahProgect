import 'package:flutter/material.dart';
import 'package:umrahapp/views/on_boarding/on_boarding_screen.dart';

class FinalProjectApplication extends StatefulWidget {
  const FinalProjectApplication({super.key});

  @override
  State<FinalProjectApplication> createState() => _FinalProjectApplicationState();
}

class _FinalProjectApplicationState extends State<FinalProjectApplication> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.highContrastLight(
          primary: Color(0xff0D9B5C),
          secondary: Color.fromRGBO(0, 0, 0, 0.5),
inverseSurface: Color.fromRGBO(230, 226, 228, 0.6),
        ),
          fontFamily: 'Poppins',
      textTheme: TextTheme(

        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight:FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
         bodySmall: TextStyle(
            fontSize:14,
            fontWeight:FontWeight.w600,
          ),
          labelSmall: TextStyle(
            fontSize:16,
            fontWeight:FontWeight.w700,
            color: Colors.white
          ),
          headlineLarge: TextStyle(
              fontSize:30,
              fontWeight:FontWeight.bold,
              color: Colors.black
          ),
          titleSmall: TextStyle(
              fontSize:12,
              fontWeight:FontWeight.w400,
              color: Theme.of(context).colorScheme.secondary

          ),
          titleMedium: TextStyle(
              fontSize:16,
              fontWeight:FontWeight.w600,
              color: Color(0xff131313
              )

          ),
        titleLarge: TextStyle(
            fontSize:24,
            fontWeight:FontWeight.w700,
            color: Color(0xff131313
            )

        ),
      )
      ),

      home: OnBoardingScreen(),
    );
  }
}
