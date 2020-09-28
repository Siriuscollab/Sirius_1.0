import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as Path;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sirius/newproject.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sirius/detailview.dart';
import 'package:sirius/profile%20.dart';
import 'package:sirius/requests.dart';
import 'package:sirius/team.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
class Home extends StatefulWidget {
  final uid;
  final token;
  Home({this.uid,this.token});
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
      .uid,token:widget.token),
    );
  }
}
class Fire extends StatefulWidget {
  final uid;
  final token;
  Fire({this.uid,this.token});
  @override
  _FireState createState() => _FireState();
}

class _FireState extends State<Fire> {
  final SearchBarController<Map<dynamic, dynamic>> _searchBarControllerCities = SearchBarController();
  final _formkey=GlobalKey<FormState>();
  String url;
  File resume;
  String name,email,phone;
  final dbref=FirebaseDatabase.instance.reference().child('projects');
  final dbref2=FirebaseDatabase.instance.reference().child('assoc');
  final dr=FirebaseDatabase.instance.reference().child('requests');
  final db=FirebaseDatabase.instance.reference().child('users');
  TextEditingController pt=TextEditingController();
  TextEditingController desc=TextEditingController();
  TextEditingController size=TextEditingController();
  var pname1=[];
  var pn=[];
  Map<dynamic, dynamic> values1=new Map<dynamic,dynamic>();
  Map<dynamic,dynamic> ud;
  Future<List<Map<dynamic,dynamic>>> _getALlPosts(String text)  async{
    List<Map<dynamic,dynamic>> posts = [];
    Map<dynamic,dynamic> lp;
    print('ok');
    DataSnapshot value=await dbref.orderByChild('title').startAt(text).endAt(text+"\uf8ff").once();
    if(value==null){print('nullll');}
    lp=value.value;
    String kt;
    lp.forEach((key, value1) {
      posts.add({key:value1});
    });
    print(posts);
    print(posts);
    return posts;
  }
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
  var l1=[];
  final dbref3=FirebaseDatabase.instance.reference().child('requests1');
  final dbref4=FirebaseDatabase.instance.reference().child('sentrequests');
  var _index=0;
  @override
  void initState(){
    values1=new Map<dynamic,dynamic>();
    db.child(widget.uid).once().then((value) {
      ud=value.value;
      print(ud);
      setState(() {
        name=ud['username'];
        phone=ud['phone'];
        email=ud['email'];
      });
    });
    super.initState();
  }
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
          children:[
               StreamBuilder(
              stream: dbref.onValue,
              builder: (context,AsyncSnapshot<Event> snapshot){
                if(snapshot.hasData){
            if(snapshot.data.snapshot.value==null){
              return Text('Create Your First One!!!!');
            }
            if(name==null){
             return Center(child: CircularProgressIndicator());
            }

            var lp=[];
            lists.clear();
            lp.clear();
            // Map<dynamic,dynamic> values=snapshot.data.value;
            // values.forEach((key, value) { lists.add(value);});
            dbref2.child(widget.uid).once().then((value) {
              values1=value.value;
              if(values1==null){
               return Text('Loading');
              }
              values1.forEach((key, value) {
                lp.add(key);
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
                                      child:  l1.contains(keys[index])?Text('Requeted'):Text('Join'),
                                      onPressed: () async{
                                        String c_pid=keys[index];
                                        String p_uid;
                                        await dbref.child(c_pid).child('uid').once()
                                            .then((snapshot){p_uid=snapshot.value;});
                                        await dbref3.child(p_uid).child(c_pid).push().set(widget.uid);
                                        await dbref4.child(widget.uid).child(c_pid).push().set(p_uid);
                                        setState(() {
                                          l1.add(c_pid);
                                        });
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Share'),
                                      onPressed: (){},
                                    ),
                                    name==lists[index]['uname']?
                                    FlatButton(
                                      child: Text('delete'),
                                      onPressed: () async{
                                        await dbref.child(keys[index]).remove();
                          await dbref2.child(widget.uid).child(keys[index]).remove();

                                      },
                                    ):SizedBox()
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:SearchBar<Map<dynamic,dynamic>>(
                searchBarController: _searchBarControllerCities,
                // searchBarPadding: EdgeInsets.symmetric(horizontal: 10),
                // headerPadding: EdgeInsets.symmetric(horizontal: 10),
                // listPadding: EdgeInsets.symmetric(horizontal: 10),
                onSearch: _getALlPosts,

                cancellationWidget: Text("Cancel"),
                emptyWidget: Text("empty"),
                onError: (e){
                  return Text('Not Found');
                },
                minimumChars: 1,
                // indexedScaledTileBuilder: (int index) => ScaledTile.count(1, index.isEven ? 2 : 1),
                onCancelled: () {
                  print("Cancelled triggered");
                },
                mainAxisSpacing: 10,
                hintText: 'Search Project by Title',
                crossAxisSpacing: 10,
                crossAxisCount: 1,
scrollDirection: Axis.vertical,
                icon: Icon(
                  Icons.find_in_page
                ),
                onItemFound: (Map<dynamic,dynamic> post, int index) {
                  String ks;
                  post.keys.forEach((element) {
                    ks=element;
                  });
                  return  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return detailview(list:post[ks],keys:ks);
                      }));
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)
                      ),
                      color: Colors.white70,
                      elevation: 8.0,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading:Text('${post[ks]['uname']}'),
                            title: Text(post[ks]['title']),
                            subtitle: Text('ML,AI,Python...'),
                          ),
                          ButtonTheme(
                            child: ButtonBar(
                              children: <Widget>[
                                up.contains(ks)?
                                FlatButton(
                                  child: Text('Joined'),
                                  onPressed: () {

                                  },
                                ):  FlatButton(
                                  child: Text('Join'),
                                  onPressed: () async{
                                    FirebaseUser user= await FirebaseAuth.instance.currentUser();
                                    final dbref1=FirebaseDatabase.instance.reference().child('assoc');
                                    final dbref2=FirebaseDatabase.instance.reference().child('users');
                                    DataSnapshot spp=await dbref2.child(widget.uid).once();
                                    Map<dynamic,dynamic> usr=spp.value;

                                    Firestore.instance
                                        .collection('projectRoom').document(ks)
                                        .updateData({'users':FieldValue.arrayUnion([usr['username']])});
                                    dbref1.child(widget.uid)
                                        .child(ks).set({
                                      'admin':0
                                    });
                                  },
                                ),
                                FlatButton(
                                  child: Text('Share'),
                                  onPressed: (){},
                                ),
                                name==post[ks]['uname']?
                                FlatButton(
                                  child: Text('delete'),
                                  onPressed: () async{
                                    await dbref.child(ks).remove();
                                    await dbref2.child(widget.uid).child(ks).remove();
                                    // _searchBarControllerCities.clear();
                                    _searchBarControllerCities.replayLastSearch();
                                  },
                                ):SizedBox()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  //   Container(
                  //   color: Colors.lightBlue,
                  //   child: ListTile(
                  //     title: Text(post['uname']['title']),
                  //     isThreeLine: true,
                  //     subtitle: Text('ok'),
                  //     onTap: () {
                  //       // Navigator.of(context).push(MaterialPageRoute(builder: (context) => Detail()));
                  //     },
                  //   ),
                  // );
                },
              ),
            ),
            StreamBuilder(
              stream: dbref2.child(widget.uid).onValue,
              builder: (context,AsyncSnapshot<Event> snapshot) {
                if(snapshot.hasData){

                if(snapshot.data.snapshot.value==null){
                  return Text('Not Joined In Any Projects!!');
                }
                else{

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
                  Map<dynamic,dynamic> val=new Map<dynamic,dynamic>();
                  Map<dynamic,dynamic> val1;
                values.forEach((key, value) {
                  list2.add(key);
                  admin.add(value['admin']);
                });
                  // values.forEach((key, values) {
                  //   if(key==widget.uid){
                  //     val1=values;
                  //     val1.forEach((key, value) {
                  //       list2.add(value['pid']);
                  //       admin.add(value['admin']);
                  //     });
                  //   }
                    // list.add(values);
                    // // print('${key} and ${widget.uid}');
                    // values['userid']==widget.uid?list2.add(values['pid']):print('not equal');
                    // print(widget.uid);
                  // });
                  list2.forEach((element) {
                    dbref.orderByKey().equalTo(element).once().then((value) {
                      val=value.value;
                      // print(val);
                      if(val==null){
                        return Text('Loading');
                      }
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
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context)=>Team(projectId:list2[index1],userr:widget.uid)
                                            ));
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
                }}
                return Center(child: CircularProgressIndicator());
              },
            ),
            Profile(uid: widget.uid)
    //         StreamBuilder(
    //           stream: dr.child(widget.uid).onValue,
    //           builder: (context,AsyncSnapshot<Event> snapshot){
    //             if(snapshot.hasData){
    //               if(snapshot.data.snapshot.value==null){
    //                 return Text("No Requests");
    //               }
    //               else {
    //                 var pro=[];
    //                 var pnn=[];
    //                 var cn=[];
    //                 cn.clear();
    //                 pnn.clear();
    //                 pro.clear();
    //                 Map<dynamic,dynamic> val1=new Map<dynamic,dynamic>();
    //                 DataSnapshot dataValues = snapshot.data.snapshot;
    //                 Map<dynamic, dynamic> values = dataValues.value;
    // values.forEach((key, value) {
    //  pro.add(key);
    //  cn.add(values[key].length);
    // });
    //
    //                 values.forEach((key, value) {
    //                   dbref.child(key).once().then((value){
    //                     val1=value.value;
    //                     pnn.add(val1['title']);
    //                     setState(() {
    //                       pn=pnn;
    //                     });
    //                   });
    //                 });
    //                 if(pn==[]){
    //                   return Text('Loading');
    //                 }
    //                 return ListView.builder(
    //                   shrinkWrap: true,
    //                     scrollDirection: Axis.vertical,
    //                     itemCount: pro.length,
    //                     itemBuilder: (BuildContext context,int index1){
    //                       return ListTile(
    //                         leading: Icon(Icons.arrow_forward),
    //                         trailing: Text(cn[index1].toString(),
    //                           style: TextStyle(
    //                               color: Colors.green,fontSize: 15),),
    //                         title:Text(pn[index1]),
    //                         onTap: (){
    //                           Navigator.push(context, MaterialPageRoute(
    //                               builder: (context)=>Request(uid:widget.uid,pid:pro[index1])
    //                           ));
    //                         },
    //                       );
    //                     });
    //               }
    //             }
    //             return Center(child: CircularProgressIndicator());
    //           },
    //
    //         )
          ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        backgroundColor: Colors.blueGrey,
        items:<BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
                color: Colors.black,
            ),
            title: Text('Home',
            style: TextStyle(
              color: Colors.black,
            ),),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
                color: Colors.black,
            ),
            title: Text('Search',
                style: TextStyle(
                  color: Colors.black,
                )
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.business_center,
              color: Colors.black,
            ),
            title: Text('My Projects',
                style: TextStyle(
                  color: Colors.black,
                )),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment_ind,
                color: Colors.black
            ),
            title: Text('Profile',
                style: TextStyle(
                  color: Colors.black,
                )),
          ),
        ],
        currentIndex: _index,
        onTap: (index){
          setState(() {
            _index=index;
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          });
        },
      ),
    );
  }
}
//.where('userName', isEqualTo: searchField)