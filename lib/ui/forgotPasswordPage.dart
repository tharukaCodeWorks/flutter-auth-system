import 'dart:convert';
import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_signup/config/apiConfig.dart';
import 'package:flutter_login_signup/model/forgotPassword.dart';
import 'package:flutter_login_signup/model/login.dart';
import 'package:flutter_login_signup/model/tokenValidate.dart';
import 'package:flutter_login_signup/ui/Widget/bezierContainer.dart';
import 'package:flutter_login_signup/ui/loginPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ForgotPasswordPage createState() => _ForgotPasswordPage();
}

class _ForgotPasswordPage extends State<ForgotPasswordPage> {
  final _resetForm = GlobalKey<FormState>();
  final _tokenVerfyForm = GlobalKey<FormState>();
  final _requestForm = GlobalKey<FormState>();

  TextEditingController userNameController = TextEditingController();
  TextEditingController verifyToken = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  int _currentStep = 0;
  int genderIndex = 0;
  DateTime selectedDate = DateTime.now();
  String jwToken;
  String referenceId;
  bool isInvalidToken = false;

  String countryName = "Australia";
  String dialCode = "+61";

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
      {bool isPassword = false,
      bool isEmail = false,
      BuildContext buildContext,
      bool enable = true,
      bool isToken = false,
      bool isConfirmPswd = false,
      Function onTap}) {
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
              enableInteractiveSelection: enable,
              onTap: () => onTap != null ? onTap(buildContext) : null,
              controller: textEditingController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter ' + title;
                } else if (isPassword && !validatePasswordStructure(value)) {
                  return 'Password must contain 1 uppercase, lowercase, numeric, special char';
                } else if (isEmail && !isValidEmail(value)) {
                  return 'Please enter valid email address';
                } else if (isToken && isInvalidToken) {
                  return 'You entered token is invalid';
                } else if (isConfirmPswd &&
                    (passwordController.text != confirmPassword.text)) {
                  return 'Password not matching!';
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

  // Widget _submitButton({BuildContext buildcontext}) {
  //   return ElevatedButton(
  //       style: ButtonStyle(
  //           padding: MaterialStateProperty.all(EdgeInsets.zero),
  //           backgroundColor:
  //               MaterialStateProperty.all<Color>(Colors.transparent)),
  //       onPressed: () {
  //         generateToken(buildcontext: buildcontext);
  //         // Validate returns true if the form is valid, or false otherwise.
  //         // if (_formKey.currentState.validate()) {
  //         //   // If the form is valid, display a snackbar. In the real world,
  //         //   // you'd often call a server or save the information in a database.
  //         //   ScaffoldMessenger.of(context).showSnackBar(
  //         //     const SnackBar(content: Text('Processing Data')),
  //         //   );
  //         // }
  //       },
  //       child: Container(
  //         width: MediaQuery.of(context).size.width,
  //         padding: EdgeInsets.symmetric(vertical: 15),
  //         alignment: Alignment.center,
  //         decoration: BoxDecoration(
  //             borderRadius: BorderRadius.all(Radius.circular(5)),
  //             boxShadow: <BoxShadow>[
  //               BoxShadow(
  //                   color: Colors.grey.shade200,
  //                   offset: Offset(2, 4),
  //                   blurRadius: 5,
  //                   spreadRadius: 2)
  //             ],
  //             gradient: LinearGradient(
  //                 begin: Alignment.centerLeft,
  //                 end: Alignment.centerRight,
  //                 colors: [Color(0xff6d6bff), Color(0xff4d4cb2)])),
  //         child: Text(
  //           'Register Now',
  //           style: TextStyle(fontSize: 20, color: Colors.white),
  //         ),
  //       ));
  // }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Already have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Login',
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

  Widget _requestResetPassword() {
    return Column(
      children: <Widget>[
        _entryField("Username", userNameController),
      ],
    );
  }

  Widget _validateToken() {
    return Column(
      children: <Widget>[
        _entryField("Token", verifyToken),
      ],
    );
  }

  Widget _resetPassword({BuildContext buildContext}) {
    return Column(
      children: <Widget>[
        _entryField("Password", passwordController, isPassword: true),
        _entryField("Re-Password", confirmPassword,
            isConfirmPswd: true, isPassword: true),
      ],
    );
  }

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  bool isValidEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  bool validatePasswordStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  continued() {
    switch (_currentStep) {
      case 0:
        {
          if (_requestForm.currentState.validate()) {
            generateToken();
          }
        }
        break;

      case 1:
        {
          {
            if (_tokenVerfyForm.currentState.validate()) {
              // _currentStep < 3 ? setState(() => _currentStep += 1) : null;
              checkToken();
            }
          }
        }
        break;
      case 2:
        {
          {
            if (_resetForm.currentState.validate()) {
              // _currentStep < 3 ? setState(() => _currentStep += 1) : null;
              resetPassword();
            }
          }
        }
        break;
    }
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  Future generateToken({BuildContext buildcontext}) async {
    print("Login process running");
    var res = await http.post("$LOGIN", body: {
      "clientId": CLIENT_ID,
      "clientSecret": API_CLIENT_TOKEN,
      "grantType": 'client_credentials'
    });
    if (res.statusCode == 200) {
      print("Loggedin");
      Map parsed = json.decode(res.body);
      Login loginResponse = Login.fromJson(parsed);
      // setState(() {
      //   this.jwToken = loginResponse.responseBody.accessToken;
      // });
      print(loginResponse.responseBody.accessToken);
      setState(() {
        jwToken = loginResponse.responseBody.accessToken;
      });
      requestForPasswordReset(loginResponse.responseBody.accessToken);
    } else if (res.statusCode == 406) {
    } else {}
  }

  Future requestForPasswordReset(String token,
      {BuildContext buildcontext}) async {
    String userName = forgotPasswordRequest(userNameController.text);
    var res = await http.get(
      userName,
      headers: {
        'authorization': "Bearer " + token,
      },
    );
    if (res.statusCode == 202) {
      Map parsed = json.decode(res.body);
      ForgotPassword forgotPassword = ForgotPassword.fromJson(parsed);
      setState(() {
        referenceId = forgotPassword.responseBody.referenceId;
      });
      _currentStep < 2 ? setState(() => _currentStep += 1) : null;
      // print("Registered Successfully");
      // var dialogRes = CoolAlert.show(
      //     context: buildcontext,
      //     type: CoolAlertType.success,
      //     text: "Registration was successful!",
      //     onConfirmBtnTap: () => Navigator.pushAndRemoveUntil(
      //         context,
      //         MaterialPageRoute(builder: (context) => LoginPage()),
      //         ModalRoute.withName("/Login")));
    } else if (res.statusCode == 406) {
    } else {
      print("Registration failed");
      print(res.statusCode);
      print(res.body);
    }
  }

  Future checkToken() async {
    // String userName = validateForgotPasswordToken(token, refId)(userNameController.text);
    var res = await http.get(
      validateForgotPasswordToken(verifyToken.text, referenceId),
      headers: {
        'authorization': "Bearer " + jwToken,
      },
    );
    if (res.statusCode == 200) {
      Map parsed = json.decode(res.body);
      TokenValidate validateToken = TokenValidate.fromJson(parsed);
      if (validateToken.responseBody.validity) {
        setState(() {
          isInvalidToken = true;
        });
      }

      _currentStep < 2 ? setState(() => _currentStep += 1) : null;
    } else if (res.statusCode == 406) {
    } else {
      print("Registration failed");
      print(res.statusCode);
      print(res.body);
      setState(() {
        isInvalidToken = true;
      });
    }
  }

  Future resetPassword() async {
    // String userName = validateForgotPasswordToken(token, refId)(userNameController.text);
    Map data = {
      "referenceId": referenceId,
      "userName": userNameController.text,
      "password": passwordController.text,
      "confirmPassword": passwordController.text,
    };
    var res = await http.post(
      RESET_PASSWORD,
      body: jsonEncode(data),
      headers: {
        'authorization': "Bearer " + jwToken,
      },
    );
    if (res.statusCode == 200) {
      CoolAlert.show(
          context: context,
          type: CoolAlertType.success,
          text: "Password reset was successful!",
          onConfirmBtnTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
              ModalRoute.withName("/Login")));
    } else if (res.statusCode == 406) {
    } else {
      print("Registration failed");
      print(res.statusCode);
      print(res.body);
      setState(() {
        isInvalidToken = true;
      });
    }
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
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer(),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .2),
                    _title(),
                    SizedBox(
                      height: 50,
                    ),
                    Column(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints.tightFor(height: 450.0),
                          child: Stepper(
                              type: StepperType.horizontal,
                              physics: ScrollPhysics(),
                              onStepTapped: (step) => tapped(step),
                              onStepContinue: continued,
                              onStepCancel: _currentStep == 0 ? null : cancel,
                              currentStep: _currentStep,
                              steps: <Step>[
                                Step(
                                  isActive: _currentStep >= 0,
                                  state: _currentStep >= 0
                                      ? StepState.complete
                                      : StepState.disabled,
                                  title:
                                      Text(_currentStep == 0 ? "Request" : ""),
                                  content: Form(
                                      key: _requestForm,
                                      child: _requestResetPassword()),
                                ),
                                Step(
                                    isActive: _currentStep >= 1,
                                    state: _currentStep >= 1
                                        ? StepState.complete
                                        : StepState.disabled,
                                    title: Text(_currentStep == 1
                                        ? "Verify Token"
                                        : ""),
                                    content: Form(
                                        key: _tokenVerfyForm,
                                        child: _validateToken())),
                                Step(
                                    isActive: _currentStep >= 2,
                                    state: _currentStep >= 2
                                        ? StepState.complete
                                        : StepState.disabled,
                                    title: Text(_currentStep == 2
                                        ? "Reset Password"
                                        : ""),
                                    content: Form(
                                        key: _resetForm,
                                        child: _resetPassword(
                                            buildContext: context)))
                              ]),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                    // SizedBox(height: height * .05),
                    _loginAccountLabel(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
