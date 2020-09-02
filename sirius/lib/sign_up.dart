import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sirius/sign_in.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading =false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password, _email1, _password1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: isLoading ? Container(child: Center(child: CircularProgressIndicator(),),) : Form(
          key: _formKey,
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
                  if(input.isEmpty){
                    return 'confirm your email';
                  }
                },
                decoration: InputDecoration(
                    labelText: 'confirm your Email'
                ),
                onSaved: (input) => _email1 = input,
                obscureText: true,
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
    );
  }

  void signUp() async {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      // setState(() {
      //
      //   isLoading = true;
      // });
      try{
        if(_email == _email1 && _password== _password1) {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _email, password: _password);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => SignIn()));
        }
      }catch(e){
        print(e.message);
      }
    }
  }
}