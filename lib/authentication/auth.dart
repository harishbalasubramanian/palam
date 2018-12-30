import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Login.dart';
import 'root_page.dart';
abstract class BaseAuth{
  Future<String> signInWithEmailAndPassword(String email, String password, AuthStatus role);
  Future<String> createUserWithEmailAndPassword(String email, String password,AuthStatus role,String name);
  Future<String> currentUser();

}

class Auth implements BaseAuth{

  static bool done = false;
  LoginPageState l = new LoginPageState();
  static AuthStatus bauth;
  Future<String> signInWithEmailAndPassword(String email, String password, AuthStatus role)async{
    bool au = false;
    FirebaseUser user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).whenComplete((){
      au = true;
    });
    while(!au){
      continue;
    }
    Firestore.instance.collection('/users').where('uid',isEqualTo: user.uid).getDocuments().then((docs){
        if(docs.documents[0].exists){
          if(docs.documents[0].data['status']=='student'){
            role = AuthStatus.student;
          }
          else if (docs.documents[0].data['status'] == 'teacher'){
            role = AuthStatus.teacher;
          }
          else if (docs.documents[0].data['status'] == 'admin'){
            role = AuthStatus.admin;
          }
          if(!docs.documents[0].data['approved']){
            RootPageState.auther = Auther.notApproved;
          }
          else if (docs.documents[0].data['approved']){
            RootPageState.auther = Auther.approved;
          }
        }


      bauth = role;
      LoginPageState.auth = RootPageState.auth = bauth;
      debugPrint('login: ${LoginPageState.auth}');
      debugPrint('root: ${RootPageState.auth}');
      debugPrint('done');
      done = true;
      RootPageState.uid = user.uid;
      RootPageState.check();
    });

    return user.uid;
  }
  Future<String> createUserWithEmailAndPassword(String _email, String _password,AuthStatus role,String name)async{
    FirebaseUser user = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password);
    debugPrint('status: ${role.toString().replaceAll('AuthStatus.','')}');
    await Firestore.instance.collection('users').document().setData({
      'email' : _email,
      'uid' : user.uid,
      'status' : role.toString().replaceAll('AuthStatus.',''),
      'approved' : false,
      'name' : name
    });
    user = await FirebaseAuth.instance.signInWithEmailAndPassword(email: user.email, password: _password);
    await Firestore.instance.collection('users').where('uid',isEqualTo: user.uid).getDocuments().then((docs){
      if(docs.documents[0].exists){
        if(docs.documents[0].data['status']=='student'){
          role = AuthStatus.student;
        }
        else if (docs.documents[0].data['status'] == 'teacher'){
          role = AuthStatus.teacher;
        }
        else if (docs.documents[0].data['status'] == 'admin'){
          role = AuthStatus.admin;
        }
        if(!docs.documents[0].data['approved']){
          RootPageState.auther = Auther.notApproved;
        }
        else if (docs.documents[0].data['approved']){
          RootPageState.auther = Auther.approved;
        }
      }

      debugPrint('autther ${RootPageState.auther}');
      bauth = role;
      LoginPageState.auth = RootPageState.auth = bauth;
      debugPrint('login: ${LoginPageState.auth}');
      debugPrint('root: ${RootPageState.auth}');
      debugPrint('done');
      done = true;
      RootPageState.uid = user.uid;
      RootPageState.check();
    });
    return user.uid;
  }
  Future<String> currentUser()async{
    bool au = false;
    FirebaseUser user = await FirebaseAuth.instance.currentUser().whenComplete((){
      au = true;
    });
    while(!au){
      continue;
    }
    String val = '';
    await Firestore.instance.collection('/users').where('uid',isEqualTo: user.uid).getDocuments().then((value){
      debugPrint('double hellop');
      if(value.documents[0].exists) {
        val = value.documents[0].data['status'];
        if (val == 'student')
          bauth = AuthStatus.student;
        else if (val == 'teacher')
          bauth = AuthStatus.teacher;
        else if (val == 'admin')
          bauth = AuthStatus.admin;
        if(value.documents[0].data['approved'] == 'false'){
          RootPageState.auther = Auther.notApproved;
        }
        else if (value.documents[0].data['approved'] == 'true'){
          RootPageState.auther = Auther.approved;
        }
        debugPrint('val $val');
      }

    });
    debugPrint('bauth $bauth');
    LoginPageState.auth = RootPageState.auth = bauth;
    return user.uid;
  }
  static Future<void> signOut() async{

    await FirebaseAuth.instance.signOut();
    LoginPageState.auth = RootPageState.auth = bauth = null;
  }




}