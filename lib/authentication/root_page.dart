import 'package:flutter/material.dart';
import 'Login.dart';
import 'auth.dart';
import 'package:prsd/student_page.dart';
import 'package:prsd/teacher_page.dart';
import 'package:prsd/Wait.dart';
import 'package:prsd/admin_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class RootPage extends StatefulWidget{
  RootPage({@required this.auth});
  final BaseAuth auth;
  @override
  State<StatefulWidget> createState() {
    return new RootPageState();
  }

}

enum AuthStat{
  notSignedIn,
  signedIn
}
enum Auther{
  notApproved,approved
}
class RootPageState extends State<RootPage>{


 static AuthStat authStatus = AuthStat.notSignedIn;
 LoginPageState l;
  static String uid;
  String name;
 @override
  void initState() {

    widget.auth.currentUser().then((userId){
      try {
        setState(() {
          authStatus =
          userId == null ? AuthStat.notSignedIn : AuthStat.signedIn;
          uid = userId;

          debugPrint('auth: $auth');

        });
      }catch(e){
        if(e.toString() != "NoSuchMethodError: The getter 'uid' was called on null."){
          debugPrint('e $e');
        }
      }

    });

    l = new LoginPageState();

    super.initState();
  }
 void _signedIn(){
  setState(() {
    authStatus = AuthStat.signedIn;
  });
 }
 void _signedOut(){
    setState(() {
      authStatus = AuthStat.notSignedIn;
      LoginPageState.isLoading = false;
      Auth.done = false;
    });

 }
  void tryAgain(){
   setState(() {
     auth = LoginPageState.auth;
     auth = Auth.bauth;

   });
 }
  static void check()async{
    QuerySnapshot docs = await Firestore.instance.collection('users').where('uid',isEqualTo: uid).getDocuments();
    if(docs.documents[0].exists){
      if(!docs.documents[0].data['approved']){
        auther = Auther.notApproved;
      }
      else if (docs.documents[0].data['approved']){
        debugPrint('docs ${docs.documents[0].data['approved']}');
        auther = Auther.approved;
      }
    }

  }
 static AuthStatus auth;
 static Auther auther;
  @override
  Widget build(BuildContext context) {

    if(authStatus == AuthStat.signedIn){
      tryAgain();

      debugPrint('now $auth');
      if(auth == AuthStatus.admin){
        auther = Auther.approved;
      }

      if(auther == Auther.approved) {
        if (auth == AuthStatus.student) {
          return new StudentPage(
            auth: widget.auth,
            onSignedOut: _signedOut,

          );
        }
        if (auth == AuthStatus.teacher) {
          debugPrint('sababanana');
          return new TeacherPage(
            auth: widget.auth,
            onSignedOut: _signedOut,
          );
        }
        if(auth == AuthStatus.admin) {
          return new AdminPage(
            auth: widget.auth,
            onSignedOut: _signedOut,
            uid: uid,
          );
        }
      }
      else{
        debugPrint('Im here');
        return new Wait(auth: widget.auth, onSignedOut: _signedOut);
      }
    }
    return new LoginPage(auth: widget.auth,onSignedIn: _signedIn,);

  }

}