import 'dart:convert';

import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/providers/google_sign_in.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/login-background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //We take the image from the assets
          Image.network(
            'https://media.licdn.com/dms/image/C4D0BAQES0B3Ft5nEgQ/company-logo_200_200/0/1676290877496?e=2147483647&v=beta&t=IMWZTN2x6HVAyCBgKN-MGPmroySCs-g8sbJV8jTGBA0',
            height: 100,
          ),
          const SizedBox(
            height: 100,
          ),
          //Texts and Styling of them
          const Text(
            'Welcome to Adepth !',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),
          const SizedBox(height: 20),
          const Text(
            'A one-stop portal for your organization to add expeditions, areas, survay, samples and many more',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          const SizedBox(
            height: 50,
          ),
          //Our MaterialButton which when pressed will take us to a new screen named as
          //LoginScreen
          Container(
              margin: const EdgeInsets.only(left: 25, right: 25),
              child: MaterialButton(
                elevation: 0,
                height: 50,
                onPressed: () {
                  singIn(context);
                },
                color: ColorUtils.secondaryColor,
                textColor: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/512/2991/2991148.png',
                      height: 28,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Sign in with Google',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                  ],
                ),
              ))
        ],
      ),
    ));
  }

  Future singIn(context) async {
    final user = await GoogleSignInApi.login();

    final jsonData = {
      'displayName': user?.displayName,
      'email': user?.email,
      'photoUrl': user?.photoUrl,
      "id": user?.id
    };

    final response = await ApiProvider()
        .post(AppConsts.baseURL + AppConsts.signin, jsonData);

    // final storage = FlutterSecureStorage();
    // await storage.write(key: "userId", value: response._key);
    Navigator.pushReplacementNamed(context, AppPaths.home);
  }

  Future logout() async {
    final user = await GoogleSignInApi.logout();
  }
}
