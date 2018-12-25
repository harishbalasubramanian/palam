import 'package:flutter/material.dart';
import 'teacher_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class StudentView extends StatefulWidget {
  @override
  StudentViewState createState() => StudentViewState();
}

class StudentViewState extends State<StudentView> {
  List<bool> value = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View All Students'),
        backgroundColor: Colors.orange,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Home'),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TeacherPage()));
              }
            ),
            ListTile(
              title: Text('View Students'),
              onTap: () {
                Navigator.pop(context);
              }
            ),

          ],
        ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('users').where('status',isEqualTo: 'student').snapshots(),
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
              value != [] ? value.removeRange(0,value.length) : null;
              while(value.length < snapshot.data.documents.length){
                value.add(false);
              }
              if(snapshot.data.documents[index]['approved'] == 'false'){
                value[index] = false;
              }
              else if (snapshot.data.documents[index]['approved'] == 'true'){
                value[index] = true;
              }
              debugPrint('index $index');
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
