import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication/auth.dart';
import 'authentication/Login.dart';
import 'student_view.dart';
import 'admin_page.dart';
import 'authentication/root_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_page.dart';
import 'teacher_page.dart';
import 'teacher_view.dart';
class AdminHub extends StatefulWidget {
  BaseAuth auth;
  VoidCallback onSignedOut;
  AdminHub({this.auth,this.onSignedOut});
  @override
  AdminHubState createState() => AdminHubState();
}

class AdminHubState extends State<AdminHub> {
  FirebaseMessaging messaging = new FirebaseMessaging();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hub'),
        backgroundColor: Colors.orange,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
                title: Text('Hub'),
                onTap: () {
                  Navigator.pop(context);

                }
            ),
            ListTile(
                title: Text('View Teachers'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>TeacherView(widget.auth,widget.onSignedOut)),);
                }
            ),
            RootPageState.auth == AuthStatus.admin ? ListTile(
                title: Text('View Students'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => StudentView(
                          widget.auth, widget.onSignedOut)));
                }
            ) : Container(),
            ListTile(
                title: Text('Sign Out'),
                onTap: () async {
                  AdminPageState.signedIn = false;
                  messaging.unsubscribeFromTopic('studentNotifier');
                  messaging.unsubscribeFromTopic('teacherNotifier');
                  try {
                    debugPrint('one');
                    await FirebaseAuth.instance.signOut();
                    LoginPageState.auth = RootPageState.auth =
                        Auth.bauth = null;
                    debugPrint('two');
                    setState(() {
                      RootPageState.authStatus = AuthStat.notSignedIn;
                      LoginPageState.isLoading = false;
                      Auth.done = false;
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              RootPage(auth: new Auth())),);
                      Auth.remail = '';
                      Auth.rname = '';
                      Auth.rstatus = null;
                    });
                    debugPrint('${RootPageState.authStatus}');
                  } catch (e) {
                    debugPrint('e $e');
//      onSignedOut();
                  }
                }
            ),
          ],
        ),
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection('users').where('uid',isEqualTo: RootPageState.uuserId).snapshots(),
          builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          return ListView.builder(
            itemCount: snapshot.data.documents[0].data['classes'].length,
            itemBuilder: (BuildContext context, int index){
              return ListTile(
                  title: snapshot.data.documents[0].data['classes'][index],
                  subtitle: snapshot.data.documents[0].data['teachers'][index],
                  onTap: (){
                    if(snapshot.data.documents[0].data['status'] == 'student'){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentPage()));
                    }
                    else if(snapshot.data.documents[0].data['status'] == 'teacher'){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>TeacherPage()));
                    }
                  },
              );
            },
          );
        }
      ),
    );
  }
}
