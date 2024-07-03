import 'package:expedition_poc/screens/application/expeditions/expeditions.dart';
import 'package:expedition_poc/screens/auth/login_page.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ValidatorPage extends StatefulWidget {
  const ValidatorPage({super.key});

  @override
  State<ValidatorPage> createState() => _ValidatorPageState();
}

class _ValidatorPageState extends State<ValidatorPage> {
  Future<bool> checkLoggedInUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    return userId != null && userId.isNotEmpty;
  }

  void navigateToNextScreen() async {
    final bool loggedIn = await checkLoggedInUser();
    if (loggedIn) {
      Navigator.pushReplacementNamed(context, AppPaths.home);
    } else {
      Navigator.pushReplacementNamed(context, AppPaths.login);
    }
  }

  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () async {
        // Prevent navigating back from the Expedition page
        return false;
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
