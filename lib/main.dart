import 'package:flutter/material.dart';
import 'package:kuis4/auth/auth.dart';
import 'package:kuis4/auth/shared_preferences_helper.dart';
import 'package:kuis4/item/items.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login/Register',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: SharedPreferencesHelper.getPreference('access_token'),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null) {
              // Token exists, redirect to some authenticated page
              return const FoodListPage();
            } else {
              // Token doesn't exist, redirect to login/register page
              return LoginRegisterPage();
            }
          } else {
            // Show loading indicator while checking token existence
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}