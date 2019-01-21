import 'package:flutter/material.dart';
import 'admin_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication/Login.dart';
import 'authentication/root_page.dart';
import 'authentication/auth.dart';
import 'student_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'Wait.dart';
class TeacherView extends StatefulWidget {
  BaseAuth auth;
  VoidCallback onSignedOut;
  TeacherView(this.auth, this.onSignedOut);
  @override
  TeacherViewState createState() => TeacherViewState();
}

class TeacherViewState extends State<TeacherView> {
  List<bool> value = [];
  FirebaseMessaging messaging = new FirebaseMessaging();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.orange,
              title: Text('View All Teachers'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        RootPageState.auther = snapshot.data.documents[0].data['approved'] ? Auther.approved : Auther.notApproved;
        if(RootPageState.auther == Auther.approved) {
          return Scaffold(
              appBar: AppBar(
                title: Text('View All Teachers'),
                backgroundColor: Colors.orange,
              ),
              drawer: Drawer(
                child: ListView(
                  children: <Widget>[
                    DrawerHeader(
                      child: Image.asset('images/PalamLogo.png'),
                    ),
                    ListTile(
                        title: Text('Home'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => AdminPage()));
                        }
                    ),
                    ListTile(
                        title: Text('View Teachers'),
                        onTap: () {
                          Navigator.pop(context);
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
                  stream: Firestore.instance.collection('users').where(
                      'status', isEqualTo: 'teacher').snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                            Text('   Loading')
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          debugPrint('value $value');
                          while (value.length > 0) {
                            value.removeLast();
                          }
                          while (value.length <
                              snapshot.data.documents.length) {
                            value.add(false);
                          }
                          if (!snapshot.data.documents[index]['approved']) {
                            value[index] = false;
                          }
                          else if (snapshot.data.documents[index]['approved']) {
                            value[index] = true;
                          }
                          return new ListTile(
                              title: Text(
                                  snapshot.data.documents[index]['name']),
                              trailing: Switch(value: value[index],
                                  onChanged: (bool change) {
                                    setState(() {
                                      value[index] = change;
                                    });
                                    Firestore.instance.collection('users')
                                        .where('uid', isEqualTo: snapshot.data
                                        .documents[index]['uid']).getDocuments()
                                        .then((docs) {
                                      DocumentReference ref = docs.documents[0]
                                          .reference;
                                      ref.updateData(
                                          {
                                            'approved': change
                                          }
                                      );
                                    });
                                  })
                          );
                        }
                    );
                  }
              )
          );
        }
        else{
          return Wait(auth: widget.auth, onSignedOut: widget.onSignedOut,);
        }
      },
    );
  }
}
