import 'package:flutter/material.dart';
import 'package:prsd/authentication/auth.dart';
import 'dart:async';
import 'authentication/root_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication/Login.dart';
class StudentPage extends StatefulWidget{
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  StudentPage({this.auth,this.onSignedOut});
  @override
  State<StatefulWidget> createState() {
    return new StudentPageState(auth: auth, onSignedOut: onSignedOut);
  }


}

class StudentPageState extends State<StudentPage>{

  StudentPageState({this.auth,this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  void _signOut() async{
    try{
      await Auth.signOut();
      onSignedOut();
    }catch(e){
      debugPrint(e);
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.accessibility),onPressed: ()async{
            debugPrint('one');
            await FirebaseAuth.instance.signOut();
            LoginPageState.auth = RootPageState.auth = Auth.bauth = null;
            debugPrint('two');
            setState(() {
              RootPageState.authStatus = AuthStat.notSignedIn;
              LoginPageState.isLoading = false;
              Auth.done = false;
              Navigator.push(context, MaterialPageRoute(builder: (context)=> RootPage(auth: new Auth())),);
            });
            debugPrint('${RootPageState.authStatus}');
          },),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Center(

          ),
        ),
      ),

    );
  }
}