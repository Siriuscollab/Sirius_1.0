import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:sirius/phone.dart';
import 'package:sirius/sign_in.dart';
import 'package:firebase_database/firebase_database.dart';

import 'homee.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading =false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final dbref= FirebaseDatabase.instance.reference();
  TextEditingController _username= new TextEditingController();
  TextEditingController _phone= new TextEditingController();
  String _email, _password, _password1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: isLoading ? Container(child: Center(child: CircularProgressIndicator(),),) : SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _username,
                  validator: (input) {
                    if(input.isEmpty){
                      return 'Provide an email';
                    }
                  },
                  decoration: InputDecoration(
                      labelText: 'Username'
                  ),

                ),
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
                  controller: _phone,
                  validator: (input) {
                    if(input.isEmpty){
                      return 'phone number cannot be empty';
                    }
                  },
                  decoration: InputDecoration(
                      labelText: 'Enter Your Phone number'
                  ),

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
                TextFormField(
                  validator: (input) {
                    if(input.length < 6){
                      return 'Longer password please';
                    }
                  },
                  decoration: InputDecoration(
                      labelText: 'Re-enter Password'
                  ),
                  onSaved: (input) => _password1 = input,
                  obscureText: true,
                ),

                RaisedButton(
                  onPressed: signUp,
                  child: Text('Sign up'),
                ),
              ],
            )
        ),
      ),
    );
  }

  void signUp() async {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      setState(() {

        isLoading = true;
      });
      try{
        if( _password== _password1) {
          FirebaseAuth _auth= FirebaseAuth.instance;
          AuthResult result=await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
          if(result!=null) {
            FirebaseUser user= await FirebaseAuth.instance.currentUser();
            await dbref.child('users').child(user.uid).set({
              'email': _email,
              'username': _username.text,
              'phone': _phone.text,
            });
          }
          Phoneauth();
          Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
        }
      }catch(e){
        print(e.message);
      }
    }
  }
  Future<bool> Phoneauth() async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    final _codeController = TextEditingController();

    _auth.verifyPhoneNumber(
        phoneNumber: _phone.text,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) async{
          Navigator.of(context).pop();

          AuthResult result = await _auth.signInWithCredential(credential);

          FirebaseUser user = result.user;

          if(user != null){
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => Home()));
          }else{
            print("Error");
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (AuthException exception){
          print(exception);
        },
        codeSent: (String verificationId, [int forceResendingToken]){
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: Text("Give the code?"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _codeController,
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Confirm"),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () async{
                        final code = _codeController.text.trim();
                        AuthCredential credential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: code);

                        AuthResult result = await _auth.signInWithCredential(credential);

                        FirebaseUser user = result.user;

                        if(user != null){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => Home()
                          ));
                        }else{
                          print("Error");
                        }
                      },
                    )
                  ],
                );
              }
          );
        },
        codeAutoRetrievalTimeout: null
    );
  }
}