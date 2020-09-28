import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sirius/accept%20.dart';
class Profile extends StatefulWidget {
  final uid;
  Profile({this.uid});
  @override
  _ProfileState createState() => _ProfileState();
}
class _ProfileState extends State<Profile> {
  @override
  final dbref=FirebaseDatabase.instance.reference().child('users');
  void initState() {
    dbref.child(widget.uid).child('username').once().then((snapshot){username=snapshot.value;});
    dbref.child(widget.uid).child('email').once().then((snapshot){mail=snapshot.value;});
    super.initState();
  }
  String username,mail;
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage('images/download.png'),
            ),
          SizedBox(
            height: 20.0,
            width: 250.0,
            child: Divider(
              color: Colors.grey,
            ),
          ),
            Text(
              '$username',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20.0,
              width: 250.0,
              child: Divider(
                color: Colors.grey,
              ),
            ),
            Text(
              '$mail',
              style: TextStyle(
                fontSize: 25.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20.0,
              width: 250.0,
              child: Divider(
                color: Colors.grey,
              ),
            ),
            RaisedButton(
              child: Text(
                'Requests',
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) =>Accept(uid: widget.uid)));
              },
            )

          ],
        )
      )
    );
  }
}
