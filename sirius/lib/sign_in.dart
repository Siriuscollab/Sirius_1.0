import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sirius/homee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sirius/sign_up.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sirius/helper/helperfunctions.dart';
class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading =false;
  String _email, _password;
  final dbref2=FirebaseDatabase.instance.reference().child('assoc');
  final dbref3=FirebaseDatabase.instance.reference().child('requested');
  final dbref=FirebaseDatabase.instance.reference().child('users');
  final GlobalKey<FormState> _formkey= GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: isLoading ? Container(child: Center(child: CircularProgressIndicator(),),) : Form(
        key:_formkey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (input) {
                  if(input.isEmpty){
                    return 'Provide an email';
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Email'
                ),
                onSaved: (input) => _email = input,
              ),
              TextFormField(
                validator: (input) {
                  if(input.length < 6){
                    return 'Longer password please';
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Password'
                ),
                onSaved: (input) => _password = input,
                obscureText: true,
              ),
              SizedBox(height: 10.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    onPressed: signn,
                    child: Text('Sign in'),
                  ),
                  RaisedButton(
                    onPressed: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=> SignUp(), fullscreenDialog: true));
                    },
                    child: Text('Sign Up'),
                  )
                ],
              )

            ],
          ),
        ),
      ),
    );
  }

  void signn() async {
    if(_formkey.currentState.validate()){
      _formkey.currentState.save();
      setState(() {

        isLoading = true;
      });
      try{
        FirebaseUser user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password)).user;
        FirebaseMessaging _messaging= FirebaseMessaging();
        DataSnapshot use_r=await dbref.child(user.uid).once();
        Map<dynamic,dynamic> use_det=use_r.value;
        _messaging.getToken().then((token) async {
          print('hello'+token+'end');
          Firestore.instance.collection(use_det['username'])
              .document(token).setData({'token':token});
          DataSnapshot asp= await dbref3.child(user.uid).once();
          Map<dynamic,dynamic> mpp=asp.value;
          if(mpp!=null){
          mpp.forEach((key, value) {
              dbref3.child(user.uid).child(key).child(token).set({
                'requested':1
              });
          });}
          dbref2.child(user.uid).once().then((value) {
            if(value.value==null){
              HelperFunctions.saveUserLoggedInSharedPreference(true);
              HelperFunctions.saveUserToken(token);
              HelperFunctions.saveUserNameSharedPreference(
                  user.uid);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(uid:user.uid,token:token)));
            }
            else{
            Map<dynamic,dynamic> vall=value.value;
          vall.forEach((key, value) {
            Firestore.instance.collection("projectRoom")
                .document(key).collection('devtokens').document(token).setData({'token':token});
          });

            HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserToken(token);
            HelperFunctions.saveUserNameSharedPreference(
               user.uid);
          print(token);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home(uid:user.uid,token:token)));}
          });
        });
      }catch(e){
        print(e.message);
      }
    }
  }
}