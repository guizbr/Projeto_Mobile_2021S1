import 'package:chatonline_app/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  User _currentUser;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<User> _getUser() async {
    if(_currentUser != null) return _currentUser;

    try{
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User user = userCredential.user;
      return user;
    } catch(error) {
      return null;
    }
  }

  void _sendMessage({String text, File imgFile}) async {
    final User user = await _getUser();

    if(user == null){
      final snackBar = SnackBar(content: Text('Não foi possível fazer o login. Tente Novamente!'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl":user.photoURL,
      "time": Timestamp.now(),
    };

    if(imgFile != null){
      UploadTask task = FirebaseStorage.instance.ref().child(DateTime.now().millisecondsSinceEpoch.toString()).putFile(imgFile);
      setState(() {
        _isLoading = true;
      });
      await task.whenComplete(() => null);
      String url = await task.snapshot.ref.getDownloadURL();
      data['imgUrl'] = url.toString();
      setState(() {
        _isLoading = false;
      });
    }

    if(text != null) data['text'] = text;

    FirebaseFirestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentUser != null ? "Olá, ${_currentUser.displayName}" : "Chat App"
        ),
        centerTitle: true,
        elevation: 0,
          actions: [
            _currentUser != null ? IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: (){
                FirebaseAuth.instance.signOut();
                googleSignIn.signOut();
                final snackBar = SnackBar(content: Text('Você saiu com sucesso!'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ) : Container(),
          ],
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("messages").orderBy("time").snapshots(),
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                     default:
                      List<DocumentSnapshot> documents = snapshot.data.docs.reversed.toList();

                      return ListView.builder(
                          itemCount: documents.length,
                          reverse: true,
                          itemBuilder: (context, index){
                            return ChatMessage(documents[index].data(), documents[index].data()["uid"] == _currentUser?.uid);
                          }
                      );
                  }
                },
              ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      )
    );
  }
}
