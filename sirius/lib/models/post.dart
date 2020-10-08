import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String sendBy;
  final String message;
  final String time;

  final String uid;
  
  const Post(this.sendBy, this.message,this.time,this.uid);

  factory Post.fromSnapshot(Map data) {
    print('maoo');
    return Post(data['sendBy'], data['message'],data['time2'],data['uid']);
  }
  
  @override
  List<Object> get props => [sendBy, message,time,uid];
}