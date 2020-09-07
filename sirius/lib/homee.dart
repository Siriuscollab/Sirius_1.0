import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sirius/newproject.dart';
// import 'package:sirius/Myprojects.dart';
// import 'package:sirius/hub.dart';
// import 'package:sirius/profile.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentindex=0;

  final List<Widget> tabs=[
    Text('hello'),
    Text('hello'),
    Text('hello')
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase',
      debugShowCheckedModeBanner: false,
      home: Fire(),
    );
  }
}
class Fire extends StatefulWidget {
  @override
  _FireState createState() => _FireState();
}

class _FireState extends State<Fire> {
  final _formkey=GlobalKey<FormState>();
  String url;
  File resume;
  final dbref=FirebaseDatabase.instance.reference().child('projects');
  TextEditingController pt=TextEditingController();
  TextEditingController desc=TextEditingController();
  TextEditingController size=TextEditingController();
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => Hom()));
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
                lists.clear();
                // Map<dynamic,dynamic> values=snapshot.data.value;
                // values.forEach((key, value) { lists.add(value);});
                DataSnapshot dataValues = snapshot.data.snapshot;
                Map<dynamic, dynamic> values = dataValues.value;
                values.forEach((key, values) {
                  lists.add(values);
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
                            return detailview(list:lists[index]);
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
                                    leading:Text('Project${index+1}'),
                                    title: Text(lists[index]['title']),
                                    subtitle: Text('ML,AI,Python...'),
                                  ),
                                  ButtonTheme(
                                    child: ButtonBar(
                                      children: <Widget>[
                                        FlatButton(
                                          child: Text('Join'),
                                          onPressed: (){},
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
class detailview extends StatefulWidget {
  Map<dynamic,dynamic> list;
  detailview({this.list});
  @override
  _detailviewState createState() => _detailviewState();
}

class _detailviewState extends State<detailview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text(
            'Project Details'
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // mainAxisAlignment: MainAxisAlignment.center ,
          children: <Widget>[
            Text('Project Title',
              style: TextStyle(
                  fontSize: 21.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic
              ),
            ),
            Text(widget.list['title'],
              style: TextStyle(
                  fontSize: 21.0,
                  // fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic
              ),),
            Text('Project Description',
              style: TextStyle(
                  fontSize: 21.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic
              ),),
            Text(widget.list['description'],
              style: TextStyle(
                  fontSize: 21.0,
                  // fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic
              ),),
            Text('Group Size',
              style: TextStyle(
                  fontSize: 21.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic
              ),),
            Text(widget.list['groupsize'],
              style: TextStyle(
                  fontSize: 21.0,
                  // fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic
              ),),

          ],
        ),
      ),
    );
  }
}
//.where('userName', isEqualTo: searchField)