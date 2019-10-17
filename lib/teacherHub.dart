import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication/auth.dart';
import 'authentication/Login.dart';
import 'admin_page.dart';
import 'authentication/root_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Wait.dart';
import 'teacher_page.dart';
import 'dart:math';
class TeacherHub extends StatefulWidget {
  BaseAuth auth;
  VoidCallback onSignedOut;
  TeacherHub({this.auth,this.onSignedOut});
  @override
  TeacherHubState createState() => TeacherHubState();
}

class TeacherHubState extends State<TeacherHub> {
  FirebaseMessaging messaging = new FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hub'),
        backgroundColor: Colors.orange,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed:(){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>CreatePage(auth: widget.auth, onSignedOut: widget.onSignedOut)));
              }
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
                child: Image.asset('images/PalamLogo.png')
            ),
            ListTile(
                title: Text('Hub'),
                onTap: () {
                  Navigator.pop(context);

                }
            ),

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
            if(!snapshot.hasData){
              return Center(
                child: Row(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('   Loading'),
                  ],
                ),
              );
            }
            if(snapshot.data.documents[0].data['classes'] == null){
              return Center(
                child: Text('No classes created'),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data.documents[0].data['classes'].length,
              itemBuilder: (BuildContext context, int index){
                return ListTile(
                  title: Text(snapshot.data.documents[0].data['classes'][index]),

                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>TeacherPage(auth: widget.auth, onSignedOut: widget.onSignedOut, uid: RootPageState.uid,className: snapshot.data.documents[0].data['classes'][index],code: snapshot.data.documents[0].data['codes'][index],teacherName: snapshot.data.documents[0].data['teachers'][index])));
                  },
                );
              },
            );
          }
      ),
    );
  }
}
class CreatePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  CreatePage({@required this.auth, @required this.onSignedOut});
  @override
  CreatePageState createState() => CreatePageState();
}

class CreatePageState extends State<CreatePage> {
  TextEditingController control = new TextEditingController();
  int counter(){
    int number = 0;
    String name = '';
    String text = control.text;
    Firestore.instance.collection('classes').getDocuments().then((docs){
      for(int i = 0; i < docs.documents.length; i++ ){
        name = docs.documents[i].data['name'];
        debugPrint('name $name');
        if (name.contains(text) && text != null){
          number++;
        }
      }
    });
    return number;
  }
  List<Widget> names = new List<Widget>();
//  Map<String, dynamic> listToMap ({@required List values, @required List<String> keys}){
//    assert(values.length == keys.length);
//    Map<String, dynamic> map = {};
//    for(int i = 0; i < values.length; i++){
//      map.addAll({
//        keys[i] : values[i]
//      });
//    }
//    return map;
//  }
  Random rand = Random();
  GlobalKey<FormState> form = new GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffold = new GlobalKey<ScaffoldState>();
  bool check = true;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('users').where('uid',isEqualTo: RootPageState.uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Scaffold(
            appBar: AppBar(
              title: Text('Getting Data'),
            ),
            body: Center(
              child: Row(
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text('   Loading'),
                ],
              ),
            ),
          );
        }
        if(snapshot.data.documents[0].data['approved']) {
          return Scaffold(
            key: scaffold,
            appBar: AppBar(
              title: Text('Create Class'),
            ),
            body: Center(
              child: Form(
                key: form,
                child: Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 15.0)),
                    Container(
                      padding: EdgeInsets.all(15.0),
                      child: TextFormField(
                        controller: control,
                        decoration: InputDecoration(
                          labelText: 'Enter Class Name',

                        ),
                        maxLength: 15,

                      ),

                    ),
                    RawMaterialButton(
                        fillColor: Colors.orange,
                        elevation: 0.0,
                        child: Text('Create Class'),
                        shape: new RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        onPressed: () async {
                          String r = '';
                          for(int i = 0; i < 6; i++){
                            int ran = rand.nextInt(62);
                            r += ran.toString();
                            switch(ran){
                              case 10:
                                r += 'a';
                                break;
                              case 11:
                                r += 'b';
                                break;
                              case 12:
                                r += 'c';
                                break;
                              case 13:
                                r += 'd';
                                break;
                              case 14:
                                r += 'e';
                                break;
                              case 15:
                                r += 'f';
                                break;
                              case 16:
                                r += 'g';
                                break;
                              case 17:
                                r += 'h';
                                break;
                              case 18:
                                r += 'i';
                                break;
                              case 19:
                                r += 'j';
                                break;
                              case 20:
                                r += 'k';
                                break;
                              case 60:
                                r += 'l';
                                break;
                              case 21:
                                r += 'm';
                                break;
                              case 22:
                                r += 'n';
                                break;
                              case 23:
                                r += 'o';
                                break;
                              case 24:
                                r += 'p';
                                break;
                              case 25:
                                r += 'q';
                                break;
                              case 26:
                                r += 'r';
                                break;
                              case 27:
                                r += 's';
                                break;
                              case 28:
                                r += 't';
                                break;
                              case 29:
                                r += 'u';
                                break;
                              case 30:
                                r += 'v';
                                break;
                              case 31:
                                r += 'w';
                                break;
                              case 32:
                                r += 'x';
                                break;
                              case 33:
                                r += 'y';
                                break;
                              case 34:
                                r += 'z';
                                break;
                              case 35:
                                r += 'A';
                                break;
                              case 36:
                                r += 'B';
                                break;
                              case 37:
                                r += 'C';
                                break;
                              case 38:
                                r += 'D';
                                break;
                              case 39:
                                r += 'E';
                                break;
                              case 40:
                                r += 'F';
                                break;
                              case 41:
                                r += 'G';
                                break;
                              case 42:
                                r += 'H';
                                break;
                              case 43:
                                r += 'I';
                                break;
                              case 44:
                                r += 'J';
                                break;
                              case 45:
                                r += 'K';
                                break;
                              case 61:
                                r += 'L';
                                break;
                              case 46:
                                r += 'M';
                                break;
                              case 47:
                                r += 'N';
                                break;
                              case 48:
                                r += 'O';
                                break;
                              case 49:
                                r += 'P';
                                break;
                              case 50:
                                r += 'Q';
                                break;
                              case 51:
                                r += 'R';
                                break;
                              case 52:
                                r += 'S';
                                break;
                              case 53:
                                r += 'T';
                                break;
                              case 54:
                                r += 'U';
                                break;
                              case 55:
                                r += 'V';
                                break;
                              case 56:
                                r += 'W';
                                break;
                              case 57:
                                r += 'X';
                                break;
                              case 58:
                                r += 'Y';
                                break;
                              case 59:
                                r += 'Z';
                                break;
                            }
                            debugPrint('r $r');
                            if(r.length >= 6) {
                              QuerySnapshot s = await Firestore.instance
                                  .collection('classes').where(
                                  'code', isEqualTo: r.substring(0,6)).getDocuments();
                              debugPrint('s ${s.documents.length == 0}');
                              if (s.documents.length != 0) {
                                i = -1;
                                r = '';
                                continue;
                              }
                              else {
                                r = r.substring(0,6);
                                break;
                              }
                            }
                          }
                          Firestore.instance.collection('classes').document().setData({
                            'code' : r,
                            'name' : control.text,
                            'teacherName' : snapshot.data.documents[0].data['name'],
                          });
                          QuerySnapshot snapps = await Firestore.instance.collection('users').where('uid',isEqualTo: RootPageState.uid).getDocuments();
                          List classes = new List();
                          if(snapps.documents[0].data['classes'] != null){
                            classes.addAll(snapps.documents[0].data['classes']);
                          }
                          classes.add(control.text);
                          List codes = new List();
                          if(snapps.documents[0].data['codes'] != null){
                            codes.addAll(snapps.documents[0].data['codes']);
                          }
                          codes.add(r);
                          List teachers = new List();
                          if(snapps.documents[0].data['teachers'] != null){
                            teachers.addAll(snapps.documents[0].data['teachers']);
                          }
                          teachers.add(snapshot.data.documents[0].data['name']);
                          Firestore.instance.collection('users').document(snapshot.data.documents[0].documentID).updateData(
                            {
                              'classes' : classes,
                              'codes' : codes,
                              'teachers' : teachers,
                            }
                          );

                          Navigator.pop(context);
                        }
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        else{
          return Wait(auth: widget.auth, onSignedOut: widget.onSignedOut);
        }
      },
    );
  }
  bool validateAndSave(){

  }
}
