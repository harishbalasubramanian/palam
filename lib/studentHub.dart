import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication/auth.dart';
import 'authentication/Login.dart';
import 'admin_page.dart';
import 'authentication/root_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_page.dart';
import 'teacher_page.dart';
class StudentHub extends StatefulWidget {
  BaseAuth auth;
  VoidCallback onSignedOut;
  StudentHub({this.auth,this.onSignedOut});
  @override
  StudentHubState createState() => StudentHubState();
}

class StudentHubState extends State<StudentHub> {
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
              Navigator.push(context, MaterialPageRoute(builder: (context)=>AddPage()));
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
            return ListView.builder(
              itemCount: snapshot.data.documents[0].data['classes'].length,
              itemBuilder: (BuildContext context, int index){
                return ListTile(
                  title: Text(snapshot.data.documents[0].data['classes'][index]),
                  subtitle: Text(snapshot.data.documents[0].data['teachers'][index]),
                  onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentPage(auth: widget.auth, onSignedOut: widget.onSignedOut, uid: RootPageState.uid,className: snapshot.data.documents[0].data['classes'][index])));
                  },
                );
              },
            );
          }
      ),
    );
  }
}
class AddPage extends StatefulWidget {
  @override
  AddPageState createState() => AddPageState();
}

class AddPageState extends State<AddPage> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Class'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 15.0)),
            Container(
              padding: EdgeInsets.all(15.0),
              child: TextField(
                controller: control,
                decoration: InputDecoration(
                  labelText: 'Enter Code',

                ),
                maxLength: 6
              ),

            ),
            RawMaterialButton(
              fillColor: Colors.orange,
              elevation: 0.0,
              child: Text('Join Class'),
              shape: new RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              onPressed: ()async{

                QuerySnapshot snap = await Firestore.instance.collection('classes').where('code',isEqualTo: control.text).getDocuments();
                QuerySnapshot snapshot = await Firestore.instance.collection('users').where('uid',isEqualTo: RootPageState.uuserId).getDocuments();
                try {
                  bool check = false;
                  check = snapshot.documents[0].data['classes'] == null;
                  if (!((snapshot.documents[0].data['classes']).contains(
                      snap.documents[0].data['name'])) || check) {

                    await Firestore.instance.collection('classes').document(snap.documents[0].documentID).collection('users').document().setData({
                      'approved': false,
                      'email': snapshot.documents[0].data['email'],
                      'uid': snapshot.documents[0].data['uid'],
                      'fcmtoken': snapshot.documents[0].data['fcmtoken'],
                      'name': snapshot.documents[0].data['name'],
                      'status': snapshot.documents[0].data['status'],
                    });
                    snap = await Firestore.instance.collection('classes').where('code',isEqualTo: control.text).getDocuments();

                    List classList = new List.from(snapshot.documents[0].data['classes']);
                    List codeList = new List.from(snapshot.documents[0].data['codes']);
                    List teacherList = new List.from(snapshot.documents[0].data['classes']);
                    classList.add(snap.documents[0].data['name']);
                    teacherList.add(snap.documents[0].data['teacherName']);
                    codeList.add(snap.documents[0].data['code']);
                    await Firestore.instance.collection('users').document(snapshot.documents[0].documentID).updateData({
                      'classes' : classList,
                      'teachers' : teacherList,
                      'codes' : codeList,
                    });
                  }
                }catch(e){
//                  await Firestore.instance.collection('classes').document(snap.documents[0].documentID).collection('users').document().setData({
//                    'approved': false,
//                    'email': snapshot.documents[0].data['email'],
//                    'uid': snapshot.documents[0].data['uid'],
//                    'fcmtoken': snapshot.documents[0].data['fcmtoken'],
//                    'name': snapshot.documents[0].data['name'],
//                    'status': snapshot.documents[0].data['status'],
//                  });
//
//
//                  snap = await Firestore.instance.collection('classes').where('code',isEqualTo: control.text).getDocuments();
//                  List classList = new List.from(snapshot.documents[0].data['classes']);
//                  List teacherList = new List.from(snapshot.documents[0].data['classes']);
//                  classList.add(snap.documents[0].data['name']);
//                  teacherList.add(snap.documents[0].data['teacherName']);
//                  await Firestore.instance.collection('users').document(snapshot.documents[0].documentID).updateData({
//                    'classes' : classList,
//                    'teachers' : teacherList,
//                  });
                  debugPrint('e $e');
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}
