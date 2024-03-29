import 'package:flutter/material.dart';
import 'package:prsd/authentication/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication/Login.dart';
import 'authentication/root_page.dart';
import 'package:chewie/chewie.dart';
import 'student_view.dart';
import 'package:dio/dio.dart';
import 'Wait.dart';
import 'teacherHub.dart';
class TeacherPage extends StatefulWidget{
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String className;
  String uid;
  final String code;
  final String teacherName;
  TeacherPage({this.auth,this.onSignedOut,this.uid, this.className, this.code,this.teacherName});
  @override
  State<StatefulWidget> createState() {
    return new TeacherPageState(auth: auth, onSignedOut: onSignedOut,uid: uid);
  }


}

class TeacherPageState extends State<TeacherPage>{
  String _path;
  static File _cachedFile;
  static List<bool> sneck = [];
  String curpath;
  StorageUploadTask u;
  SharedPreferences prefs;
  static String className = '';
  static String url = '';
  GlobalKey<ScaffoldState> scaffold = new GlobalKey<ScaffoldState>();
  //static FlutterDocumentPickerParams params;
  String uid;
  TeacherPageState({this.auth,this.onSignedOut,this.uid});
  BaseAuth auth;
  static bool signedIn;
  static String reference = '';
  bool loading = false;
  final VoidCallback onSignedOut;
  static String code ='';
  void signOut() async{
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
        Auth.remail = '';
        Auth.rname = '';
        Auth.rstatus = null;
      });
      debugPrint('${RootPageState.authStatus}');
    }catch(e){
      debugPrint('e $e');
//      onSignedOut();
    }

//    try {
//      FirebaseAuth.instance.signOut();
//      LoginPageState.auth = RootPageState.auth = Auth.bauth = null;
//    }catch(e){
//      debugPrint('e $e');
//    }
  }

  FirebaseMessaging messaging = new FirebaseMessaging();
  @override
  void initState(){
    super.initState();
//    params = FlutterDocumentPickerParams(
//      allowedFileExtensions: ['txt'],
//    );
    signedIn = true;
    code = widget.code;
    className = widget.className;
    messaging.configure(
      onLaunch: (Map<String, dynamic> map){
        debugPrint('onLaunch called');
      },
      onMessage: (Map<String, dynamic> map){
        debugPrint('onMessage called');
      },
      onResume: (Map<String, dynamic> map){
        debugPrint('onResume called');
      },
    );
    messaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true,
          alert: true,
          badge: true
      ),
    );
    messaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      debugPrint('IOS Settings Registered');
    });
    SharedPreferences.getInstance().then((prefer)async {
      Set<String> keys = prefer.getKeys();
      //QuerySnapshot snapshot = await Firestore.instance.collection('classes').document(reference).collection('videos').getDocuments());
      QuerySnapshot snap = await Firestore.instance.collection('classes')
          .document(reference).collection('videos')
          .getDocuments();
      List<DocumentSnapshot> snupshot = snap.documents;
      keys.forEach((snapshot) {
        if(snapshot.contains('.mp4')){
          String naame = prefs.getString(widget.code+snapshot);
          if (naame !=
              null) {
            File file = File(
                naame);
            file.delete();
          }
          String naaame = prefs
              .getString(
              widget
                  .code +
                  'Test' +
                  snapshot) ??
              null;
          if (naaame !=
              null) {
            File file = File(
                naaame);
            file.delete();
          }
          NextPageState
              .check =
          false;
          try {
            prefs.remove(
                widget
                    .code +
                    snapshot);
            prefs.remove(
                widget
                    .code +
                    'Test' +
                    snapshot
                        .replaceAll(
                        '.mp4',
                        '.txt'));
          } catch (e) {

          }
          setState(() {
            cool = true;
          });
        }
      });

//      if (naame !=
//          null) {
//        File file = File(
//            naame);
//        file.delete();
//      }
//      String naaame = prefs
//          .getString(
//          widget
//              .teacherName +
//              'Test' +
//              snapshot['name']) ??
//          null;
//      if (naaame !=
//          null) {
//        File file = File(
//            naaame);
//        file.delete();
//      }
//      NextPageState
//          .check =
//      false;
//      try {
//        prefs.remove(
//            widget
//                .teacherName +
//                snapshot['name']);
//        prefs.remove(
//            widget
//                .teacherName +
//                'Test' +
//                snapshot['name']
//                    .replaceAll(
//                    '.mp4',
//                    '.txt'));
//      } catch (e) {
//
//      }
//      setState(() {
//        cool = true;
//      });
    });
  }


  void init() async {
    prefs = await SharedPreferences.getInstance();
  }
  static var httpClient = new HttpClient();
  void downloadFile (String url,String name) async{
//    bool check = false;
//    while(!check){
//      if(Platform.isIOS){
//        check = true;
//        continue;
//      }
//      PermissionStatus perm = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
//      if(perm != PermissionStatus.granted){
//        Map<PermissionGroup,PermissionStatus> map = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
//        if(map[PermissionGroup.storage] == PermissionStatus.granted){
//          check = true;
//          continue;
//        }
//        else{
//          continue;
//        }
//      }
//      else{
//        check = true;
//        continue;
//      }
//    }
//    String task = '';
    try {
      Dio dio = Dio();
      String dir = (await getApplicationDocumentsDirectory()).path;
      String path = '$dir/$name';
      await dio.download(url, path);
      prefs = await SharedPreferences.getInstance();

      prefs.setString(widget.code+name,path);

      debugPrint(path);
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>NextPage(auth: auth, onSignedOut: onSignedOut, name: name, url: url, task: path)));


//      debugPrint((await getExternalStorageDirectory()).path);
//      String directory = (await getExternalStorageDirectory()).path;
//      FlutterDownloader.enqueue(
//          url: url,
//          savedDir: directory,
//        showNotification: true,
//        openFileFromNotification: true,
//      ).then((string)async {
//        task = string;
//        prefs = await SharedPreferences.getInstance();
//        prefs.setString(name, task);
//      });

    }catch(e){
      debugPrint('error in download $e');
    }
    return null;
  }
  bool a;

  static List<Color> calor = new List<Color>();
  Future<List<bool>> firestoree (int index,DocumentSnapshot snapshot) async {
    bool check;
    bool smeck;
    QuerySnapshot docs = await Firestore.instance.collection('classes').document(reference).collection('tests').where('name',isEqualTo: snapshot['name'].replaceAll('.mp4','.txt')).getDocuments();
//      Future<bool> name = Firestore.instance.collection('tests').where('name', isEqualTo: snapshot['name'].replaceAll('.mp4', '.txt')).getDocuments().then((docs){
//     try {
//       if (docs.documents[0].exists) check = true;
//
//       SharedPreferences.getInstance().then((pref) {
//         prefs = pref;
//       });
//       cool = prefs.getString(snapshot['name']) != null ? false : true;
//
//     }catch(e){
//       if (e.toString() ==
//           'RangeError (index): Invalid value: Valid value range is empty: 0') {
//         check = false;
//       }
//     }
//     return check;

    try{
      if(docs.documents[0].exists) check = true;
      prefs = await SharedPreferences.getInstance();
      cool = prefs.getString(widget.code+snapshot['name']) != null ? false : true;

    }catch(e){
      if (e.toString() == 'RangeError (index): Invalid value: Valid value range is empty: 0') {
        check = false;
      }
    }
    smeck = prefs.getString(widget.code+snapshot['name']) != null ? false : true;
    return [check,smeck];
  }

//  fire(int index, DocumentSnapshot snapshot, bool dreck)async{
//    dreck = false;
//      await firestoree(index, snapshot).then((boolean){
//        dreck = boolean;
//
//      });
//      debugPrint(dreck.toString());
//  }
  static bool cool = false;

  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: Firestore.instance.collection('classes').where('code',isEqualTo: code).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snupshot){
        if(!snupshot.hasData){
          return Scaffold(
            appBar: AppBar(
              title: Text('Getting Data'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        reference = snupshot.data.documents[0].documentID;
        debugPrint('reference $reference');
        return Scaffold(
        key: scaffold,
        appBar: AppBar(
          title: Text(snupshot.data.documents[0].data['name']),
           // ,trailing: Image.asset('images/PalamLogo.jpeg'),

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
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>TeacherHub(auth: widget.auth, onSignedOut: widget.onSignedOut,)),);
                }
              ),
              ListTile(
                  title: Text('Home'),
                  onTap: (){
                    Navigator.pop(context);
                  }
              ),

              ListTile(
                  title: Text('View Students'),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>StudentView(auth, onSignedOut, reference: reference)));
                  }
              ),
              ListTile(
                title: Text('View Code'),
                onTap : (){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CodePage(auth: auth, onSignedOut: onSignedOut, reference: reference,)));
                }
              ),
              ListTile(
                  title: Text('Sign Out'),
                  onTap: (){
                    setState(() {
                      signedIn = false;
                    });
                    messaging.unsubscribeFromTopic('studentNotifier');
                    messaging.unsubscribeFromTopic('teacherNotifier');
                    signOut();
                  }
              ),
            ],
          ),
        ),
        body: !loading && signedIn ? StreamBuilder(
            stream: Firestore.instance.collection('classes').document(reference).collection('videos').snapshots(),
            builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
              debugPrint('refs '+reference);
              if(!snap.hasData)
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(),
                      Text('   Loading'),
                    ],
                  ),
                );
              final int messageCount = snap.data.documents.length;


              if(messageCount == 0) return Center( child : Text('No videos were uploaded'));
              return ListView.builder(
                  itemCount: messageCount,
                  itemBuilder: (BuildContext context, int index){

                    DocumentSnapshot snapshot = snap.data.documents[index];
                    sneck.removeRange(0,sneck.length);
                    for(int i = 0; i < messageCount; i++){
                      sneck.add(false);
                      //debugPrint('i $i');
                    }

                    while(index+1>calor.length){
                      calor.add(Colors.orange);
                    }
//                  colorr(snapshot['name'].replaceAll('.mp4','.txt'),index);
                    SharedPreferences.getInstance().then((pref){
                      prefs = pref;
                      //debugPrint('sup '+prefs.get(snapshot['name']).toString());
                    });
                    //debugPrint(calor[index].toString());



//                  Firestore.instance.collection('tests').where('name', isEqualTo: snapshot['name'].replaceAll('.mp4', '.txt')).getDocuments().then((docs){
//                    try {
//                      if (docs.documents[0].exists) value = true;
//
//                      SharedPreferences.getInstance().then((pref) {
//                        prefs = pref;
//                      });
//                      cool = prefs.getString(snapshot['name']) != null ? false : true;
//
//                    }catch(e){
//                      if (e.toString() ==
//                          'RangeError (index): Invalid value: Valid value range is empty: 0') {
//                        value = false;
//                      }
//                    }
//
//                  });
                    return FutureBuilder(
                        future: firestoree(index, snapshot),
                        builder : (BuildContext context, AsyncSnapshot<List<bool>> snapper) {
                          //debugPrint(snapper.data.toString() + 'snam');
                          if(!snapper.hasData){
                            return Center(
                                child: CircularProgressIndicator()
                            );
                          }
                          if (snapper.hasData) {
                            cool = snapper.data[1];
                            if (snapper.data[0]) {

                              return ExpansionTile(
                                title: ListTile(
                                    title: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(padding: EdgeInsets.only(left: 16.0)),
                                        Text(snapshot['name'].replaceAll('.mp4',''), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 15.0),),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget> [
                                        snapper.data[1] ? Container(
                                          width: 40.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.green,
                                            ),
                                            child: IconButton(
                                          icon: Icon(Icons.file_download,color: Colors.white),
                                          color: Theme
                                              .of(context)
                                              .accentColor,
                                          onPressed: () async {
                                            setState(() {
                                              loading = true;
                                            });
                                            await downloadFile(
                                                snapshot['downloadURL'],
                                                snapshot['name']);
                                            QuerySnapshot snapper = await Firestore
                                                .instance.collection('classes').document(reference).collection('tests')
                                                .where('name',
                                                isEqualTo: snapshot['name']
                                                    .replaceAll('.mp4', '.txt'))
                                                .getDocuments();
                                            if (snapper.documents[0].exists) {
                                              await downloadFile(
                                                  snapper
                                                      .documents[0]['downloadURL'],
                                                  'Test' +
                                                      snapper.documents[0]['name']);
                                            }
                                            setState(() {
                                              loading = false;
                                              scaffold.currentState.showSnackBar(
                                                  SnackBar(
                                                    content: Text(snapshot['name'] +
                                                        ' has downloaded'),
                                                  ));
                                              cool = false;
                                            });
                                          },

                                        )) :
                                  Container(
                                      width: 40.0,
                                    decoration: BoxDecoration(

                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                        child: IconButton(
                                            icon: Icon(Icons.delete, color: Colors.white),

                                            onPressed: () async {
                                              var alert = AlertDialog(
                                                title: Text(
                                                    'Are you sure that you want to delete this from your device?'),
                                                content: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    FlatButton(
                                                        child: Text('Yes'),
                                                        onPressed: () async {
                                                          prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                          String naame = prefs
                                                              .getString(
                                                              widget.code+snapshot['name']) ??
                                                              null;
                                                          debugPrint(naame);
                                                          if (naame != null) {
                                                            File file = File(naame);
                                                            file.delete();
                                                          }
                                                          NextPageState.check =
                                                          false;
                                                          prefs.remove(
                                                              widget.code+snapshot['name']);
                                                          prefs.remove(widget.code+'Test' +
                                                              snapshot['name']
                                                                  .replaceAll(
                                                                  '.mp4', '.txt'));
                                                          setState(() {
                                                            cool = true;
                                                          });
                                                          Navigator.pop(context);
                                                        }
                                                    ),
                                                    FlatButton(
                                                        child: Text('No'),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        }
                                                    ),

                                                  ],
                                                ),
                                              );
                                              showDialog(context: context,
                                                  builder: (context) {
                                                    return alert;
                                                  });
                                            }
                                        )),
                                        Container(
                                          width: 40.0,

                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red,
                                          ),
                                          child: IconButton(
                                              icon: Icon(Icons.delete_forever, color: Colors.white,),
                                              onPressed: () async {
                                                var alert = AlertDialog(
                                                  title: Text(
                                                      'Are you sure that you want to delete this from the cloud?'),
                                                  content: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      FlatButton(
                                                          child: Text('Yes'),
                                                          onPressed: () async {
                                                            Directory dir = Directory
                                                                .systemTemp;
                                                            File file = File('${dir
                                                                .path}/${snapshot['name']}');
                                                            StorageReference ref = FirebaseStorage
                                                                .instance.ref().child(
                                                                file.path.replaceAll(
                                                                    '${Directory.systemTemp.path}',
                                                                    'videos'));
                                                            ref.delete();
                                                            await Firestore.instance
                                                                .collection('classes').document(reference).collection('videos')
                                                                .where('name',
                                                                isEqualTo: snapshot['name'])
                                                                .getDocuments()
                                                                .then((docs) {
                                                              docs.documents[0]
                                                                  .reference.delete();
                                                            });
                                                            dir =
                                                                Directory.systemTemp;
                                                            file = File('${dir
                                                                .path}/${snapshot['name']
                                                                .replaceAll(
                                                                '.mp4', '.txt')
                                                                .replaceAll(
                                                                ' ', '')}');
                                                            ref =
                                                                FirebaseStorage
                                                                    .instance
                                                                    .ref().child(
                                                                    file.path
                                                                        .replaceAll(
                                                                        '${Directory.systemTemp.path}',
                                                                        'tests'));
                                                            ref.delete();
                                                            Firestore.instance
                                                                .collection('classes').document(reference).collection('tests')
                                                                .where('name',
                                                                isEqualTo: snapshot['name']
                                                                    .replaceAll(
                                                                    '.mp4', '.txt')
                                                                    .replaceAll(
                                                                    ' ', ''))
                                                                .getDocuments()
                                                                .then((docs) {
                                                              docs.documents[0]
                                                                  .reference.delete();
                                                            });
                                                            prefs =
                                                            await SharedPreferences
                                                                .getInstance();


                                                            try {
                                                              prefs.remove(
                                                                  widget.code+snapshot['name']);
                                                              prefs.remove(
                                                                  widget.code+snapshot['name']
                                                                      .replaceAll(
                                                                      ' ', '')
                                                                      .replaceAll(
                                                                      '.mp4',
                                                                      '.txt'));
                                                            } catch (e) {
                                                              debugPrint('e $e');
                                                            }
                                                            prefs.setBool(
                                                                widget.code+snapshot['name']
                                                                    .replaceAll(
                                                                    ' ', '')
                                                                    .replaceAll(
                                                                    '.mp4', '.txt'),
                                                                true);
                                                            Navigator.pop(context);
                                                          }
                                                      ),
                                                      FlatButton(
                                                          child: Text('No'),
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          }
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                showDialog(context: context,
                                                    builder: (context) {
                                                      return alert;
                                                    });
                                              }
                                          ),
                                        ),
                                        Container(
                                          width: 40.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey,
                                          ),
                                          child: IconButton(
                                              icon: Icon(Icons.file_upload,color: Colors.white,),
                                              onPressed: () => null


                                          ),
                                        ),
                          ],
                          ),
                                    enabled: true,
                                    selected: true,


                                    onTap: () async {
                                      url = snapshot['downloadURL'];
                                      debugPrint('url1 $url');
                                      prefs = await SharedPreferences.getInstance();
                                      String task = prefs.getString(
                                          widget.code+snapshot['name']) ?? '';
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) =>
                                              NextPage(
                                                name: snapshot['name'],
                                                task: task,
                                                auth: auth,
                                                onSignedOut: onSignedOut,
                                                url: url,
                                              )));
                                    }
                                ),

                                children: <Widget>[
                                  ListTile(
                                    title: Row(
                                      children: <Widget>[
                                        Padding(padding: EdgeInsets.only(left: 16.0)),
                                        Text(snapshot['name'].replaceAll(
                                            '.mp4', '.txt'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 15.0),),
                                      ],
                                    ),
                                        trailing: Container(
                                          width: 40.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red
                                          ),
                                          child: IconButton(
                                              icon: Icon(Icons.delete_forever, color: Colors.white),

                                              onPressed: () {
                                                var alert = AlertDialog(
                                                  title: Text(
                                                      'Are you sure that you want to delete this from the cloud?'),
                                                  content: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      FlatButton(
                                                          child: Text('Yes'),
                                                          onPressed: () async {
                                                            Directory dir =
                                                                Directory.systemTemp;
                                                            File file = File('${dir
                                                                .path}/${snapshot['name']
                                                                .replaceAll(
                                                                '.mp4', '.txt')
                                                                .replaceAll(
                                                                ' ', '')}');
                                                            StorageReference ref =
                                                            FirebaseStorage
                                                                .instance
                                                                .ref().child(
                                                                file.path
                                                                    .replaceAll(
                                                                    '${Directory.systemTemp.path}',
                                                                    'tests'));
                                                            ref.delete();
                                                            Firestore.instance
                                                                .collection('classes').document(reference).collection('tests')
                                                                .where('name',
                                                                isEqualTo: snapshot['name']
                                                                    .replaceAll(
                                                                    '.mp4', '.txt')
                                                                    .replaceAll(
                                                                    ' ', ''))
                                                                .getDocuments()
                                                                .then((docs) {
                                                              docs.documents[0]
                                                                  .reference.delete();
                                                            });
                                                            prefs =
                                                            await SharedPreferences
                                                                .getInstance();


                                                            try {
                                                              prefs.remove(
                                                                  widget.code+snapshot['name']);
                                                              prefs.remove(
                                                                  widget.code+snapshot['name']
                                                                      .replaceAll(
                                                                      ' ', '')
                                                                      .replaceAll(
                                                                      '.mp4',
                                                                      '.txt'));
                                                            } catch (e) {
                                                              debugPrint('e $e');
                                                            }
                                                            prefs.setBool(
                                                                widget.code+snapshot['name']
                                                                    .replaceAll(
                                                                    ' ', '')
                                                                    .replaceAll(
                                                                    '.mp4', '.txt'),
                                                                true);
                                                            Navigator.pop(context);
                                                            setState(() {

                                                            });
                                                          }
                                                      ),
                                                      FlatButton(
                                                          child: Text('No'),
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          }
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                showDialog(context: context,
                                                    builder: (context) {
                                                      return alert;
                                                    });
                                              }
                                          ),
                                        ),

                                  ),
                                ],
                              );
                            }

                            return ListTile(
                                title:
//                                    Padding(padding: EdgeInsets.only(left: 16.0)),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(padding: EdgeInsets.only(left: 16.0)),
                                        Text(snapshot['name'].replaceAll('.mp4',''), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 15.0),),
                                      ],
                                    ),


                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget> [
                                      snapper.data[1] ? Container(

                                        width: 40.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green
                                          ),
                                          child: IconButton(

                                        icon: Icon(Icons.file_download,color: Colors.white),
//                                        color: Theme
//                                            .of(context)
//                                            .accentColor,
                                        onPressed: () async {
                                          setState(() {
                                            loading = true;
                                          });
                                          await downloadFile(
                                              snapshot['downloadURL'],
                                              snapshot['name']);
                                          setState(() {
                                            loading = false;
                                            scaffold.currentState.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      snapshot['name'] +
                                                          ' has downloaded'),
                                                ));
                                          });
                                          try {
                                            QuerySnapshot snapper = await Firestore
                                                .instance
                                                .collection('classes').document(reference).collection('videos').where('name',
                                                isEqualTo: snapshot['name']
                                                    .replaceAll(
                                                    '.mp4', '.txt')).getDocuments();
                                            if (snapper.documents[0].exists) {
                                              await downloadFile(
                                                  snapper
                                                      .documents[0]['downloadURL'],
                                                  'Test' +
                                                      snapper.documents[0]['name']);
                                            }
                                            setState(() {
                                              loading = false;
                                              scaffold.currentState.showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        snapshot['name'] +
                                                            ' has downloaded'),
                                                  ));
                                              cool = false;
                                            });
                                          } catch (e) {

                                          }
                                        }
                                    )):
                                    Container(
                                      width: 40.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                    child: IconButton(
                                        icon: Icon(Icons.delete, color: Colors.white),

                                        onPressed: () async {
                                          var alert = AlertDialog(
                                            title: Text(
                                                'Are you sure that you want to delete this from your device?'),
                                            content: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                FlatButton(
                                                    child: Text('Yes'),
                                                    onPressed: () async {
                                                      prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                      String naame = prefs
                                                          .getString(
                                                          widget.code+snapshot['name']) ?? null;
                                                      if (naame != null) {
                                                        File file = File(naame);
                                                        file.delete();
                                                      }
                                                      String naaame = prefs
                                                          .getString(widget.code+
                                                          'Test' +
                                                              snapshot['name']) ??
                                                          null;
                                                      if (naaame != null) {
                                                        File file = File(naaame);
                                                        file.delete();
                                                      }
                                                      NextPageState.check = false;
                                                      try {
                                                        prefs.remove(
                                                            widget.code+snapshot['name']);
                                                        prefs.remove(widget.code+'Test' +
                                                            snapshot['name']
                                                                .replaceAll(
                                                                '.mp4', '.txt'));
                                                      } catch (e) {

                                                      }
                                                      setState(() {
                                                        cool = true;
                                                      });
                                                      Navigator.pop(context);
                                                    }
                                                ),
                                                FlatButton(
                                                    child: Text('No'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    }
                                                ),

                                              ],
                                            ),
                                          );
                                          showDialog(
                                              context: context, builder: (context) {
                                            return alert;
                                          });
                                        }
                                    )),
                                    Padding (padding: EdgeInsets.only(right: 8.0)),
                                    Container(
                                      padding: EdgeInsets.only(right: 8.0),
                                      width: 40.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.red,
                                      ),
                                      child: IconButton(
                                          icon: Icon(Icons.delete_forever,color: Colors.white),
                                          onPressed: () async {
                                            var alert = AlertDialog(
                                              title: Text(
                                                  'Are you sure that you want to delete this from the cloud?'),
                                              content: Row(
                                                children: <Widget>[
                                                  FlatButton(
                                                      child: Text('Yes'),
                                                      onPressed: () async {
                                                        try {
                                                          prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                          String naame = prefs
                                                              .getString(
                                                              widget.code+snapshot['name']) ??
                                                              null;
                                                          if (naame != null) {
                                                            File file = File(naame);
                                                            file.delete();
                                                          }
                                                          NextPageState.check = false;
                                                          String naaame = prefs
                                                              .getString(widget.code+'Test' +
                                                              snapshot['name']
                                                                  .replaceAll(
                                                                  '.mp4', '.txt')) ??
                                                              null;
                                                          if (naaame != null) {
                                                            File file2 = File(naaame);
                                                            file2.delete;
                                                          }
                                                        } catch (e) {
                                                          debugPrint(e.toString());
                                                        }
                                                        try {
                                                          Directory dir = Directory
                                                              .systemTemp;
                                                          File file = File('${dir
                                                              .path}/${snapshot['name']}');
                                                          StorageReference ref = FirebaseStorage
                                                              .instance.ref().child(
                                                              file.path.replaceAll(
                                                                  '/data/user/0/com.happssolutions.prsd/cache',
                                                                  'videos'));
                                                          ref.delete();
                                                          await Firestore.instance
                                                              .collection('classes').document(reference).collection('videos')
                                                              .where('name',
                                                              isEqualTo: snapshot['name'])
                                                              .getDocuments()
                                                              .then((docs) {
                                                            docs.documents[0]
                                                                .reference
                                                                .delete();
                                                          });
                                                          dir = Directory.systemTemp;
                                                          file = File('${dir
                                                              .path}/${snapshot['name']
                                                              .replaceAll(
                                                              '.mp4', '.txt')
                                                              .replaceAll(' ', '')}');
                                                          ref =
                                                              FirebaseStorage.instance
                                                                  .ref()
                                                                  .child(
                                                                  file.path
                                                                      .replaceAll(
                                                                      '/data/user/0/com.happssolutions.prsd/cache',
                                                                      'tests'));
                                                          ref.delete();
                                                          Firestore.instance
                                                              .collection(
                                                              'classes').document(reference).collection('tests')
                                                              .where('name',
                                                              isEqualTo: snapshot['name']
                                                                  .replaceAll(
                                                                  '.mp4', '.txt')
                                                                  .replaceAll(
                                                                  ' ', ''))
                                                              .getDocuments()
                                                              .then((docs) {
                                                            docs.documents[0]
                                                                .reference
                                                                .delete();
                                                          });
                                                          prefs =
                                                          await SharedPreferences
                                                              .getInstance();


                                                          try {
                                                            prefs.remove(
                                                                widget.code+snapshot['name']);
                                                            prefs.remove(
                                                                widget.code+snapshot['name']
                                                                    .replaceAll(
                                                                    ' ', '')
                                                                    .replaceAll(
                                                                    '.mp4', '.txt'));
                                                          } catch (e) {
                                                            debugPrint('e $e');
                                                          }
                                                          prefs.setBool(
                                                              widget.code+snapshot['name']
                                                                  .replaceAll(
                                                                  ' ', '')
                                                                  .replaceAll(
                                                                  '.mp4', '.txt'),
                                                              true);
                                                          Navigator.pop(context);
                                                        } catch (e) {

                                                        }
                                                      }
                                                  ),
                                                  FlatButton(
                                                      child: Text('No'),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      }
                                                  ),
                                                ],
                                              ),
                                            );
                                            showDialog(
                                                context: context, builder: (context) {
                                              return alert;
                                            });
                                          }
                                      ),
                                    ),
                                      Padding (padding: EdgeInsets.only(right: 8.0)),
                                    Container(
                                      width: 40.0,

                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green,
                                      ),
                                      child: IconButton(
                                          icon: Icon(Icons.file_upload,color: Colors.white),
                                          color: Colors.orange,
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(
                                                builder: (context) =>
                                                    FileUpload(
                                                      snapshot['name'], auth: auth,
                                                      onSignedOut: onSignedOut,)));
                                            // Put a test wizard here so that files don't have to be uploaded

                                          }


                                      ),
                                    ),
                                  ],
                                ),
                                enabled: true,
                                selected: true,


                                onTap: () async {
                                  url = snapshot['downloadURL'];
                                  debugPrint('url1 $url');
                                  prefs = await SharedPreferences.getInstance();
                                  String task = prefs.getString(widget.code+snapshot['name']) ??
                                      '';
                                  debugPrint('task $task');
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) =>
                                          NextPage(
                                            name: snapshot['name'],
                                            task: task,
                                            auth: auth,
                                            onSignedOut: onSignedOut,
                                            url: url,
                                          )));
                                }
                            );
                          }
                        }
                    );
                  }
              );
            }
        ) :
        Center(child: CircularProgressIndicator()),

        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>new Second(auth: auth, onSignedOut: onSignedOut,)));
//            Navigator.push(context, MaterialPageRoute(builder: (context)=>NextPage()));
//            createVideo();
//            control.play();
            }
        ),
      );
      }
    );
  }
  method(bool cool, DocumentSnapshot snapshot, int index){
    debugPrint('sneck $sneck');

  }
  Future<Color>coloror(String key) async{
    Color color;
    SharedPreferences prefs = await initialize();
    bool a = prefs.getBool(key.replaceAll(' ',''));

    if(a == null){
      a = true;
    }

    if(a){
      color = Colors.orange;
    }
    else{
      color = Colors.grey;
    }

    return color;
  }
  void colorr(String key,int index)async{
    calor[index] = await coloror(key);
    setState(() {

    });
  }
  Future<SharedPreferences> initialize()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

}
class FileUpload extends StatefulWidget{
  FileUpload(this.videoName, {@required this.auth, @required this.onSignedOut});
  String videoName = '';
  BaseAuth auth;
  VoidCallback onSignedOut;
  @override
  State<StatefulWidget> createState() {
    return FileUploadState(this.videoName, auth: auth,onSignedOut: onSignedOut);
  }

}
class FileUploadState extends State<FileUpload>{
  String path = '';
  SharedPreferences prefs;
  String videoName = '';
  String val = '';
  String ind = '';
  bool isLoading = false;
  BaseAuth auth;
  bool validated = true;
  int color = 0;
  TextEditingController controller = new TextEditingController();
  //bool loading = false;
  VoidCallback onSignedOut;
  FileUploadState(this.videoName, {@required this.auth, @required this.onSignedOut});
  Widget build(BuildContext context){
    return StreamBuilder(
      stream: Firestore.instance.collection('users').where('uid',isEqualTo: RootPageState.uid).snapshots(),
      builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.orange,
              title: Text('Quiz Upload'),
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
                title: Text('Quiz Upload'),
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: ()async {
                      QuerySnapshot fire = await Firestore.instance.collection('classes').where('code',isEqualTo: TeacherPageState.code).getDocuments();
                      if (RootPageState.auth == AuthStatus.teacher)
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => TeacherPage(auth: widget.auth, onSignedOut: widget.onSignedOut, uid: snapshot.data.documents[0].data['uid'],
                              className: fire.documents[0].data['className'], code: fire.documents[0].data['code'], teacherName: fire.documents[0].data['teacherName'],
                            )));
                      setState(() {

                      });
                    }
                ),
              ),
              //create wizard here
              body: !isLoading ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
//                  Container(
//                    padding: EdgeInsets.all(8.0),
//                    child: TextField(
//
//                    ),
//                  ),
                  Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            color: color == 1 ? Colors.blueAccent : Colors.grey.shade100,
                            child: Icon(Icons.lock_open),
                            onPressed: (){
                              setState(() {
                                color = 1;
                              });
                            },
                          ),
                          FlatButton(
                            color: color == 2 ? Colors.blueAccent : Colors.grey.shade100,
                            child: Icon(Icons.lock_outline),
                            onPressed: (){
                              setState(() {
                                color = 2;
                              });
                            },
                          ),
                        ],
                      ),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 30.0)),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: color == 2 ? TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Number of Attempts',
                        errorText: !validated ? 'Please input a whole number greater that 0' : null,
                      ),
                    ) : Container(),
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 30.0)),
                  Center(
                    child: RawMaterialButton(

                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        fillColor: Colors.orange,
                        elevation: 0.0,
                        padding: EdgeInsets.all(20.0),
                        child: Text('Upload Quiz'),
                        onPressed: () async {
                          double checker = 0.0;
                          try{
                            checker = double.parse(controller.text);
                            if(checker > 0.0 && checker.roundToDouble() == checker){
                              setState(() {
                                validated = true;
                              });
                            }
                            else{
                              setState(() {
                                validated = false;
                              });
                            }
                          }
                          catch(e){
                            setState(() {
                              validated = false;
                            });
                          }
                          if(validated) {
                            setState(() {
                              isLoading = true;
                            });
                            List<Map<String, dynamic>>test = [];

                            path = await FilePicker.getFilePath(
                                type: FileType.CUSTOM, fileExtension: 'txt');

                            File file = File(path);

                            val = await file.readAsString();
                            List<String> questions = val.split('Question');
                            questions.removeAt(0);
                            for (int i = 0; i < questions.length; i++) {
                              String question = questions[i];
                              List<String> lines = List<String>();
                              question = 'Question$question';
                              int start = 0;
                              int count = 0;
                              while (start >= 0) {
                                start = question.indexOf('Op', start + 1);
                                if (start != -1) {
                                  count++;
                                }
                              }
                              lines = question.split('\n');
                              List<Map<String, dynamic>> options = List<
                                  Map<String, dynamic>>();
                              List<Map<String, dynamic>> explanations = List<
                                  Map<String, dynamic>>();
                              for (int j = 0; j < count; j++) {
                                options.addAll([{
                                  'option ${j + 1}': lines[j + 1].replaceAll(
                                      'Op', '')
                                }
                                ],);
                                explanations.addAll([{
                                  'explanation ${j + 1}': lines[count + j + 3]
                                      .replaceAll('Ex', '')
                                }
                                ],);
                              }

                              test.add(
                                {
                                  'question ${i + 1}': {
                                    'question': lines[0],
                                    'options': options,
                                    'answer': lines[count + 1].substring(7, 9),
                                    'explanations': explanations
                                  }
                                },
                              );
                            }
                            ind = json.encode(test).replaceAll(r'\r', '');
                            File file2 = File(
                                '${Directory.systemTemp.path}/${videoName
                                    .replaceAll(
                                    '.mp4', '')}.txt'.replaceAll(' ', ''));
                            await file2.writeAsString(ind);
                            ByteData bytes = await rootBundle.load(file2.path);
                            String fileName = '${videoName.replaceAll(
                                '.mp4', '.txt')}'
                                .replaceAll(' ', '');
                            file2 =
                                File('${Directory.systemTemp.path}/$fileName');
                            file2.writeAsBytesSync(
                                bytes.buffer.asInt8List(),
                                mode: FileMode.write);
                            StorageReference ref = FirebaseStorage.instance
                                .ref()
                                .child(
                                file2.path.replaceAll(
                                    '${Directory.systemTemp.path}', 'tests/${TeacherPageState.code}'));
                            StorageUploadTask task = ref.putFile(file2);
                            ref =
                                FirebaseStorage.instance.ref().child('$file2');
                            String _path = await(await task.onComplete).ref
                                .getDownloadURL();
                            QuerySnapshot docs = await Firestore.instance
                                .collection('classes')
                                .where('code', isEqualTo: TeacherPageState.code)
                                .getDocuments();

                            Firestore.instance.collection('classes')
                                .document(docs.documents[0].documentID)
                                .collection('tests').document()
                                .setData(
                                <String, dynamic>{
                                  'name': fileName,
                                  'downloadURL': _path,
                                  'attempts' : int.parse(controller.text),
                                });
                            prefs = await SharedPreferences.getInstance();
                            prefs.setBool(
                                TeacherPageState.code + '$fileName', false);
                            HttpClient httpClient = HttpClient();
                            if (!TeacherPageState.cool) {
                              debugPrint('1');
                              var request = await httpClient.getUrl(
                                  Uri.parse(_path));
                              debugPrint('2');
                              var response = await request.close();
                              debugPrint('3');
                              var bytes = await consolidateHttpClientResponseBytes(
                                  response);
                              debugPrint('4');
                              String dir = (await getApplicationDocumentsDirectory())
                                  .path;

                              File file = new File(
                                  '$dir/${videoName.replaceAll(
                                      '.mp4', '')}.txt');

                              await file.writeAsBytes(bytes);

                              prefs = await SharedPreferences.getInstance();

                              prefs.setString(
                                  TeacherPageState.code +
                                      'Test${videoName.replaceAll(
                                          '.mp4', '')}.txt',
                                  file.path);

                              debugPrint(file.path);
                            }
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                    ),
//                    : Row(
//                      children: <Widget>[
//                        CircularProgressIndicator(),
//                        Text('Uploading'),
//                      ],
//                    ),
//
//
//                  ),
                  ),

                ],
              ) : Center(child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Padding(padding: EdgeInsets.only( right: 10.0)),
                  Text('Uploading')
                ],
              ),
              ),


          );
        }
        else{
          return Wait(auth: auth, onSignedOut: onSignedOut);
        }
      },
    );
  }
}
class NextPage extends StatefulWidget{
  String name;
  String url;
  String task;
  BaseAuth auth;
  VoidCallback onSignedOut;
  NextPage({this.name, this.task, @required this.auth, @required this.onSignedOut,@required this.url});
  @override
  State<StatefulWidget> createState() {
    return new NextPageState(this.name, this.task, auth: auth,onSignedOut: onSignedOut, url: url);
  }

}

class NextPageState extends State<NextPage>{
  bool sneeze = false;
  BaseAuth auth;
  bool fullScreen;
  double aspectRatio;
  static VideoPlayerController control;
  VoidCallback listen ;
  bool tapped;
  String name;
  String task;
  VoidCallback onSignedOut;
  String url;
  //Fader fade = Fader(Icon(Icons.play_arrow,size: 100.0));
  NextPageState(this.name, this.task, {@required this.auth, @required this.onSignedOut, @required this.url});

  @override
  void initState() {
    super.initState();
    listen = (){
//      setState(() {
//
//      });
    };
    Firestore.instance.collection('classes').document(TeacherPageState.reference).collection('tests').where('name',isEqualTo: name.replaceAll('.mp4','.txt')).getDocuments().then((docs){
      try {
        if (docs.documents[0].exists) {
          sneeze = true;
        }
      }catch(e){
        sneeze = false;
      }
    });
    check = false;
    debugPrint('task $task');
    if(task != ''){

      File file = File(task);
      TeacherPageState._cachedFile = file;
      debugPrint('file : ${file.lengthSync()}');
      if(file.existsSync()){
        check = true;
      }
      control = VideoPlayerController.file(file)
        ..addListener(listen);
      ready = true;
      debugPrint('iin here');
      debugPrint('control' + control.toString());
      control.initialize();
//          control.seekTo(Duration(seconds: 0));
      //control.setVolume(1.0);
      debugPrint('here');

    }
//    if(task != ''){
//      check = true;
//      FlutterDownloader.open(taskId: task).then((success){
//        debugPrint(success.toString());
//      });
//
//    }

    debugPrint('check $check');
    if(check) {
      try {
        debugPrint(TeacherPageState._cachedFile.toString());
        control = VideoPlayerController.file(TeacherPageState._cachedFile)
          ..addListener(listen);
        ready = true;
        debugPrint('iin here');
        debugPrint('control' + control.toString());
        control.initialize();
//          control.seekTo(Duration(seconds: 0));
        //control.setVolume(1.0);
        debugPrint('here');
        control.play();

      }catch(e){

      }
      //..setVolume(1.0);
      //..play();

    }

    else {
      debugPrint('network');
      debugPrint('url2 $url');
      control = VideoPlayerController.network(url)..addListener(listen);//..setVolume(1.0);//..play();
      ready = true;
      debugPrint('control' + control.toString());
      control.initialize();
      control.seekTo(Duration(seconds: 0));
      //control.setVolume(1.0);
      control.play();
    }

//    else{
//      ready = true;
////      control.initialize();
////      control.setVolume(1.0);
////      control.seekTo(Duration(seconds: 0));
//      //control.play();
//
//    }
//    if (control == null) {
//      control = VideoPlayerController.network(
//          "https://firebasestorage.googleapis.com/v0/b/psrd-fa583.appspot.com/o/videos%2FTest.mp4?alt=media&token=d3ef43ea-bcbc-4baf-a074-5555d396164c")
//        ..addListener(listen)
//        ..setVolume(1.0)
//        ..initialize()
//        ..play();
//    } else {
//      if (control.value.isPlaying) {
//        control.pause();
//      } else {
//        control.initialize();
//        control.play();
//      }
//    }

  }
  @override
  void deactivate() {
    //control.setVolume(0.0);

    //control.setVolume(0.0);



    super.deactivate();
  }

//  @override
//  void dispose(){
////    control.seekTo(Duration(seconds: 0));
////    control.setVolume(0.0);
////    control.removeListener(listen);
////    control.dispose();
//    super.dispose();
//  }



  static bool check = false;
  bool ready = false;



  void createVideo()async{

    check = false;
    debugPrint('task $task');
    if(task != ''){

      File file = File(task);
      TeacherPageState._cachedFile = file;
      debugPrint('file : ${file.lengthSync()}');
      if(file.existsSync()){
        check = true;
      }
      control = VideoPlayerController.file(file)
        ..addListener(listen);
      ready = true;
      debugPrint('iin here');
      debugPrint('control' + control.toString());
      control.initialize();
//          control.seekTo(Duration(seconds: 0));
      //control.setVolume(1.0);
      debugPrint('here');

    }
//    if(task != ''){
//      check = true;
//      FlutterDownloader.open(taskId: task).then((success){
//        debugPrint(success.toString());
//      });
//
//    }

    debugPrint('check $check');
    if(check) {
      try {
//          debugPrint(AdminPageState._cachedFile.toString());
//          control = VideoPlayerController.file(AdminPageState._cachedFile)
//            ..addListener(listen);
//          ready = true;
//          debugPrint('iin here');
//          debugPrint('control' + control.toString());
//          control.initialize();
////          control.seekTo(Duration(seconds: 0));
//          //control.setVolume(1.0);
//          debugPrint('here');
//          control.play();

      }catch(e){

      }
      //..setVolume(1.0);
      //..play();

    }

    else {
//        debugPrint('network');
//        debugPrint('url2 $url');
//        control = VideoPlayerController.network(url)..addListener(listen);//..setVolume(1.0);//..play();
//        ready = true;
//        debugPrint('control' + control.toString());
//        control.initialize();
//        control.seekTo(Duration(seconds: 0));
//        //control.setVolume(1.0);
//        control.play();
    }

//    else{
//      ready = true;
////      control.initialize();
////      control.setVolume(1.0);
////      control.seekTo(Duration(seconds: 0));
//      //control.play();
//
//    }
//    if (control == null) {
//      control = VideoPlayerController.network(
//          "https://firebasestorage.googleapis.com/v0/b/psrd-fa583.appspot.com/o/videos%2FTest.mp4?alt=media&token=d3ef43ea-bcbc-4baf-a074-5555d396164c")
//        ..addListener(listen)
//        ..setVolume(1.0)
//        ..initialize()
//        ..play();
//    } else {
//      if (control.value.isPlaying) {
//        control.pause();
//      } else {
//        control.initialize();
//        control.play();
//      }
//    }
  }
  Future<bool> testThere (String name)async{
    bool isThere = false;
    QuerySnapshot docs = await Firestore.instance.collection('classes').document(TeacherPageState.reference).collection('tests').where('name',isEqualTo: name.replaceAll('.mp4','.txt')).getDocuments();
    try {
      if (docs.documents[0].exists) isThere = true;
    }catch(e){
      if(e.toString() == "RangeError (index): Invalid value: Valid value range is empty: 0") isThere = false;
    }
    return isThere;
  }
  bool hide = true;
  bool app = true;
  Widget build(BuildContext context){

    return  WillPopScope(
      onWillPop: () async => false,
      child: StreamBuilder(
        stream: Firestore.instance.collection('users').where('uid',isEqualTo: RootPageState.uid).snapshots(),
        builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData){
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.orange,
                title: Text(name.replaceAll('.mp4','')),
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
                backgroundColor: Colors.orange,
                title: Text(name.replaceAll('.mp4', '')),

                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      //control.seekTo(Duration(seconds: 0));
                      control.setVolume(0.0);
                      control.removeListener(listen);
                      Navigator.pop(context);
                    }

                ),
                actions: <Widget>[
                  FutureBuilder(
                      future: testThere(name),
                      builder: (BuildContext context, AsyncSnapshot<bool> snap) {
                        if (!snap.hasData) {
                          return CircularProgressIndicator();
                        }
                        if (snap.hasData) {
                          if (snap.data) {
                            return FlatButton(
                                child: Text('Take The Quiz'),
                                onPressed: () async {
                                  await control.pause();
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) =>
                                          Test(name: name,
                                            task: task,
                                            auth: auth,
                                            onSignedOut: onSignedOut,)));
                                }
                            );
                          }
                          else {
                            return Container();
                          }
                        }
                      }
                  ),
                ],
              ),

              body: SingleChildScrollView(
                child: Container(
//          child: AspectRatio(
//            aspectRatio: 16/9,
//            child: Container(
//                child: control != null ?
//                Stack(
//                  fit: StackFit.passthrough,
//                  children:<Widget>[
//                    GestureDetector(
//                        child: VideoPlayer(control),
//
//                        onTap: (){
//                          if(control.value.isPlaying){
//                            //fade = Fader(Icon(Icons.pause, size: 100.0));
//                            control.pause();
//
//                          }
//                          else {
//                            //fade = Fader(Icon(Icons.play_arrow, size: 100.0));
//                            control.play();
//
//                          }
//                        }
//                    ),
//                    Align(
//                      alignment: Alignment.bottomCenter,
//                      child: VideoProgressIndicator(
//                        control,
//                        allowScrubbing: true,
//                        padding: EdgeInsets.only(top: 10.0),
//                      ),
//                    ),
//                    Center(child: fade),
//                    Center(child: control.value.isBuffering ? CircularProgressIndicator() : Container()),
//                  ],
//                ): Container()
//
//
//            ) ,
//
//          ) ,

                    child: Chewie(control, aspectRatio: 16 / 9,)
                ),
              ),

//      floatingActionButton: !tapped ? FloatingActionButton(child: Icon(Icons.play_arrow),onPressed: () {
//        setState(() {
//          tapped = true;
//          createVideo();
//        });
//
//
//      },) : Container(),
              floatingActionButtonLocation: FloatingActionButtonLocation
                  .centerFloat,
            );
          }
          else{
            try{
              control.pause();
            }catch(e){

            }
            return Wait(auth: auth, onSignedOut: onSignedOut);
          }
        },
      ),
    );
  }

//  @override
//  void afterFirstLayout(BuildContext context) {
//    setState(() {
//      if(ready) {
//
//
//      }
//    });
//  }
}
class Fader extends StatefulWidget{
  BaseAuth auth;
  Fader(this.child, {this.duration = const Duration(milliseconds: 500), @required this.auth});
  final Widget child;
  final Duration duration;

  @override
  State<StatefulWidget> createState() {
    return FaderState( auth: auth);
  }

}
class FaderState extends State<Fader> with SingleTickerProviderStateMixin{
  AnimationController anim;
  BaseAuth auth;
  FaderState({@required this.auth});
  @override
  void initState() {
    super.initState();
    anim = AnimationController(duration: widget.duration, vsync: this);
    anim.addListener((){
      if(mounted){
        setState(() {

        });
      }
    });
  }

  @override
  void deactivate() {
    anim.stop();
    super.deactivate();
  }

  @override
  void didUpdateWidget(Fader old) {
    super.didUpdateWidget(old);
    if(old.child != widget.child){
      anim.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return anim.isAnimating ? Opacity(
        opacity: 1.0-anim.value,
        child: widget.child
    ) : Container();
  }

}
class Second extends StatefulWidget{
  BaseAuth auth;
  VoidCallback onSignedOut;
  Second({@required this.auth, @required this.onSignedOut});
  @override
  State<StatefulWidget> createState() {
    return new SecondState( auth: auth,onSignedOut: onSignedOut);
  }

}

class SecondState extends State<Second>{
  BaseAuth auth;
  VoidCallback onSignedOut;
  SecondState({@required this.auth, @required this.onSignedOut});
  var scaffold = GlobalKey<ScaffoldState>();
  String _path;
  static File _cachedFile;
  String curpath;
  StorageUploadTask u;
  FirebaseStorage storage;
  TextEditingController control;
  bool check = true;
  Future<Null> uploadFile (String path) async{



//    final ByteData bytes = await rootBundle.load(filepath);
//    debugPrint(bytes.lengthInBytes.toString());
//    final Directory tempDir = await getApplicationDocumentsDirectory();
//    final String fileName = '${control.text}.mp4';

//    File file = File('${Directory.systemTemp}/${control.text}.mp4');
//    file.write
//   file.writeAsBytesSync(bytes.buffer.asInt8List(),mode: FileMode.write);
//    debugPrint('file'+file.path);
    //file.writeAsBytes(bytes.buffer.asInt8List(),mode: FileMode.write);
    File file = File(path);
    StorageReference ref = FirebaseStorage.instance.ref().child(path.replaceAll('/data/user/0/com.happssolutions.prsd/cache','videos').replaceAll('.MOV','.mp4'));
    StorageUploadTask task = ref.putFile(file);
    u = task;
    ref = FirebaseStorage.instance.ref().child('$file');
    _path = await (await task.onComplete).ref.getDownloadURL();
    debugPrint(_path);
    curpath = control.text;
    QuerySnapshot docs = await Firestore.instance.collection('classes').where('code',isEqualTo: TeacherPageState.code).getDocuments();
    Firestore.instance.collection('classes').document(docs.documents[0].documentID).collection('videos').document().setData(<String,dynamic>{
      'name' : control.text+'.mp4',
      'downloadURL' : _path
    });
    setState(() {
      isLoading = false;
    });
    file.deleteSync();
  }
  @override
  void initState() {
    super.initState();
    control = new TextEditingController();
    storage = new FirebaseStorage();
  }
  bool isLoading = false;
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: Firestore.instance.collection('users').where('uid',isEqualTo: RootPageState.uid).snapshots(),
      builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.orange,
              title: Text('Upload A Video'),
              leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> TeacherPage(auth: auth, onSignedOut: onSignedOut,code: TeacherPageState.code, className: TeacherPageState.className, uid: RootPageState.uid)));
              },),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        RootPageState.auther = snapshot.data.documents[0].data['approved'] ? Auther.approved : Auther.notApproved;
        if(RootPageState.auther == Auther.approved) {
          return Scaffold(
            key: scaffold,

            appBar: AppBar(
              backgroundColor: Colors.orange,
              title: Text('Upload A Video'),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () async{
                    QuerySnapshot fire = await Firestore.instance.collection('classes').where('code',isEqualTo: TeacherPageState.code).getDocuments();
                    if (RootPageState.auth == AuthStatus.teacher)
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => TeacherPage(auth: widget.auth, onSignedOut: widget.onSignedOut, uid: snapshot.data.documents[0].data['uid'],
                            className: fire.documents[0].data['className'], code: fire.documents[0].data['code'], teacherName: fire.documents[0].data['teacherName'],
                          )));
                    setState(() {

                    });
                  }

              ),
            ),
            body: !isLoading ? SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                            controller: control,
                            decoration: InputDecoration(
                                labelText: 'Title of Video',

                            ),
                            maxLength: 15,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Title can\'t be empty';
                              }

                              if (value.contains(' ')) {
                                return 'Title can\'t contain any spaces';
                              }
                              if(value.contains('mp4') || value.contains('txt') || value.contains('MOV') || value.contains('mov')){
                                return 'This title is invalid. Please change the title';
                              }

                            },

                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 30.0),
                        child: RawMaterialButton(

                          child: Text('Upload Video'),

                          onPressed: () => doStuff(),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          padding: EdgeInsets.all(15.0),
                          fillColor: Colors.orange,
                          elevation: 0.0,
                        ),
                      ),
                    ],
                  ),
                )
            ) : Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text('   Uploading'),
                ],
              ),
            ),
          );
        }
        else{
          return Wait(auth: auth, onSignedOut: onSignedOut);
        }
      },
    );

  }

  void doStuff()async{
    try {
      final form = formKey.currentState;
      form.save();
      if(form.validate()) {
        setState(() {
          isLoading = true;
        });
        await uploadFile(
            await FilePicker.getFilePath(
                type: FileType.CUSTOM, fileExtension: 'mp4'));
        //debugPrint('Path:'+(await ImagePicker.pickVideo(source: ImageSource.gallery)).path);
        setState(() {
          isLoading = false;
          control.text = '';

          _showSnackBar();
        });
      }
    }
    catch(e){
      debugPrint(e.toString());
    }
  }
  void _showSnackBar(){

    final snackBar = SnackBar(
        content: Text('Video Uploaded')
    );
    scaffold.currentState.showSnackBar(snackBar);
    debugPrint('Show snack bar');
  }

}
class Test extends StatefulWidget {
  final String name;
  String task;
  BaseAuth auth;
  VoidCallback onSignedOut;
  Test({this.name,this.task, @required this.auth, @required this.onSignedOut});
  State createState () => new TestState( auth: auth,onSignedOut: onSignedOut);
}

class TestState extends State<Test>{
  BaseAuth auth;
  VoidCallback onSignedOut;
  TestState({@required this.auth, @required this.onSignedOut});
  String name = "";
  SharedPreferences prefs;
  String downloadUrl = "";
  List quest = [];
  List options = [];
  String answer = "";
  int score = 0;
  List explanations = [];
  String question = "";
  int length = 0;
  int index = 0;
  bool loaded = false;
  Future<List> getTest()async{
    name = widget.name;
    prefs = await SharedPreferences.getInstance();
    String filepath = prefs.getString(TeacherPageState.code+'Test'+name.replaceAll('.mp4','.txt')) ?? "";
    if(filepath != ""){
      File file = File(filepath);
      return json.decode(file.readAsStringSync());
    }
    if(filepath == "") {
      debugPrint('refies ${TeacherPageState.reference}');
      QuerySnapshot docs = await Firestore.instance.collection('classes').document(TeacherPageState.reference).collection('tests').where(
          'name', isEqualTo: name.replaceAll('.mp4', '.txt')).getDocuments();

      if (docs.documents[0].exists) {
        downloadUrl = docs.documents[0].data['downloadURL'];
        debugPrint('downloadUrl $downloadUrl');
        http.Response response = await http.get(downloadUrl);
        return json.decode(response.body);
      }
    }



    return [];
  }

  @override
  void initState() {
    super.initState();

    count();

  }

  void count(){
    getTest().then((list){
      quest = list;
      length = quest.length;
      trynum = 0;
      //debugPrint('quest'+quest.toString());
      displayQuestion(quest[index],index);

      index++;
      setState(() {
        loaded = true;
      });
    });
  }
  void displayQuestion(Map problem, int index){
    Map pro = problem['question ${index+1}'];
    setState(() {
      debugPrint('pro $pro');
      question = pro['question'];
      options.forEach((s){
        toRemove.add(s);
      });
      options.removeWhere((e)=>toRemove.contains(e));
      toRemove = [];
      explanations.forEach((s){
        toRemove.add(s);
      });
      explanations.removeWhere((e)=>toRemove.contains(e));
      toRemove = [];
      options = pro['options'];
      explanations = pro['explanations'];

      answer = pro['answer'];
      for(int i = 0; i < options.length; i++){
        colorlist.add(false);
      }
    });
  }
  List<Widget> op = [];
  List toRemove = [];
  bool color = false;
  bool pushed = false;
  int value = -1;
  String choice = "";
  int activated = 0;
  GlobalKey<ScaffoldState> scaffold = GlobalKey<ScaffoldState>();
  String explanation = "";
  bool done = false;
  List<bool> colorlist = [];
  int trynum = 0;
  bool next = false;
  void optionButton(int i){
    setState(() {
      pushed = true;
      value = i;
      debugPrint(i.toString());
      for(int j = 0; j < colorlist.length; j++ ){
        colorlist[j] = false;
      }
      colorlist[i] = true;
      debugPrint('color $colorlist');
      choice = options[i]['option ${i+1}'][0];
      debugPrint('choice $choice');
      debugPrint('answer $answer');
    });
  }
  List<Widget> loopOptions() {
    if(!done){
      debugPrint('colorlist $colorlist');
      op.forEach((w) {
        toRemove.add(w);
      });

      op.removeWhere((e) => toRemove.contains(e));
      toRemove = [];
      op.add(Padding(padding: EdgeInsets.only(top: 25.0)));

      op.add(Text('''$question''', textAlign: TextAlign.center,
          style: TextStyle(fontFamily: "Serif", fontSize: 16.0)),);


      for (int i = 0; i < options.length; i++) {
        color = false;
//      op.add(InkButton(options[i]['option ${i+1}'].toString(),onTap: (){
//        color = true;
//        pushed = true;
//        value = i;
//        choice = options[i][0];
//        debugPrint(options[i]['option ${i+1}'].toString()+color.toString());
//      },colorVal: color,));
        op.add(Container(

          child: FlatButton(
            color: colorlist[i] ? Colors.blueAccent : Colors.grey.shade100,
            child: Text(options[i]['option ${i + 1}'].toString(),
                textAlign: TextAlign.start,
                style: TextStyle(fontFamily: "Serif", fontSize: 14.0,)),
            onPressed: () => optionButton(i),

          ),

        ));
        debugPrint(colorlist.toString());
      }
      debugPrint(colorlist.toString());
      debugPrint(pushed.toString());
      if (activated != 2) {
        op.add(RawMaterialButton(
            fillColor: Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            elevation: 0.0,
            padding: EdgeInsets.all(10.0),
            child: Text('Submit'),
            onPressed: () {
              if (!pushed) {
                showDialog(context: context, builder: (context) =>
                    AlertDialog(title: Text('You must select one of the options'),
                        content: Row(mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FlatButton(child: Text('OK'),
                                onPressed: () => Navigator.pop(context))
                          ],
                        )));
                return null;
              }


              explanation =
                  explanations[value]['explanation ${value + 1}']
                      .toString()
                      .substring(3);
              if (choice.replaceAll(' ', '') == answer.replaceAll(' ', '')) {
                activated = 2;
                if (index != length) next = true;
                trynum++;
                if (trynum == 1) score++;
                scaffold.currentState.showSnackBar(
                    SnackBar(
                      content: Text('You are correct'),
                      duration: Duration(milliseconds: 1500),
                    )
                );
              }
              else {
                trynum++;
                activated = 1;
                scaffold.currentState.showSnackBar(
                    SnackBar(
                      content: Text(
                          'You are incorrect choose a different answer and submit again'),
                      duration: Duration(milliseconds: 1500),
                    )
                );
                debugPrint('choice $choice answer $answer');
              }
              setState(() {

              });
            }
        ));
      }
      if (activated == 2)
        op.add(Container(
          color: Colors.yellow,
          child: Text('''Answer $answer''', textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "Serif", fontSize: 16.0,color: Colors.blue)),
        ),);
      if (activated == 1 || activated == 2)
        op.add(Text('''$explanation''', textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Serif", fontSize: 16.0)),);

      if (next) {
        op.add(
            RawMaterialButton(
              fillColor: Colors.orange,
              padding: EdgeInsets.all(10.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              elevation: 0.0,
              child: Text('Next Question', textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: "Serif", fontSize: 16.0)),
              onPressed: () {
                activated = 0;
                next = false;
                colorlist = [];
                count();
              },
            )


        );
      }
      if (length == index && activated == 2) {
        op.add(RawMaterialButton(
          fillColor: Colors.orange,
          elevation: 0.0,
          padding: EdgeInsets.all(10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: Text('Finish', textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "Serif", fontSize: 16.0)),
          onPressed: () {
            done = true;
            setState(() {

            });
          },
        ));
      }
    }
    else{
      op.forEach((w) {
        toRemove.add(w);
      });

      op.removeWhere((e) => toRemove.contains(e));
      toRemove = [];
      op.add(Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height/2.5)));
      op.add(
          Center(
            child: Text(
              'You\'re final score is ${(score/length*100).ceil()}%',textAlign: TextAlign.center, style: TextStyle(fontFamily: "Serif",fontSize: 25.0),
            ),
          )
      );
    }
    b = op;

//    try {
//      op.forEach((f) {
//        op.remove(f);
//      });
//    }catch(e){
//
//    }
    debugPrint('b $b');
    return b;
  }
  List b = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('users').where('uid',isEqualTo: RootPageState.uid).snapshots(),
      builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.orange,
              title: Text(name.replaceAll('.mp4','')+' Quiz'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        RootPageState.auther = snapshot.data.documents[0].data['approved'] ? Auther.approved : Auther.notApproved;
        if(RootPageState.auther == Auther.approved) {
          return Scaffold(
            key: scaffold,
            appBar: AppBar(
              backgroundColor: Colors.orange,
              title: Text(name.replaceAll('.mp4', '') + ' Quiz'),

            ),

            body: loaded ? SingleChildScrollView(
              child: Center(

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,

                  children: loopOptions(),
                ),
              ),
            ) : Center(child: CircularProgressIndicator()),
          );
        }
        else{
          return Wait(auth: auth, onSignedOut: onSignedOut);
        }
      },
    );
  }

}
class CodePage extends StatefulWidget {
  BaseAuth auth;
  VoidCallback onSignedOut;
  String reference;
  CodePage({this.auth, this.onSignedOut,this.reference});
  @override
  CodePageState createState() => CodePageState(auth: auth, onSignedOut: onSignedOut,reference: reference);
}

class CodePageState extends State<CodePage> {
  BaseAuth auth;
  VoidCallback onSignedOut;
  String reference;
  CodePageState({this.auth, this.onSignedOut,this.reference});
  FirebaseMessaging messaging = new FirebaseMessaging();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance.collection('users').where('uid', isEqualTo: RootPageState.uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.orange,
              title: Text('Code Page'),
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
              backgroundColor: Colors.orange,
              title: Text('Code Page'),
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

                      }
                  ),

                  ListTile(
                      title: Text('View Students'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context,MaterialPageRoute(builder: (context)=>StudentView(auth,onSignedOut,reference: reference,)));
                      }
                  ),
                  ListTile(
                      title: Text('View Code'),
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
            body: Center(
              child: Text('''${TeacherPageState.code}''', textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: "Serif", fontSize: 25.0)),
            ),
          );
        }
        else{
          return Wait(auth: auth, onSignedOut: onSignedOut);
        }
      }
    );
  }
}

//class InkButton extends StatefulWidget {
//  final String text;
//  final onTap;
//  final bool colorVal;
//  InkButton(this.text,{this.onTap,@required this.colorVal,});
//  @override
//  InkButtonState createState() => InkButtonState();
//}
//
//class InkButtonState extends State<InkButton> {
//
//  @override
//  Widget build(BuildContext context) {
//
//    return Container(
//      color: widget.colorVal ? Colors.blueAccent : Colors.white,
//      child: FlatButton(
//        child: Text('''${widget.text}''', textAlign: TextAlign.start, style: TextStyle(fontFamily: "Serif", fontSize: 14.0,)),
//        onPressed: ()=>widget.onTap,
//      ),
//    );
//  }
//}
