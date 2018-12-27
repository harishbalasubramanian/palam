import 'package:flutter/material.dart';
import 'admin_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication/Login.dart';
import 'authentication/root_page.dart';
import 'authentication/auth.dart';
import 'student_view.dart';
class TeacherView extends StatefulWidget {
  @override
  TeacherViewState createState() => TeacherViewState();
}

class TeacherViewState extends State<TeacherView> {
  List<bool> value = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('View All Teachers'),
          backgroundColor: Colors.orange,
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                  title: Text('Home'),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminPage()));
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
                onTap: (){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentView()));
                }
              ):Container(),
              ListTile(
                  title: Text('Sign Out'),
                  onTap: ()async{
                    AdminPageState.signedIn = false;
                    try{
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
                    }catch(e){
                      debugPrint('e $e');
//      onSignedOut();
                    }
                  }
              ),
            ],
          ),
        ),
        body: StreamBuilder(
            stream: Firestore.instance.collection('users').where('status',isEqualTo: 'teacher').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if(!snapshot.hasData){
                return Center(
                  child: Row(
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Text('   Loading')
                    ],
                  ),
                );
              }

              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index){

                    debugPrint('value $value');
                    while(value.length >0){
                      value.removeLast();
                    }
                    while(value.length < snapshot.data.documents.length){
                      value.add(false);
                    }
                    if(snapshot.data.documents[index]['approved'] == 'false'){
                      value[index] = false;
                    }
                    else if (snapshot.data.documents[index]['approved'] == 'true'){
                      value[index] = true;
                    }
                    return new ListTile(
                        title: Text(snapshot.data.documents[index]['name']),
                        trailing: Switch(value: value[index], onChanged: (bool change){
                          setState(() {
                            value[index] = change;
                          });
                          Firestore.instance.collection('users').where('uid',isEqualTo: snapshot.data.documents[index]['uid']).getDocuments().then((docs){
                            DocumentReference ref = docs.documents[0].reference;
                            ref.updateData(
                                {
                                  'approved' : change ? 'true' : 'false'
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
}
