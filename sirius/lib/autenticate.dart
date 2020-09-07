import 'package:flutter/material.dart';
import 'package:sirius/sign_in.dart';
import 'package:sirius/sign_up.dart';
class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome Bro'),
          backgroundColor: Colors.deepOrangeAccent,
        ),
        body: Center(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text('Sign in'),
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context)=> SignIn(), fullscreenDialog: true));
                  },
                  textColor: Colors.blueAccent,
                ),
                RaisedButton(
                  child: Text('Sign up'),
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context)=> SignUp(), fullscreenDialog: true));
                  },
                  textColor: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}