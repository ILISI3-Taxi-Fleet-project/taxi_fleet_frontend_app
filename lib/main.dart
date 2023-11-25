import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_fleet_frontend_app/pages/client/main_page.dart' as clientHomePage;
import 'package:taxi_fleet_frontend_app/pages/driver/main_page.dart' as driverHomePage;
import 'package:taxi_fleet_frontend_app/pages/signin_page.dart';
import 'package:taxi_fleet_frontend_app/providers/location_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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