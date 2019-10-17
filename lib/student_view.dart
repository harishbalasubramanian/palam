import 'package:flutter/material.dart';
import 'teacher_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication/Login.dart';
import 'authentication/root_page.dart';
import 'authentication/auth.dart';
import 'teacher_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'admin_page.dart';
import 'Wait.dart';
import 'teacherHub.dart';
class StudentView extends StatefulWidget {
  BaseAuth auth;
  VoidCallback onSignedOut;
  final String reference;
  StudentView(this.auth, this.onSignedOut, {this.reference});
  @override
  StudentViewState createState() => StudentViewState();
}

class StudentViewState extends State<StudentView> {
  List<bool> value = [];
  FirebaseMessaging messaging = new FirebaseMessaging();

  String role = '';
  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: Firestore.instance.collection('users').where('uid',isEqualTo: RootPageState.uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.orange,
              title: Text('View All Students'),
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
                title: Text('View All Students'),
                backgroundColor: Colors.orange,
              ),
              drawer: Drawer(
                child: ListView(
                  children: <Widget>[
                    DrawerHeader(
                      child: Image.asset('images/PalamLogo.png'),
                    ),
                    ListTile(
                      title: Text('Back to Hub'),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>TeacherHub()),);
                      }
                    ),
                    ListTile(
                        title: Text('Home'),
                        onTap: () async{
                          Navigator.pop(context);

                          QuerySnapshot fire = await Firestore.instance.collection('classes').where('code',isEqualTo: TeacherPageState.code).getDocuments();
                          if (RootPageState.auth == AuthStatus.teacher)
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => TeacherPage(auth: widget.auth, onSignedOut: widget.onSignedOut, uid: snapshot.data.documents[0].data['uid'],
                                className: fire.documents[0].data['className'], code: fire.documents[0].data['code'], teacherName: fire.documents[0].data['teacherName'],
                                )));
                          else
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => AdminPage()));
                        }
                    ),
                    RootPageState.auth == AuthStatus.admin ? ListTile(
                        title: Text('View Teachers'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => TeacherView(widget.auth, widget.onSignedOut)));
                        }
                    ) : Container(),
                    ListTile(
                        title: Text('View Students'),
                        onTap: () {
                          Navigator.pop(context);
                        }
                    ),
                    ListTile(
                        title: Text('Sign Out'),
                        onTap: () async {
                          TeacherPageState.signedIn = false;
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
//                  stream: Firestore.instance.collection('classes').document(widget.reference).collection('users').where(
//                      'status', isEqualTo: 'student').snapshots(),
                  stream: Firestore.instance.collection('users').where(
                      'status', isEqualTo: 'student').snapshots(),
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
//                    debugPrint(snapshot.data.documents[0].data['approved'].toString());
                          if (!snapshot.data.documents[index]
                              .data['approved']) {
                            value[index] = false;
                          }

                          else if (snapshot.data.documents[index]['approved']) {
                            value[index] = true;
                          }

                          return new ListTile(
                              title: Text(
                                  snapshot.data.documents[index]['name']),
                              trailing: Switch(
                                  value: value[index],
                                  onChanged: (bool change) {
                                    setState(() {
                                      value[index] = change;
                                    });
                                    Firestore.instance.collection('users')
                                        .where(
                                        'uid', isEqualTo: snapshot.data
                                        .documents[index]['uid'])
                                        .getDocuments()
                                        .then((docs) {
                                      DocumentReference ref = docs.documents[0]
                                          .reference;
                                      debugPrint('heello');
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
