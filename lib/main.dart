import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'widgets/navbar.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<bool> _checkOnboardingStatus() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/onboarding_data.txt');
    return file.exists();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoCrave',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: _checkOnboardingStatus(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            if (snapshot.hasData && snapshot.data == true) {
              return NavBar();
            } else {
              return OnboardingScreen();
            }
          }
        },
      ),
      routes: {
        '/home': (context) => NavBar(),
      },
    );
  }
}
