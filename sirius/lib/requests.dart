import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:sirius/chat.dart';
class Request extends StatefulWidget {
  final uid;
  final pid;
  Request({this.uid,this.pid});
  @override
  _RequestState createState() => _RequestState();
}

class _RequestState extends State<Request> {
  final dr=FirebaseDatabase.instance.reference().child('requests');
  final dbref3=FirebaseDatabase.instance.reference().child('requested');
  final du=FirebaseDatabase.instance.reference().child('users');
  final pu=FirebaseDatabase.instance.reference().child('proj_users');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requests"),
      ),
      body: StreamBuilder(
        stream: dr.child(widget.uid).child(widget.pid).onValue,
        builder: (context,AsyncSnapshot<Event> snapshot){
          if(snapshot.hasData){
            if(snapshot.data.snapshot.value==null) {
              return Text('No Requests for this project');
            }
            var uin=[];
            uin.clear();
            DataSnapshot sp=snapshot.data.snapshot;
            Map<dynamic,dynamic> val=sp.value;
            return StreamBuilder(
              stream: du.onValue,
              builder: (context,AsyncSnapshot<Event> snapshot1){
                if(snapshot1.hasData){
                  if(snapshot1.data.snapshot.value==null) {
                    return Text('No Requests for this project');
                  }
                  var un=[];
                  var ui=[];
                  var kee=[];
                  kee.clear();
                  ui.clear();
                  un.clear();
                  DataSnapshot sjp=snapshot1.data.snapshot;
                  Map<dynamic,dynamic> vals=sjp.value;
                  val.forEach((key, value) {
             un.add(vals[key]['username']);
             kee.add(key);
          });
                  print(un);
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: un.length,
                      itemBuilder: (context,int index){
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)
                          ),
                          color: Colors.white70,
                          elevation: 8.0,
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading:Text('Request${index}'),
                                title: Text(un[index]),
                              ),
                              ButtonTheme(
                                child: ButtonBar(
                                  children: <Widget>[
                                    FlatButton(
                                      child: Text('Accept'),
                                      onPressed: () async {
                                        FirebaseUser user= await FirebaseAuth.instance.currentUser();
                                        final dbref1=FirebaseDatabase.instance.reference().child('assoc');
                                        final dbref2=FirebaseDatabase.instance.reference().child('users');
                                        DataSnapshot spp=await dbref2.child(kee[index]).once();
                                        Map<dynamic,dynamic> usr=spp.value;
                                        pu.child(widget.pid).child(kee[index]).set({
                                          'joined':1
                                        });
                                        Firestore.instance
                                            .collection('projectRoom').document(widget.pid)
                                            .updateData({'users':FieldValue.arrayUnion([usr['username']])});
                                        dbref1.child(kee[index])
                                            .child(widget.pid).set({
                                          'admin':0
                                        });
                                        DataSnapshot uspp=await dbref3.child(kee[index]).child(widget.pid).once();
                                        Map<dynamic,dynamic> test=uspp.value;
                                        test.forEach((key, value) {
                                          Firestore.instance.collection("projectRoom")
                                              .document(widget.pid).collection('devtokens').document(key).setData({'token':key});
                                        });
                                        await dbref3.child(kee[index]).child(widget.pid).remove();
                                        await dr.child(widget.uid).child(widget.pid).child(kee[index]).remove();
                                        print('success');
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Reject'),
                                      onPressed: () async {
                                        await dbref3.child(kee[index]).child(widget.pid).remove();
                                        await dr.child(widget.uid).child(widget.pid).child(kee[index]).remove();
                                      },
                                    ),
                                    FlatButton(
                                      onPressed: () async {
                                        DataSnapshot u1=await du.child(widget.uid).once();

                                        Map<dynamic,dynamic> v1,v2;
                                        v1=u1.value;

                                        print(un[index]);
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Chat(s:v1['username'],r:un[index])));
                                      },
                                      child: Text('Talk With Him'),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                }
                return CircularProgressIndicator();
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
// class req extends StatefulWidget {
//   final uid;
//   final pid;
//   req({this.uid,this.pid});
//   @override
//   _reqState createState() => _reqState();
// }
//
// class _reqState extends State<req> {
//
//
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }

