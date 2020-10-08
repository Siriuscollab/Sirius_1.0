

import 'package:cloud_firestore/cloud_firestore.dart';

class PostRepository {
  // Singleton boilerplate
  PostRepository._();
  
  static PostRepository _instance = PostRepository._();
  static PostRepository get instance => _instance;
  
  // Instance
  // final CollectionReference _postCollection = Firestore.instance.collection('posts');
  final Query _postCollection=Firestore.instance
      .collection("projectRoom")
      .document(
      '-MIru6Lben6UWzodk1fk'
  )
      .collection("chats").orderBy('time',descending: true);
  
  Stream<QuerySnapshot> getPosts(String pid) {

   return Firestore.instance
       .collection("projectRoom")
       .document(
       pid
   )
       .collection("chats").orderBy('time',descending: true)
      .limit(15)
      .snapshots();
  }
  
  Stream<QuerySnapshot> getPostsPage(DocumentSnapshot lastDoc,String pid) {
    return Firestore.instance
        .collection("projectRoom")
        .document(
        pid
    )
        .collection("chats").orderBy('time',descending: true)
        .startAfterDocument(lastDoc)
        .limit(15)
        .snapshots();
  }
}