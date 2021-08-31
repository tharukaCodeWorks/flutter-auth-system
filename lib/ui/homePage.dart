import 'package:flutter/material.dart';
import 'package:flutter_login_signup/main.dart';
import 'package:flutter_login_signup/ui/loginPage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future logoutFunction() async {
    await storage.delete(key: 'jwt');
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        ModalRoute.withName("/Login"));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: TextButton(
          child: Text("Logout"),
          onPressed: logoutFunction,
        ),
      ),
    );
  }
}
