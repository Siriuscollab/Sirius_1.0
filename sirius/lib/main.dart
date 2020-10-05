// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:sirius/autenticate.dart';
// import 'package:sirius/sign_in.dart';
// void main() => runApp(MaterialApp(
//   routes: {
//     '/': (context) => SignIn(),
//     '/signin': (context) => SignIn(),
//   },
// ));
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sirius/helper/authenticate.dart';
import 'package:sirius/helper/helperfunctions.dart';
import 'package:flutter/material.dart';
import 'package:sirius/homee.dart';
import 'package:sirius/sign_in.dart';
import 'package:sirius/team.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  bool userIsLoggedIn=false;
String uid;
String token;
  final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>(); // To be used as navigator
  @override
   void initState()  {
    _fcm.configure(
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
       handleClickedNotification(message);
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        print('uiiid');
        print(uid);
        print('uiiid');
        print(message['data']['pid']);
        // TODO optional
        uid=await HelperFunctions.getUserNameSharedPreference();
        handleClickedNotification(message);
      },
    );
    getLoggedInState();
    super.initState();
  }

  getLoggedInState() async {
    token=await HelperFunctions.getUserTokenSharedPreference();
    uid=await HelperFunctions.getUserNameSharedPreference();
    await HelperFunctions.getUserLoggedInSharedPreference().then((value){
      setState(() {
        userIsLoggedIn  = value;
      });
    });
  }
  handleClickedNotification(message) async {
    // Put your logic here before redirecting to your material page route if you want too
    uid=await HelperFunctions.getUserNameSharedPreference();
    navigatorKey.currentState.pushReplacement(MaterialPageRoute(builder: (context) => Team(
        projectId:
        message['data']['pid'],
        userr: uid)));
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'FlutterChat',
      //hello sudheer
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFFFFFFF),
        scaffoldBackgroundColor: Color(0xFFbdb9a6),
        accentColor: Color(0xFF4FF5F5),
        fontFamily: "OverpassRegular",
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: userIsLoggedIn != null ? userIsLoggedIn ? Home(uid:uid ,token: token) : SignIn():SignIn());
  }
}

