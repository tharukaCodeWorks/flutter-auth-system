import 'dart:convert';
import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_signup/config/apiConfig.dart';
import 'package:flutter_login_signup/model/login.dart';
import 'package:flutter_login_signup/ui/Widget/bezierContainer.dart';
import 'package:flutter_login_signup/ui/loginPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _personal1 = GlobalKey<FormState>();
  final _personal2 = GlobalKey<FormState>();
  final _account = GlobalKey<FormState>();

  TextEditingController userNameController = TextEditingController();
  TextEditingController referalCodeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController birthDay = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  int _currentStep = 0;
  int genderIndex = 0;
  DateTime selectedDate = DateTime.now();
  String jwToken;

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

  Widget _countrySelectField(String title) {
    return Row(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Expanded(
          flex: 1,
          child: CountryListPick(
            appBar: AppBar(
              backgroundColor: Color(0xff459bff),
              title: Text('Pick your country'),
            ),
            theme: CountryTheme(
              isShowFlag: true,
              isShowTitle: true,
              isShowCode: false,
              isDownIcon: true,
              showEnglishName: false,
              labelColor: Color(0xff459bff),
            ),
            initialSelection: '+61',
            // or
            // initialSelection: 'US'
            onChanged: (CountryCode code) {
              print(code.name);
              print(code.dialCode);
            },
          ),
        )
      ],
    );
  }

  Widget _selectField(
    String title,
    List<String> itemList,
  ) {
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
              DropdownButtonFormField(
                  onChanged: (String value) {
                    setState(() {
                      genderIndex = itemList.indexOf(value);
                    });
                  },
                  value: itemList[genderIndex],
                  hint: Text("Select Gender"),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      fillColor: Color(0xfff3f3f4),
                      filled: true),
                  items: itemList
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Row(
                              children: <Widget>[Text(e)],
                            ),
                          ))
                      .toList()),
            ]));
  }

  Widget _submitButton({BuildContext buildcontext}) {
    return ElevatedButton(
        style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent)),
        onPressed: () {
          generateToken(buildcontext: buildcontext);
          // Validate returns true if the form is valid, or false otherwise.
          // if (_formKey.currentState.validate()) {
          //   // If the form is valid, display a snackbar. In the real world,
          //   // you'd often call a server or save the information in a database.
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(content: Text('Processing Data')),
          //   );
          // }
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
            'Register Now',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ));
  }

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

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Username", userNameController),
        _entryField("Email id", emailController, isEmail: true),
        _entryField("Referral Code", referalCodeController),
        _entryField("Password", passwordController, isPassword: true),
      ],
    );
  }

  Widget _personalDetails1() {
    List<String> genders = ["Male", "Female"];
    return Column(
      children: <Widget>[
        _entryField("First Name", firstNameController),
        _entryField("Last Name", lastNameController),
        _selectField("Gender", genders)
      ],
    );
  }

  Widget _personalDetails2({BuildContext buildContext}) {
    return Column(
      children: <Widget>[
        _entryField("Birthday", birthDay,
            buildContext: buildContext, enable: false, onTap: _selectDate),
        // _entryField("Country"),
        _countrySelectField("Country"),
        _entryField("Contact Number", contactNumber),
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
          if (_account.currentState.validate()) {
            // If the form is valid, display a snackbar. In the real world,
            // you'd often call a server or save the information in a database.
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text('Processing Data')),
            // );
            _currentStep < 3 ? setState(() => _currentStep += 1) : null;
          }
        }
        break;

      case 1:
        {
          {
            if (_personal1.currentState.validate()) {
              // If the form is valid, display a snackbar. In the real world,
              // you'd often call a server or save the information in a database.
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Processing Data')),
              // );
              _currentStep < 3 ? setState(() => _currentStep += 1) : null;
            }
          }
        }
        break;
      case 2:
        {
          {
            if (_personal2.currentState.validate()) {
              // If the form is valid, display a snackbar. In the real world,
              // you'd often call a server or save the information in a database.
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Processing Data')),
              // );
              _currentStep < 3 ? setState(() => _currentStep += 1) : null;
            }
          }
        }
        break;
    }
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: DateTime(1940, 1),
        lastDate: new DateTime.now());
    if (picked != null && picked != selectedDate)
      birthDay.text = picked.toString().split(" ")[0];
    setState(() {
      selectedDate = picked;
    });
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
      registerUser(loginResponse.responseBody.accessToken,
          buildcontext: buildcontext);
    } else if (res.statusCode == 406) {
    } else {}
  }

  Future registerUser(String token, {BuildContext buildcontext}) async {
    print("-----------------------");

    print(selectedDate.toLocal().toString().split(" ")[0]);
    print(
      contactNumber.text,
    );
    print(countryName);
    print(emailController.text);
    print(firstNameController.text);
    print(genderIndex == 0 ? 'Male' : 'Female');
    print(lastNameController.text);
    print(referalCodeController.text);
    print(userNameController.text);
    print(passwordController.text);
    // print(selectedDate.toString().split(" ")[0]);

    print("-----------------------");
    Map data = {
      "birthday": selectedDate.toString().split(" ")[0],
      "contactNo": contactNumber.text,
      "country": countryName,
      "email": emailController.text,
      "firstName": firstNameController.text,
      "gender": genderIndex == 0 ? 'Male' : 'Female',
      "lastName": lastNameController.text,
      "referralCode": referalCodeController.text,
      "userName": userNameController.text,
      "password": passwordController.text,
      "confirmPassword": passwordController.text
    };
    var res = await http.post("$REGISTER",
        headers: {
          "Content-Type": "application/json",
          'authorization': "Bearer " + token,
        },
        encoding: Encoding.getByName("utf-8"),
        body: jsonEncode(data));
    if (res.statusCode == 201) {
      print("Registered Successfully");
      CoolAlert.show(
          context: buildcontext,
          type: CoolAlertType.success,
          text: "Registration was successful!",
          onConfirmBtnTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
              ModalRoute.withName("/Login")));
    } else if (res.statusCode == 406) {
    } else {
      print("Registration failed");
      print(res.statusCode);
      print(res.body);
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
                              onStepContinue:
                                  _currentStep == 3 ? null : continued,
                              onStepCancel: _currentStep == 0 ? null : cancel,
                              currentStep: _currentStep,
                              steps: <Step>[
                                Step(
                                  isActive: _currentStep >= 0,
                                  state: _currentStep >= 0
                                      ? StepState.complete
                                      : StepState.disabled,
                                  title:
                                      Text(_currentStep == 0 ? "Account" : ""),
                                  content: Form(
                                      key: _account,
                                      child: _emailPasswordWidget()),
                                ),
                                Step(
                                    isActive: _currentStep >= 1,
                                    state: _currentStep >= 1
                                        ? StepState.complete
                                        : StepState.disabled,
                                    title: Text(
                                        _currentStep == 1 ? "Personal" : ""),
                                    content: Form(
                                        key: _personal1,
                                        child: _personalDetails1())),
                                Step(
                                    isActive: _currentStep >= 2,
                                    state: _currentStep >= 2
                                        ? StepState.complete
                                        : StepState.disabled,
                                    title: Text(
                                        _currentStep == 2 ? "Personal" : ""),
                                    content: Form(
                                        key: _personal2,
                                        child: _personalDetails2(
                                            buildContext: context))),
                                Step(
                                  isActive: _currentStep >= 3,
                                  state: _currentStep >= 3
                                      ? StepState.complete
                                      : StepState.disabled,
                                  title:
                                      Text(_currentStep == 3 ? "Finish" : ""),
                                  content: _submitButton(buildcontext: context),
                                )
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
