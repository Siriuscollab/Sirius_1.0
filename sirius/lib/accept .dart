import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// import 'package:sirius/scrap.dart';
import 'package:sirius/chat.dart';
class Accept extends StatefulWidget {
  final String uid;
  Accept({this.uid});
  @override
  _AcceptState createState() => _AcceptState();
}
class _AcceptState extends State<Accept> {
  var _index=0;
  dynamic k=0;
  final dbref=FirebaseDatabase.instance.reference().child('requests1');
  final dbref3=FirebaseDatabase.instance.reference().child('sentrequests');
  final dbref1=FirebaseDatabase.instance.reference().child('users');
  final dbref2=FirebaseDatabase.instance.reference().child('projects');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
      ),
      body: IndexedStack(
        index: _index,
        children: <Widget>[
         StreamBuilder (
           stream: dbref.child(widget.uid).onValue,
           builder: (context, AsyncSnapshot<Event> snapshot) {
            if(snapshot.hasData){
              var lists=[];
              var keys=[];
              int head=0;
              //print(snapshot.data.snapshot.value.length);
              DataSnapshot dataValues = snapshot.data.snapshot;

              Map<dynamic, dynamic> values = dataValues.value;
              if(values==null){
                return Container(
                    child:Text('No Requests for you')
                );
              }
              values.forEach((key, values) {
                lists.add(values);
                keys.add(key);
              });
              print(lists);
              List<List<dynamic>> final_users=[];
              List<List<dynamic>> final_push=[];
              List<List<dynamic>> user_names=[];
              var proj_names = [];
              Future<List<List<dynamic>>> get_usernames() async {
                for (var i = 0; i < lists.length; i++) {
                  dynamic l=[];
                  dynamic push=[];
                  dynamic users1=[];
                  Map<dynamic, dynamic> users = lists[i];
                  for(var uid in users.values){
                    String uname;
                    uid=uid.toString();
                    l.add(uid);
                    await dbref1.child(uid).child('username').once().then((snapshot) {uname=snapshot.value;});
                    users1.add(uname);
                  }
                  for(var push1 in users.keys)
                    {
                      push.add(push1);
                    }
                  final_users.add(l);
                  user_names.add(users1);
                  final_push.add(push);
                }
                for(var pid in keys)  {
                  String uname1;
                  pid = pid.toString();
                  await dbref2.child(pid).child('title').once().then((
                      snapshot) {
                    uname1=snapshot.value;
                  });
                  proj_names.add(uname1);
                }
                 return user_names;
              }
              delete_request(dpid,duid) async {
                dbref.child(widget.uid).child(dpid).child(duid).remove().then((_){
                  print('request removed');
                });
              }

              return FutureBuilder(
                future: get_usernames(),
                builder: (BuildContext context,AsyncSnapshot Snapshot) {
                  if(Snapshot.data==null)
                    {
                      return Container(
                        child: Text('loading'),
                      );
                    }
                  else {
                    return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: lists.length,
                        itemBuilder: (BuildContext context, int index) {
                          //print(lists[index].length);
                          return ListView.builder(
                              //scrollDirection: Axis.vertical,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: lists[index].length,
                          itemBuilder:(BuildContext,index1){
                          print(index1);
                          return user_names.isEmpty
                              ? Center(child: Text(''),)
                              : Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 150,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.0)
                                  ),
                                  color: Colors.white70,
                                  elevation: 8.0,
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        title: Text(user_names[index][index1]),
                                        leading: Text(proj_names[index]),
                                        subtitle: Text('requested you'),
                                      ),
                                      ButtonTheme(
                                        child: ButtonBar(
                                          children: <Widget>[
                                            FlatButton(
                                              child: Text('Talk with him'),
                                              onPressed: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(builder: (
                                                        context) =>
                                                        Chat(s: widget.uid,
                                                            r: final_users[index][index1])));
                                              },
                                            ),
                                            SizedBox(
                                              width: 50.0,
                                              height: 50.0,
                                              child: FloatingActionButton(
                                                heroTag: 'one+$head',
                                                onPressed: () async {

                                                  final dbref4=FirebaseDatabase.instance.reference().child('assoc');
                                                  //final dbref1=FirebaseDatabase.instance.reference().child('users');
                                                  DataSnapshot spp=await dbref1.child(final_users[index][index1]).once();
                                                  Map<dynamic,dynamic> usr=spp.value;
                                                  print('${usr} okra');
                                                  await Firestore.instance
                                                      .collection('projectRoom').document(keys[index])
                                                  .updateData({'users':FieldValue.arrayUnion([usr['username']])});
                                                  await dbref4.child(final_users[index][index1])
                                                  .push().set({'pid':keys[index],
                                                  'admin':0
                                                  });
                                                  delete_request(keys[index],final_push[index][index1]);
                                                },
                                                child: Icon(Icons.check),
                                                backgroundColor: Colors.green,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 50.0,
                                              height: 50.0,
                                              child: FloatingActionButton(
                                                heroTag: 'two+$head',
                                                onPressed: () {
                                                  delete_request(keys[index],final_push[index][index1]);
                                                  },
                                                child: Icon(Icons.clear),
                                                backgroundColor: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                          );
                        }
                    );
                  }
                }
              );
            }
            return Center(child: CircularProgressIndicator());
           }
         ),
          StreamBuilder(
            stream: dbref3.child(widget.uid).onValue,
            builder: (context, AsyncSnapshot<Event> snapshot) {
              if (snapshot.hasData) {
                var lists = [];
                var keys = [];
                //print(snapshot.data.snapshot.value.length);
                DataSnapshot dataValues = snapshot.data.snapshot;
                Map<dynamic, dynamic> values = dataValues.value;
                if(values==null){
                  return Container(
                      child:Text('You didnt send any requests')
                  );
                }
                values.forEach((key, values) {
                  lists.add(values);
                  keys.add(key);
                });
                var uids = [];
                for (var i = 0; i < lists.length; i++) {
                  Map<dynamic, dynamic> users = lists[i];
                  for (var j in users.values) {
                    uids.add(j);
                  }
                }
                print(uids);
                print(lists);
                print(keys);
                dynamic users = [];
                dynamic projects = [];
                Future<List<dynamic>> get_users() async {
                  for (var i = 0; i < uids.length; i++) {
                    String uid = uids[i],
                        uname;
                    await dbref1.child(uid).child('username').once().then((
                        snapshot) {
                      uname = snapshot.value;
                    });
                    users.add(uname);
                  }
                  for (var pid in keys) {
                    String uname1;
                    pid = pid.toString();
                    await dbref2.child(pid).child('title').once().then((
                        snapshot) {
                      uname1 = snapshot.value;
                    });
                    projects.add(uname1);
                  }
                  return users;
                }

                return FutureBuilder(
                  future: get_users(),
                  builder: (BuildContext context,AsyncSnapshot Snapshot) {
                    if(Snapshot.data==null){

                      return Container(
                        child: Text('Loding'),
                      );
                    }
                    else {
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (BuildContext context, int index) {
                          print(users.length);
                          return  Container(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 150,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.0)
                                  ),
                                  color: Colors.white70,
                                  elevation: 8.0,
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        title: Text(users[index]),
                                        leading: Text('you requested'),
                                        subtitle: Text(projects[index]),
                                      ),
                                      ButtonTheme(
                                        child: ButtonBar(
                                          children: <Widget>[
                                            FlatButton(
                                              child: Text('Talk with him'),
                                              onPressed: () {
                                                Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Chat(s: widget.uid,
                                                                r: uids[index])));
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                );

              }
              return Center(child: CircularProgressIndicator());

            }
          ),
          
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items:<BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.arrow_back,
            ),
            title: Text('Requests'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.arrow_forward,
            ),
            title: Text('Sent Requests'),
          ),
        ],
        currentIndex: _index,
        onTap: (index){
          setState(() {
            _index=index;
          });
        },
      ),
    );

  }
}
