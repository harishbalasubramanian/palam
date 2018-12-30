import 'package:flutter/material.dart';
import 'package:prsd/authentication/auth.dart';
class Wait extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  Wait({this.auth,this.onSignedOut});
  @override
  WaitState createState() => WaitState(auth: auth, onSignedOut: onSignedOut);
}

class WaitState extends State<Wait> {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  WaitState({this.auth, this.onSignedOut});
  void _signOut()async{
    try {
      await Auth.signOut();
      onSignedOut();
    }catch(e){
      debugPrint('e $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('You have not been approved'),
        backgroundColor: Colors.orange,


      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Home'),
              onTap: (){
                Navigator.pop(context);
              }
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: () {
                _signOut();
                Navigator.pop(context);
              }
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          '''You have not been approved so please come back at another time or contact your teacher or administrator''',textAlign: TextAlign.center,
          style: TextStyle(fontFamily: "Serif",fontSize: 16.0),
        ),
      ),
    );
  }
}
