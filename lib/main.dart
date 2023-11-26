import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_fleet_frontend_app/pages/client/main_page.dart' as clientHomePage;
import 'package:taxi_fleet_frontend_app/pages/driver/main_page.dart' as driverHomePage;
import 'package:taxi_fleet_frontend_app/pages/signin_page.dart';
import 'package:taxi_fleet_frontend_app/providers/location_provider.dart';
import 'package:taxi_fleet_frontend_app/providers/shared_prefs.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        Provider<SharedPrefs>(create: (context) => SharedPrefs()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Taxi Fleet App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SigninPage(),
      routes:{
        '/passengerHome': (context) => const clientHomePage.MainPage(),
        '/driverHome': (context) => const driverHomePage.MainPage(),
        '/signinpage': (context) => const SigninPage(),
      }
    );
  }
}