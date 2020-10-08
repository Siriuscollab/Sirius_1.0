import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sirius/requests.dart';

class Numb extends StatefulWidget {
  final uid;
  Numb({this.uid});
  @override
  _NumbState createState() => _NumbState();
}

class _NumbState extends State<Numb> {
  final dr=FirebaseDatabase.instance.reference().child('requests');
  final dbref=FirebaseDatabase.instance.reference().child('projects');
  var pn=[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Requests"),
      ),
      body: StreamBuilder(
        stream: dr.child(widget.uid).onValue,
        builder: (context,AsyncSnapshot<Event> snapshot){
          if(snapshot.hasData){
            if(snapshot.data.snapshot.value==null){
              return Text("No Requests");
            }
            else {
              var pro=[];
              var pnn=[];
              var cn=[];
              cn.clear();
              pnn.clear();
              pro.clear();
              Map<dynamic,dynamic> val1=new Map<dynamic,dynamic>();
              DataSnapshot dataValues = snapshot.data.snapshot;
              Map<dynamic, dynamic> values = dataValues.value;
              values.forEach((key, value) {
                pro.add(key);
                cn.add(values[key].length);
              });

              values.forEach((key, value) {
                dbref.child(key).once().then((value1){
                  val1=value1.value;
                  // print(value1.value);
                  // print(key);
                  pnn.add(val1['title']);

                  setState(() {
                    pn=pnn;
                  });
                });
              });
              if(pn==[]){
                return Text('Loading');
              }
              return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: pn.length,
                  itemBuilder: (BuildContext context,int index1){
                    return ListTile(
                      leading: Icon(Icons.arrow_forward),
                      trailing: Text(cn[index1].toString(),
                        style: TextStyle(
                            color: Colors.green,fontSize: 15),),
                      title:Text(pn[index1]),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context)=>Request(uid:widget.uid,pid:pro[index1])
                        ));
                      },
                    );
                  });
            }
          }
          return Center(child: CircularProgressIndicator());
        },

      )
    );
  }
}
