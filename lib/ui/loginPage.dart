import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_login_signup/config/apiConfig.dart';
import 'package:flutter_login_signup/model/login.dart';
import 'package:flutter_login_signup/ui/forgotPasswordPage.dart';
import 'package:flutter_login_signup/ui/homePage.dart';
import 'package:flutter_login_signup/ui/signup.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Widget/bezierContainer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final storage = new FlutterSecureStorage();

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, TextEditingController textEditingController,
      {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
              controller: textEditingController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter ' + title;
                }
                return null;
              },
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
        style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent)),
        onPressed: () {
          // Validate returns true if the form is valid, or false otherwise.
          if (_formKey.currentState.validate()) {
            // If the form is valid, display a snackbar. In the real world,
            // you'd often call a server or save the information in a database.
            attemptLogIn();
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text('Processing Data')),
            // );
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xff6d6bff), Color(0xff4d4cb2)])),
          child: Text(
            'Login',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ));
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUpPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Don\'t have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Color(0xff4d4cb2),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return Padding(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              "assets/images/logo.png",
              height: 70,
            ),
          )
        ],
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("User Name", emailController),
        _entryField("Password", passwordController, isPassword: true),
      ],
    );
  }

  Future<String> attemptLogIn() async {
    print("Login process running");
    var res = await http.post("$LOGIN", body: {
      "username": emailController.text,
      "password": passwordController.text,
      "clientId": CLIENT_ID,
      "clientSecret": API_CLIENT_TOKEN,
      "grantType": 'password'
    });
    if (res.statusCode == 200) {
      print("Loggedin");
      Map parsed = json.decode(res.body);
      Login loginResponse = Login.fromJson(parsed);
      await storage.write(
          key: 'jwt', value: loginResponse.responseBody.accessToken);
      await storage.write(
          key: 'refreshToken', value: loginResponse.responseBody.refreshToken);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          ModalRoute.withName("/Home"));
      // print(loginResponse.responseBody.accessToken);
    } else if (res.statusCode == 406) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Your username or password is wrong!"),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please try again!"),
      ));
    }
    // print(res.body);
    // return res.body;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      height: height,
      child: Stack(
        children: <Widget>[
          Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer()),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * .2),
                  _title(),
                  SizedBox(height: 50),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _emailPasswordWidget(),
                          SizedBox(height: 20),
                          _submitButton(),
                        ],
                      )),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage())),
                      child: Text('Forgot Password ?',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  _createAccountLabel(),
                ],
              ),
            ),
          ),
          Positioned(top: 40, left: 0, child: _backButton()),
        ],
      ),
    ));
  }
}
