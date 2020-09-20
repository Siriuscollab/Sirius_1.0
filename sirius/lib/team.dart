import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:sirius/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:sirius/people.dart';

class Team extends StatefulWidget {
  final String projectId;
  final userr;
  Team({this.projectId,this.userr});
  @override
  _TeamState createState() => _TeamState();
}

class _TeamState extends State<Team> {
  FocusNode nod;
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
  void initState() {
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