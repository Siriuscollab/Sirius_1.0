import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sirius/newproject.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sirius/detailview.dart';
// import 'package:sirius/Myprojects.dart';
// import 'package:sirius/hub.dart';
// import 'package:sirius/profile.dart';


class Home extends StatefulWidget {
  final uid;
  Home({this.uid});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentindex=0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase',
      debugShowCheckedModeBanner: false,
      home: Fire(uid:widget
      .uid),
    );
  }
}
class Fire extends StatefulWidget {
  final uid;
  Fire({this.uid});
  @override
  _FireState createState() => _FireState();
}

class _FireState extends State<Fire> {
  final _formkey=GlobalKey<FormState>();
  String url;
  File resume;
  final dbref=FirebaseDatabase.instance.reference().child('projects');
  final dbref2=FirebaseDatabase.instance.reference().child('assoc');
  TextEditingController pt=TextEditingController();
  TextEditingController desc=TextEditingController();
  TextEditingController size=TextEditingController();
  var pname1=[];
  Future<void> uploadFile() async{
    print('ok');
    File file = await FilePicker.getFile(type: FileType.custom, allowedExtensions: ['pdf', 'doc']);
    print(file.path);
    setState(() {
      resume=file;
    });
    StorageReference storageReference = FirebaseStorage.instance.ref().child('resumes/${Path.basename(file.path)}}');
    StorageUploadTask t=storageReference.putFile(file);
    await t.onComplete;
    print('uploaded');
    storageReference.getDownloadURL().then((value) { url=value;
    });
  }
  final lists=[];
  final keys=[];
  var up=[];
  var _index=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:      FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
        backgroundColor: Colors.white70,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Hom(uid:widget.uid)));
        },
      ),
      appBar: AppBar(
        title: Text(
          'Projects',
        ),
        centerTitle: true,
        titleSpacing: 1.0,
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
      ),
      body:IndexedStack(
          index: _index,
          children:[StreamBuilder(
            stream: dbref.onValue,
            builder: (context,AsyncSnapshot<Event> snapshot){
              if(snapshot.hasData){
                Map<dynamic, dynamic> values1;
                var lp=[];
                lists.clear();
                lp.clear();
                // Map<dynamic,dynamic> values=snapshot.data.value;
                // values.forEach((key, value) { lists.add(value);});
                dbref2.child(widget.uid).once().then((value) {
                  values1=value.value;
                  values1.forEach((key, value) {
                    lp.add(value['pid']);
                  });
                  setState(() {
                    up=lp;
                  });
                });
                DataSnapshot dataValues = snapshot.data.snapshot;
                Map<dynamic, dynamic> values = dataValues.value;
                values.forEach((key, values) {
                  lists.add(values);
                  keys.add(key);
                });
                return  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: lists.length,
                    itemBuilder: (BuildContext context,int index){
                      return GestureDetector(
                        onTap: (){
                          print('ok');
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return detailview(list:lists[index],keys:keys[index]);
                          }));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 150,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)
                              ),
                              color: Colors.white70,
                              elevation: 8.0,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading:Text('${lists[index]['uname']}'),
                                    title: Text(lists[index]['title']),
                                    subtitle: Text('ML,AI,Python...'),
                                  ),
                                  ButtonTheme(
                                    child: ButtonBar(
                                      children: <Widget>[
                                        up.contains(keys[index])?
                                        FlatButton(
                                          child: Text('Joined'),
                                          onPressed: () {

                                          },
                                        ):  FlatButton(
                                          child: Text('Join'),
                                          onPressed: () async{
                                            FirebaseUser user= await FirebaseAuth.instance.currentUser();
                                            final dbref1=FirebaseDatabase.instance.reference().child('assoc');
                                            dbref1.child(widget.uid)
                                                .push().set({'pid': keys[index],
                                              'admin':0
                                            });
                                          },
                                        ),
                                        FlatButton(
                                          child: Text('Share'),
                                          onPressed: (){},
                                        )
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
              return Center(child: CircularProgressIndicator());
            },
          ),
            StreamBuilder(
              stream: dbref2.onValue,
              builder: (context,AsyncSnapshot<Event> snapshot) {
                if(snapshot.hasData){
                  var list=[];
                  var list2=[];
                  var admin=[];
              var pname=[];
                pname.clear();
                  list2.clear();
                  list.clear();
                  admin.clear();
                  // Map<dynamic,dynamic> values=snapshot.data.value;
                  // values.forEach((key, value) { lists.add(value);});
                  DataSnapshot dataValues = snapshot.data.snapshot;
                  Map<dynamic, dynamic> values = dataValues.value;
                  Map<dynamic,dynamic> val;
                  Map<dynamic,dynamic> val1;

                  values.forEach((key, values) {
                    if(key==widget.uid){
                      val1=values;
                      val1.forEach((key, value) {
                        list2.add(value['pid']);
                        admin.add(value['admin']);
                      });
                    }
                    // list.add(values);
                    // // print('${key} and ${widget.uid}');
                    // values['userid']==widget.uid?list2.add(values['pid']):print('not equal');
                    // print(widget.uid);
                  });
                  list2.forEach((element) {
                    dbref.orderByKey().equalTo(element).once().then((value) {
                      val=value.value;
                      // print(val);
                      val.forEach((key, values) {
                        pname.add(values);
                      });
                      setState(() {
                      pname1=pname;
                      });
                      // print(pname);
                    });
                  });
                  return  ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: pname1.length,
                      itemBuilder: (BuildContext context,int index1){
                        return GestureDetector(
                          onTap: (){
                            print('ok');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 150,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)
                                ),
                                color: admin[index1]==1?Colors.tealAccent:Colors.white70,
                                elevation: 8.0,
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading:Text('Project${index1+1}'),
                                      title: Text(pname1[index1]['title']),
                                      subtitle: Text('ML,AI,Python...'),
                                    ),
                                    ButtonTheme(
                                      child: ButtonBar(
                                        children: <Widget>[
                                          FlatButton(
                                            child: Text('Chat Room'),
                                            onPressed: () {

                                            },
                                          ),
                                          FlatButton(
                                            child: Text('Share'),
                                            onPressed: (){},
                                          )
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
                return Center(child: CircularProgressIndicator());
              },
            ),
            Text('Profile'),
          ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        items:<BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.business_center,
            ),
            title: Text('My Projects'),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment_ind,
            ),
            title: Text('Profile'),
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
//.where('userName', isEqualTo: searchField)