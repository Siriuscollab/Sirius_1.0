import 'package:flutter/material.dart';
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