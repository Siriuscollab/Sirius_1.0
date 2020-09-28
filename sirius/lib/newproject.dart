import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sirius/homee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Hom extends StatefulWidget {
  final uid;
  Hom({this.uid});
  @override
  _HomState createState() => _HomState();
}

class _HomState extends State<Hom> {
  final _formkey=GlobalKey<FormState>();
  String url;
  File resume;
  final dbref2=FirebaseDatabase.instance.reference().child('assoc');
  final dbref=FirebaseDatabase.instance.reference().child('projects').push();
  final dbref3=FirebaseDatabase.instance.reference().child('users');
  TextEditingController pt=TextEditingController();
  TextEditingController desc=TextEditingController();
  TextEditingController size=TextEditingController();

  Future<bool> addChatRoom2(projectRoom, projectId) {
    Firestore.instance
        .collection("projectRoom")
        .document(projectId)
        .setData(projectRoom)
        .catchError((e) {
      print(e);
    });
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
  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      appBar: AppBar(
        title: Text(
          'Create Project',
        ),
        centerTitle: true,
        titleSpacing: 1.0,
        backgroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Builder(
        builder:(context)=>
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Form(
                  key:_formkey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: pt,
                        autofocus: true,
                        decoration: InputDecoration(
                            labelText: 'Project Title',
                            icon: Icon(Icons.input),
                            border: OutlineInputBorder(
                            )
                        ),
                        validator: (str){
                          if(str.length>4){
                            return null;
                          }
                          return "Length must be grater than 4";
                        },
                        onChanged: (val){
                          print(val);
                        },
                      ),
                      SizedBox(height: 10.0),

                      TextFormField(
                        controller: size,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'Size',
                            labelText: 'Group Size',
                            icon: Icon(Icons.group),
                            border: OutlineInputBorder(
                            )
                        ),
                        validator: (num){
                          if(num.length==0){
                            return "Group Size must be greater than 0";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        maxLines: null,
                        controller: desc,
                        decoration: InputDecoration(

                            labelText: 'Project Description',
                            icon: Icon(Icons.description),
                            border: OutlineInputBorder(
                            )
                        ),
                        validator: (str){
                          if(str.length>4){
                            return null;
                          }
                          return "Length must be grater than 4";
                        },
                        onChanged: (val){
                          print(val);
                        },
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                              Icons.file_upload
                          ),
                          resume==null?
                          Text('Upload Resume',
                            style: TextStyle(
                                fontSize: 18.0
                            ),):Text('Uploaded Resume', style: TextStyle(
                              fontSize: 18.0
                          )),
                          RaisedButton(
                            child: Text('Upload'),
                            color: Colors.blueGrey,
                            onPressed: uploadFile,
                          )
                        ],
                      ),

                      SizedBox(height: 10.0),
                      RaisedButton(
                        child: Text(
                            'Create'
                        ),
                        onPressed: () async{
                          if(_formkey.currentState.validate()) {
                            var key=dbref.key;
                            DataSnapshot user=await dbref3.child(widget.uid).once();
                            Map<dynamic,dynamic> l=user.value;
                          dbref.set({
                              'title':pt.text,
                              'description':desc.text,
                              'groupsize':size.text,
                              'resume':url,
                            'uname':l['username'],
                            'uid':widget.uid
                            });

                            dbref2.child(widget.uid).child(key).set({
                              'admin':1,
                            });
                                String projectId = key;

                                List<String> users = [l['username']];

                                Map<String, dynamic> projectRoom = {
                                  "users": [l['username']],
                                  "projectId": projectId,
                                  "admin":l['username'],
                                };

                                addChatRoom2(projectRoom, projectId);

                            Scaffold.of(context).showSnackBar(SnackBar(content: Text('Created Successfully'),));
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Home(uid: widget.uid,)));
                          }
                        },
                        color: Colors.blueGrey,
                        textColor: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}