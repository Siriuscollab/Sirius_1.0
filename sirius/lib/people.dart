import 'dart:io';
import 'package:sirius/database.dart';
// import 'package:chatapp/views/addPeople.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sirius/chat.dart';
class People extends StatefulWidget {
  final String projectId;
  final user;
  People({this.projectId,this.user});
  @override
  _PeopleState createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  QuerySnapshot doc;
  bool haveSearched = false;
  String admin;
  bool isAdmin = false;
  List<dynamic> pplList;
  getDoc() async {
    await DatabaseMethods().getUsers(widget.projectId).then((snapshot) {
      setState(() {
        doc = snapshot;
        haveSearched = true;
        admin = doc.documents[0].data["admin"];
        isAdmin = (widget.user == admin);
        print(isAdmin);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDoc();
  }

  Widget userList() {
    return haveSearched
        ? userTile(
      doc.documents[0].data["users"],
    )
        : Container(
        child: Center(
          child: Text(
            "Loading! Please wait...",
            style: TextStyle(color: Colors.white, fontSize: 30.0),
          ),
        ));
  }

  Widget userTile(List<dynamic> people) {
    print(people.runtimeType);
    setState(() {
      pplList = people;
    });

    print(pplList);

    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: people.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 50,
            child: Card(
              color: Colors.black12,
              child: InkWell(
                onTap: () {
                  print('Card tapped.');
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Chat(s:widget.user,r:people[index])));
                },
                child: Row(
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          color: Colors.brown,
                          borderRadius: BorderRadius.circular(30)),
                      child: Text(people[index].substring(0, 1),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'OverpassRegular',
                              fontWeight: FontWeight.w300)),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Row(
                      children: [
                        (widget.user==people[index])?Text("You",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'OverpassRegular',
                                fontWeight: FontWeight.w300)):
                        Text(people[index],
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontFamily: 'OverpassRegular',
                                fontWeight: FontWeight.w300)),
                        SizedBox(width: 10.0,),
                        (admin==people[index])? Icon(Icons.person,
                          color: Colors.white,):Text(''),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members in the group'),
        actions: [
          isAdmin
              ? GestureDetector(
            onTap: () {
              // print(widget.user);
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => AddPeople(
              //             projectId: widget.projectId, people: pplList)));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.group_add),
            ),
          )
              : SizedBox(height: 0.0,width: 0.0,),
        ],
      ),
      body: userList(),
    );
  }
}
