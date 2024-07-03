import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class AuthGuard {
  static Future<bool> isAuthenticated() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    if (userId == null || userId.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Check if the requested route requires authentication
    return MaterialPageRoute(
      builder: (context) {
        return FutureBuilder<bool>(
          future: AuthGuard.isAuthenticated(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Still waiting for authentication result, display a loading indicator
              return const CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data == true) {
              // User is authenticated, allow access to the requested route
              return settings.arguments as Widget;
            } else {
              // User is not authenticated, redirect to the login screen
              return const AppSignIn();
            }
          },
        );
      },
    );
    // else {
    //   // Route does not require authentication, allow access
    //   return MaterialPageRoute(builder: (_) => settings.arguments as Widget);
    // }
  }
}
