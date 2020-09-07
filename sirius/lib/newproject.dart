import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sirius/homee.dart';
class Hom extends StatefulWidget {
  @override
  _HomState createState() => _HomState();
}

class _HomState extends State<Hom> {
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
                        onPressed: (){
                          if(_formkey.currentState.validate()){

                            dbref.push().set({
                              'title':pt.text,
                              'description':desc.text,
                              'groupsize':size.text,
                              'resume':url
                            });
                            Scaffold.of(context).showSnackBar(SnackBar(content: Text('Created Successfully'),));
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
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