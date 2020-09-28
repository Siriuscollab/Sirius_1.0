import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
class Request extends StatefulWidget {
  final uid;
  final pid;
  Request({this.uid,this.pid});
  @override
  _RequestState createState() => _RequestState();
}

class _RequestState extends State<Request> {
  final dr=FirebaseDatabase.instance.reference().child('requests');
  final du=FirebaseDatabase.instance.reference().child('users');
  var un=[];
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
            var ui=[];
            var uin=[];
            uin.clear();
            ui.clear();
            if(snapshot.data.snapshot.value==null){
              return Text('No Requests');
            }
            DataSnapshot sp=snapshot.data.snapshot;
            Map<dynamic,dynamic> val=sp.value;
            val.forEach((key, value) {
              ui.add(key);
            });
            val.forEach((key, value) {
              du.child(key).once().then((value1) {
                uin.add(value1.value['username']);
                setState(() {
                  un=uin;
                });
              });
            });
            if(un==[]){
             return Text('Null');
            }
            if(un==null){
              return Text('Null');
            }
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
                                onPressed: (){},
                              ),
                              FlatButton(
                                child: Text('Reject'),
                                onPressed: (){},
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                });
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

