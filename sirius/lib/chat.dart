import 'dart:io';
import 'package:sirius/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:align_positioned/align_positioned.dart';
class Chat extends StatefulWidget {

final String s;
final String r;
  Chat({this.s,this.r});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  FocusNode nod;
  String chatRoomId;
  Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  String time = DateFormat.jm().format(DateTime.now());
  ScrollController _controller = ScrollController();
  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
          controller: _controller,
          scrollDirection: Axis.vertical,
            reverse: true,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              return MessageTile(
                message: snapshot.data.documents[index].data["message"],
                sendByMe: widget.s ==
                    snapshot.data.documents[index].data["sendBy"],
                name: snapshot.data.documents[index].data["sendBy"],
                time: snapshot.data.documents[index].data["time2"],
              );
            })
            : Container();
      },
    );
  }

  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      setState(() {
        time=DateFormat.jm().format(DateTime.now());
      });
      Map<String, dynamic> chatMessageMap = {
        "sendBy": widget.s,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
        'time2': time
      };

      DatabaseMethods().addMessage(chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      });
    }
  }

  @override
  void initState() {
    chatRoomId=widget.s.compareTo(widget.r)==1?"${widget.s}\_${widget.r}":"${widget.r}\_${widget.s}";
    DatabaseMethods().getChats(chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.r,style: TextStyle(color: Colors.white),) ,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(child:
            Container(child: chatMessages())),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            widget.sendByMe? SizedBox(width: 0.0,height: 0.0,):Text(widget.name,
              style: TextStyle(color: Colors.greenAccent,
                  fontSize: 14,
              fontWeight: FontWeight.bold
              ),),
            Text("${widget.message}",
                //textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300)),
Text(widget.time,
style: TextStyle(
  fontSize: 9.0
),
)
          ],
        ),

      ),
    );
  }
}
// class MessageTile extends StatelessWidget {
//   final String message;
//   final bool sendByMe;
//   final String name;
//   final String time;
//
//   MessageTile(
//       {@required this.message, @required this.sendByMe, @required this.name, @required this.time});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.only(
//           top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
//       alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin:
//         sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
//         padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
//         decoration: BoxDecoration(
//             borderRadius: sendByMe
//                 ? BorderRadius.only(
//                 topLeft: Radius.circular(23),
//                 topRight: Radius.circular(23),
//                 bottomLeft: Radius.circular(23))
//                 : BorderRadius.only(
//                 topLeft: Radius.circular(23),
//                 topRight: Radius.circular(23),
//                 bottomRight: Radius.circular(23)),
//             gradient: LinearGradient(
//               colors: sendByMe
//                   ? [const Color(0xff4e342e), const Color(0xff3e2723)]
//                   : [const Color(0x1AFFFFFF), const Color(0x1AFFFFFF)],
//             )),
//         child: Text("${message}\n${time}",
//             textAlign: TextAlign.start,
//             style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//                 fontFamily: 'OverpassRegular',
//                 fontWeight: FontWeight.w300)),
//       ),
//     );
//   }
// }
