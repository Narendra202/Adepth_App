
import 'package:expedition_poc/screens/home_page.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';

import '../../../utils/AppSigninTextFormField.dart';
import '../../../utils/App_Images_Path.dart';
import '../../../utils/colors.dart';



class AppSignIn extends StatefulWidget {
  // static var tag = "/T3SignIn";
  const AppSignIn({
    Key? key,
  }) : super(key: key);

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<AppSignIn> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool passwordVisible = true;


  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final nameController = TextEditingController();
  String error = "";

  bool? isRemember = false;

  _toggleObscured(){
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }



    @override
  Widget build(BuildContext context) {


    // changeStatusColor(Colors.transparent);
    return Scaffold(
      body: SingleChildScrollView(
           child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                height: 270,
                child: Stack(
                  children: <Widget>[
                    Image.asset(login_img, fit: BoxFit.fill, width:context.width(),height: 300,color: primaryColor,),
                    Container(
                      height: 300,
                      margin: EdgeInsets.only(left: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Adepth', style: boldTextStyle(size: 40, color: t3_white)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                // color: Colors.green,
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(right: 45),
                transform: Matrix4.translationValues(0.0, -80.0, 0.0),
                child: Image.asset(login2, height: 80, width: 80,color: primaryColor,),
              ),

              Container(
                child: ResponsiveApp(
                  mobile: LoginTextField(),

                  tablet:  Container(
                    // width: 500,
                    width: MediaQuery.of(context).size.width*0.5,
                    child: LoginTextField(),
                  ),

                  desktop: Container(
                    // width: 600,
                    // width: MediaQuery.of(context).size.width * 0.50,
                    width: MediaQuery.of(context).size.width*0.6,
                    child: Column(
                      children: [
                        // Container(
                        //     child: Image.asset(desktop_img, height: 150, width: 570,),
                        //     transform: Matrix4.translationValues(0.0, -50.0, 0.0),
                        // ),
                        LoginTextField()
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 50, left: 16, right: 26, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Image.asset(login1, height: 50, width: 70, color: primaryColor),
                        Container(
                          margin: EdgeInsets.only(top: 15, left: 20),
                          child: Image.asset(login2, height: 50, width: 70, color: primaryColor),
                        ),
                      ],
                    ),
                    Container(
                      child: Image.asset(login3, height: 80, width: 80, color: primaryColor),
                    ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),

    );

  }

  LoginTextField() {
    return Column(
      children: [
        SizedBox(height: 16),
        // t3EditTextField('Password', isPassword: true),
        AppTextFormField(hintText: 'Email Id', controller: _emailController,prefixIcon: Icon(Icons.person),),
        SizedBox(height: 16),
        // AppTextFormField(hintText: 'Password', controller: _passwordController, prefixIcon: Icon(Icons.lock), suffixIcon: Icon(Icons.remove_red_eye),),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: TextFormField(
            controller: _passwordController,
            style: primaryTextStyle(size: 18),
            obscureText: passwordVisible,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock),
              prefixIconColor: primaryColor,
              suffixIcon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                child: GestureDetector(
                  onTap: _toggleObscured,
                  child: Icon(
                    passwordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: primaryColor,
                  ),
                ),
              ),
              contentPadding: EdgeInsets.fromLTRB(26, 18, 4, 18),
              hintText:'Password',
              filled: true,
              fillColor: text_field_bg_color,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide(color: t3_edit_background, width: 0.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide(color: t3_edit_background, width: 0.0),
              ),
            ),
          ),
        ),

        if (error.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            error,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
        SizedBox(height: 14),
        Container(
          margin: EdgeInsets.only(left: 16),
          child: Row(
            children: <Widget>[
              Checkbox(
                focusColor: primaryColor,
                activeColor: primaryColor,
                value: isRemember,
                onChanged: (bool? value) {
                  setState(() {
                    isRemember = value;
                  });
                },
              ),

              Text('Remember', style: secondaryTextStyle(size: 16))
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            // child: T3AppButton(textContent: 'Sign In', onPressed: () {login();}),

            child: ElevatedButton(
              onPressed: () {
                login();
                // _onLoading();
              },
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)), padding: EdgeInsets.all(0.0), elevation: 4, textStyle: TextStyle(color: t3_white)),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: <Color>[ primaryDarkColor,primaryColor]),
                  borderRadius: BorderRadius.all(Radius.circular(80.0)),
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Text(
                      'Sign In',
                      style: TextStyle(fontSize: 22,color: Colors.white,fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _onLoading() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: EdgeInsets.all(0.0),
          insetPadding: EdgeInsets.symmetric(horizontal: 100),
          content: Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 16),
                Text("Please wait....", style: primaryTextStyle(color: primaryColor)),
              ],
            ),
          ),
        );
      },
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
      _onLoading();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', response["data"]["_key"]);
      await prefs.setString('userName', response["data"]["name"]);
      await prefs.setString('userEmail', response["data"]["email"]);
      HomePage().launch(context, isNewTask: true);
      // Navigator.pushReplacementNamed(context, AppPaths.home);
    }
  }


}

class MobileLogin extends StatelessWidget {
  const MobileLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('hello'),
    );
  }
}








