import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data_bloc/data_bloc.dart';

class LazyListScreen extends StatefulWidget {
  final pid;
  final uid;
  LazyListScreen({this.pid, this.uid});
  @override
  createState() => _LazyListScreenState();
}

class _LazyListScreenState extends State<LazyListScreen> {

  DataBloc _dataBloc;
  
  @override
  initState() {
    super.initState();
    _dataBloc=DataBloc(pid:widget.pid);
    _dataBloc.add(DataEventStart());
  }
  
  @override
  Widget build(BuildContext context) {
   return BlocBuilder<DataBloc, DataState>(
        cubit: _dataBloc,
        builder: (BuildContext context, DataState state) {
          if (state is DataStateLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is DataStateEmpty) {
            print(state);
              return Center(
                child: Text(''),
              );
          } else if (state is DataStateLoadSuccess) {
            return ListView.builder(
              reverse: true,
              padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
              itemCount: state.hasMoreData ? state.posts.length + 1 : state.posts.length,
              itemBuilder: (context, i) {
                if (i >= state.posts.length) {
                  _dataBloc.add(DataEventFetchMore());
                  return Container(
                    margin: EdgeInsets.only(top: 15),
                    height: 30,
                    width: 30,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return MessageTile(
                  message: state.posts[i].message,
                  sendByMe: widget.uid == state.posts[i].uid,
                  name: state.posts[i].sendBy,
                  time: state.posts[i].time,
                );
                // return ListTile(
                //   title: Text(state.posts[i].message),
                //   subtitle: Text(state.posts[i].sendBy),
                // );
              },
              // separatorBuilder: (context, i) {
              //   return Divider();
              // }
            );
          }
        }
     );
  }
  // state.posts[i].title
  // state.posts[i].author

  @override
  void dispose() { 
    _dataBloc.close();
    super.dispose();
  }
  
}
class MessageTile extends StatefulWidget {
  final String message;
  final bool sendByMe;
  final String name;
  final String time;

  MessageTile({@required this.message, @required this.sendByMe,@required this.name,@required this.time});

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: widget.sendByMe ? 0 : 24,
          right: widget.sendByMe ? 24 : 0),
      alignment: widget.sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sendByMe
            ? EdgeInsets.only(left: 30)
            : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(
            top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: widget.sendByMe ? BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomLeft: Radius.circular(23)
            ) :
            BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: widget.sendByMe ? [
                const Color(0xFFa39568),
                const Color(0xFFa39568)
              ]
                  : [
                const Color(0xff4e868a),
                const Color(0xff4e868a)
              ],
            )
        ),
        child: Column(

          children: [
            widget.sendByMe? SizedBox(width: 0.0,height: 0.0,):Text(widget.name,
              style: TextStyle(color: Colors.white,
                  fontSize: 12),),
            Text("${widget.message}\n ${widget.time}",
                //textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'OverpassRegular',
                    fontWeight: FontWeight.w300)),
          ],
        ),

      ),
    );
  }
}
