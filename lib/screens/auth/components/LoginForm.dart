import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double defaultPadding = 10.0;

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String error = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: Container(
              decoration: BoxDecoration(
                color: ColorUtils.primaryColorLight, // Set the background color
                borderRadius:
                    BorderRadius.circular(30), // Set the border radius
              ),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                cursorColor: ColorUtils.primaryColor,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  // Remove the bottom line
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                  // Adjust the vertical padding
                  hintText: "Your email",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.person),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                controller: _emailController,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: Container(
              decoration: BoxDecoration(
                color: ColorUtils.primaryColorLight,
                // S/ Set the background color
                borderRadius:
                    BorderRadius.circular(30), // Set the border radius
              ),
              child: TextFormField(
                textInputAction: TextInputAction.done,
                obscureText: true,
                cursorColor: ColorUtils.primaryColor,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  // Remove the bottom line
                  contentPadding: EdgeInsets.symmetric(vertical: 20.0),
                  // Adjust the vertical padding
                  hintText: "Your password",
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Icon(Icons.lock),
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                controller: _passwordController,
              ),
            ),
          ),
          if (error.isNotEmpty) ...[
            const SizedBox(height: defaultPadding),
            Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],
          const SizedBox(height: defaultPadding),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              // Adjust the padding as needed
              child: ElevatedButton(
                onPressed: () => {login()},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  // Adjust the vertical padding as needed
                  child: Text(
                    "Login".toUpperCase(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
        ],
      ),
    );
  }

  handleValidation() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      return "Fields are empty";
    }
    final emailRegex = RegExp(
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z\d-]+(\.[a-zA-Z\d-]+)*\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  login() async {
    setState(() {
      error = "";
    });
    var validate = handleValidation();
    if (validate != null) {
      setState(() {
        error = validate;
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final obj = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    // save to db
    final response =
        await ApiProvider().post(AppConsts.baseURL + AppConsts.login, obj);

    setState(() {
      _isLoading = false;
    });

    if (response["success"] == false) {
      setState(() {
        error = "Invalid email/password";
      });
      return;
    } else {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', response["data"]["_key"]);
      await prefs.setString('userName', response["data"]["name"]);
      await prefs.setString('userEmail', response["data"]["email"]);
      Navigator.pushReplacementNamed(context, AppPaths.home);
    }
  }
}
