import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:sirius/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:sirius/people.dart';
import 'package:sirius/call.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/feature_flag/feature_flag_enum.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/jitsi_meeting_listener.dart';
import 'package:jitsi_meet/room_name_constraint.dart';
import 'package:jitsi_meet/room_name_constraint_type.dart';
class Team extends StatefulWidget {
  final String projectId;
  final userr;
  Team({this.projectId,this.userr});
  @override
  _TeamState createState() => _TeamState();
}

class _TeamState extends State<Team> {
  final serverText = TextEditingController();
  String roomText ;
  final subjectText = TextEditingController(text: "My Plugin Test Meeting");
  final nameText = TextEditingController(text: "Plugin Test User");
  final emailText = TextEditingController(text: "fake@email.com");
  var isAudioOnly = true;
  var isAudioMuted = false;
  var isVideoMuted = true;
  FocusNode nod;
  final db = FirebaseDatabase.instance.reference().child('users');
  final db1 = FirebaseDatabase.instance.reference().child('projects');
  Stream<QuerySnapshot> chats;
  ScrollController _controller = ScrollController();
  TextEditingController messageEditingController = new TextEditingController();
Map<dynamic,dynamic> user_v;
  Map<dynamic,dynamic> proj;
  String time = DateFormat.jm().format( DateTime.now());
  String projname;
 String myname="proj";
  Widget chatMessages(){
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot){
        return snapshot.hasData ?  ListView.builder(
          padding: EdgeInsets.only(bottom: 10.0),
          controller: _controller,
          scrollDirection: Axis.vertical,
            shrinkWrap: true,
            reverse: true,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index){
              return MessageTile(
                message: snapshot.data.documents[index].data["message"],
                sendByMe: myname == snapshot.data.documents[index].data["sendBy"],
                name: snapshot.data.documents[index].data["sendBy"],
                time: snapshot.data.documents[index].data["time2"],
              );
            }) : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      setState(() {
        time= DateFormat.jm().format( DateTime.now());
      });
      Map<String, dynamic> chatMessageMap = {
        "sendBy": myname,
        "message": messageEditingController.text,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
        'time2': time
      };

      DatabaseMethods().addMessage2(widget.projectId, chatMessageMap);
      print('kk');
      setState(() {
        messageEditingController.text = "";
        // Timer(
        //     Duration(milliseconds: 300),
        //         () => _controller
        //         .jumpTo(_controller.position.maxScrollExtent));
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      });
    }
  }
  @override
  void dispose() {
    super.dispose();
    JitsiMeet.removeAllListeners();
  }
  _onAudioOnlyChanged(bool value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
  }
  @override
  void initState() {
    roomText=widget.projectId;
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
    final dbref3=FirebaseDatabase.instance.reference().child('users');
    final dbref4=FirebaseDatabase.instance.reference().child('projects');
    dbref3.child(widget.userr).once().then((value1) {
      dbref4.child(widget.projectId).once().then((value) {
        proj=value.value;
        user_v=value1.value;
        DatabaseMethods().getChats2(widget.projectId).then((val) {
          setState(() {
            myname=user_v['username'];
            print(user_v);
            print(widget.userr);
            projname=proj['title'];
            chats = val;
            // Timer(`
            //     Duration(milliseconds: 300),
            //         () => _controller
            //         .jumpTo(_controller.position.maxScrollExtent));
          });
        });
      });
    });

    super.initState();
  }
  _joinMeeting() async {
    DataSnapshot usr=await db.child(widget.userr).once();
    Map<dynamic,dynamic> usrr=usr.value;
    DataSnapshot pro=await db1.child(widget.projectId).once();
    Map<dynamic,dynamic> proo=pro.value;
    String serverUrl =
    serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;

    try {
      // Enable or disable any feature flag here
      // If feature flag are not provided, default values will be used
      // Full list of feature flags (and defaults) available in the README
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
      };

      // Here is an example, disabling features for each platform
      if (Platform.isAndroid) {
        // Disable ConnectionService usage on Android to avoid issues (see README)
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      } else if (Platform.isIOS) {
        // Disable PIP on iOS as it looks weird
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions()
        ..room = roomText
        ..serverURL = serverUrl
        ..subject = proo['title']
        ..userDisplayName = usrr['username']
        ..userEmail = emailText.text
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted
        ..featureFlags.addAll(featureFlags);

      debugPrint("JitsiMeetingOptions: $options");
      await JitsiMeet.joinMeeting(
        options,
        listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
          debugPrint("${options.room} will join with message: $message");
        }, onConferenceJoined: ({message}) {
          debugPrint("${options.room} joined with message: $message");
        }, onConferenceTerminated: ({message}) {
          debugPrint("${options.room} terminated with message: $message");
        }),
        // by default, plugin default constraints are used
        //roomNameConstraints: new Map(), // to disable all constraints
        //roomNameConstraints: customContraints, // to use your own constraint(s)
      );
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  static final Map<RoomNameConstraintType, RoomNameConstraint>
  customContraints = {
    RoomNameConstraintType.MAX_LENGTH: new RoomNameConstraint((value) {
      return value.trim().length <= 50;
    }, "Maximum room name length should be 30."),
    RoomNameConstraintType.FORBIDDEN_CHARS: new RoomNameConstraint((value) {
      return RegExp(r"[$€£]+", caseSensitive: false, multiLine: false)
          .hasMatch(value) ==
          false;
    }, "Currencies characters aren't allowed in room names."),
  };

  void _onConferenceWillJoin({message}) {
    debugPrint("_onConferenceWillJoin broadcasted with message: $message");
  }

  void _onConferenceJoined({message}) {
    debugPrint("_onConferenceJoined broadcasted with message: $message");
  }

  void _onConferenceTerminated({message}) {
    debugPrint("_onConferenceTerminated broadcasted with message: $message");
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:projname==null?Text('Loading'):Text(projname),
        backgroundColor: Colors.grey,
        elevation: 0.0,
        actions: [
          GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => People(projectId: widget.projectId,user:user_v['username'])
                    ));
              },
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.group)
              )),
          GestureDetector(
              onTap: (){
               _joinMeeting();
              },
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.video_call)
              )),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[

                   Expanded(
                     child: Container(
                         child:  chatMessages()),
                   ),

            Container(alignment: Alignment.bottomCenter,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                color:Colors.greenAccent,
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          controller: messageEditingController,
                          maxLines: null,
                          style: TextStyle(color: Colors.teal, fontSize: 16),
                          decoration: InputDecoration(
                              hintText: "Message ...",
                              hintStyle: TextStyle(
                                color: Colors.teal,
                                fontSize: 16,
                              ),
                              border: InputBorder.none
                          ),
                        )),
                    SizedBox(width: 16,),
                    GestureDetector(
                      onTap: () {
                        addMessage();
                      },
                      child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    const Color(0x36F0FFFF),
                                    const Color(0x0FFFFFFF)
                                  ],
                                  begin: FractionalOffset.topLeft,
                                  end: FractionalOffset.bottomRight
                              ),
                              borderRadius: BorderRadius.circular(40)
                          ),
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.send
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessageTile extends StatefulWidget {
  final String message;
  final bool sendByMe;
  final String name;
  final String time;

  MessageTile({@required this.message, @required this.sendByMe,@required this.name,@required this.time});

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: widget.sendByMe ? 0 : 24,
          right: widget.sendByMe ? 24 : 0),
      alignment: widget.sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sendByMe
            ? EdgeInsets.only(left: 30)
            : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(
            top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: widget.sendByMe ? BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomLeft: Radius.circular(23)
            ) :
            BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: widget.sendByMe ? [
                const Color(0xFFa39568),
                const Color(0xFFa39568)
              ]
                  : [
                const Color(0xff4e868a),
                const Color(0xff4e868a)
              ],
            )
        ),
        child: Column(

          children: [
            widget.sendByMe? SizedBox(width: 0.0,height: 0.0,):Text(widget.name,
              style: TextStyle(color: Colors.white,
                  fontSize: 12),),
            Text("${widget.message}\n ${widget.time}",
                //textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300)),
          ],
        ),

      ),
    );
  }
}
