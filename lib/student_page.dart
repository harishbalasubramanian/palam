import 'package:flutter/material.dart';
import 'package:prsd/authentication/auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'authentication/Login.dart';
import 'authentication/root_page.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
//import 'Wait.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'studentHub.dart';
import 'StudentWait.dart';
class StudentPage extends StatefulWidget{
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  String uid;
  String className;
  String code;
  final String teacherName;
  StudentPage({this.auth,this.onSignedOut,this.uid,this.className,this.code,this.teacherName});
  @override
  State<StatefulWidget> createState() {
    return new StudentPageState(auth: auth, onSignedOut: onSignedOut,uid: uid);
  }


}

class StudentPageState extends State<StudentPage>{
  String _path;
  static File _cachedFile;
  static List<bool> sneck = [];
  String curpath;
  StorageUploadTask u;
  SharedPreferences prefs;
  static String url = '';
  GlobalKey<ScaffoldState> scaffold = new GlobalKey<ScaffoldState>();
  //static FlutterDocumentPickerParams params;

  String uid;
  StudentPageState({this.auth,this.onSignedOut,this.uid});
  BaseAuth auth;
  static String code = '';
  static bool signedIn;
  bool loading = false;
  final VoidCallback onSignedOut;
  static String teacherName = '';
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


  @override
  void initState(){
    super.initState();
//    params = FlutterDocumentPickerParams(
//      allowedFileExtensions: ['txt'],
//    );

    teacherName = widget.teacherName;
    signedIn = true;
    code = widget.code;
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
  static String reference = '';
  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
      stream: Firestore.instance.collection('classes').where('code',isEqualTo: widget.code).snapshots(),
      builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snupshot){
        if(!snupshot.hasData){
          return Scaffold(
              appBar: AppBar(
                title: Text('Getting Data'),
                automaticallyImplyLeading: false,
              ),
              body: Center(child: CircularProgressIndicator())
          );
        }
        reference = snupshot.data.documents[0].documentID;


        return StreamBuilder(
          stream: Firestore.instance.collection('classes').document(reference).collection('users').where('uid',isEqualTo: RootPageState.uid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapp){
            if(!snapp.hasData){
              return Scaffold(
                  appBar: AppBar(
                    title: Text('Getting Data'),
                    automaticallyImplyLeading: false,
                  ),
                  body: Center(child: CircularProgressIndicator())
              );
            }
            if(snapp.data.documents[0].data['approved']) {
              reference = snupshot.data.documents[0].documentID;
              return Scaffold(
                key: scaffold,
                appBar: AppBar(
                  title: Text(widget.className),
                  actions: <Widget>[
//          IconButton(icon: Icon(Icons.accessibility),onPressed: () {
//            setState(() {
//              signedIn = false;
//            });
//            _signOut();
//          },),
//          IconButton(icon: Icon(Icons.add),onPressed: ()async{
//            Navigator.push(context, MaterialPageRoute(builder: (context)=>new Second(auth: auth, onSignedOut: onSignedOut,)));
//            //uploadFile(await ImagePicker.pickVideo(source: ImageSource.gallery));
//          }

//          )

                  ],
                ),
                drawer: Drawer(
                  child: ListView(
                    children: <Widget>[
                      DrawerHeader(
                        child: Image.asset('images/PalamLogo.png'),
                      ),
                      ListTile(
                        title: Text('Back to Hub'),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => StudentHub()));
                        },
                      ),
                      ListTile(
                          title: Text('Home'),
                          onTap: () {
                            Navigator.pop(context);
                          }
                      ),
                      ListTile(
                          title: Text('Sign Out'),
                          onTap: () {
                            setState(() {
                              signedIn = false;
                            });
                            signOut();
                          }
                      ),
                    ],
                  ),
                ),
                body: !loading && signedIn ? StreamBuilder(
                    stream: Firestore.instance.collection('classes').document(
                        reference).collection('videos').snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snap) {
                      if (!snap.hasData)
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
                      debugPrint('reference $reference');

                      if (messageCount == 0)
                        return Center(child: Text('No videos were uploaded'));
                      return ListView.builder(
                          itemCount: messageCount,
                          itemBuilder: (BuildContext context, int index) {
                            DocumentSnapshot snapshot = snap.data
                                .documents[index];
                            sneck.removeRange(0, sneck.length);
                            for (int i = 0; i < messageCount; i++) {
                              sneck.add(false);
                              //debugPrint('i $i');
                            }

                            while (index + 1 > calor.length) {
                              calor.add(Colors.orange);
                            }
//                  colorr(snapshot['name'].replaceAll('.mp4','.txt'),index);
                            SharedPreferences.getInstance().then((pref) {
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
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<bool>> snapper) {
                                  //debugPrint(snapper.data.toString() + 'snam');
                                  if (!snapper.hasData) {
                                    return Center(
                                        child: CircularProgressIndicator()
                                    );
                                  }
                                  if (snapper.hasData) {
                                    cool = snapper.data[1];
                                    return ListTile(
                                        title: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Padding(padding: EdgeInsets.only(
                                                left: 16.0)),
                                            Text(snapshot['name'].replaceAll('.mp4',''), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 15.0),),

                                          ],
                                        ),
                                        //
                                           trailing: snapper.data[1] ? Container(
                                             width: 40.0,
                                             decoration: BoxDecoration(
                                               shape: BoxShape.circle,
                                               color: Colors.green,
                                             ),
                                             child: IconButton(
                                                  icon: Icon(Icons.file_download, color: Colors.white),
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
                                                    setState(() {
                                                      loading = false;
                                                      scaffold.currentState
                                                          .showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                                snapshot['name'] +
                                                                    ' has downloaded'),
                                                          ));
                                                    });
                                                    try {
                                                      QuerySnapshot snapper = await Firestore
                                                          .instance.collection(
                                                          'classes').document(
                                                          reference)
                                                          .collection('tests')
                                                          .where('name',
                                                          isEqualTo: snapshot['name']
                                                              .replaceAll(
                                                              '.mp4', '.txt'))
                                                          .getDocuments();
                                                      if (snapper.documents[0]
                                                          .exists) {
                                                        await downloadFile(
                                                            snapper
                                                                .documents[0]['downloadURL'],
                                                            'Test' +
                                                                snapper
                                                                    .documents[0]['name']);
                                                      }
                                                      setState(() {
                                                        loading = false;
                                                        scaffold.currentState
                                                            .showSnackBar(
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
                                              ),
                                           ) :
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
                                                        children: <Widget>[
                                                          FlatButton(
                                                              child: Text('Yes'),
                                                              onPressed: () async {
                                                                prefs =
                                                                await SharedPreferences
                                                                    .getInstance();
                                                                String naame = prefs
                                                                    .getString(
                                                                    widget
                                                                        .code +
                                                                        snapshot['name']) ??
                                                                    null;
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
                                                                        snapshot['name']) ??
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
                                                                          snapshot['name']);
                                                                  prefs.remove(
                                                                      widget
                                                                          .code +
                                                                          'Test' +
                                                                          snapshot['name']
                                                                              .replaceAll(
                                                                              '.mp4',
                                                                              '.txt'));
                                                                } catch (e) {

                                                                }
                                                                setState(() {
                                                                  cool = true;
                                                                });
                                                                Navigator.pop(
                                                                    context);
                                                              }
                                                          ),
                                                          FlatButton(
                                                              child: Text('No'),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              }
                                                          ),

                                                        ],
                                                      ),
                                                    );
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return alert;
                                                        });
                                                  }
                                              ),
                                            ),


                                        enabled: true,
                                        selected: true,


                                        onTap: () async {
                                          url = snapshot['downloadURL'];
                                          debugPrint('url1 $url');
                                          prefs =
                                          await SharedPreferences.getInstance();
                                          String task = prefs.getString(
                                              widget.code +
                                                  snapshot['name']) ??
                                              '';
                                          debugPrint('task $task');
                                          Navigator.push(
                                              context, MaterialPageRoute(
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


              );
            }
            else{
              return StudentWait(auth: widget.auth, onSignedOut: widget.onSignedOut);
            }
          },
        );
      },
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
  static VoidCallback listen ;
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
    Firestore.instance.collection('classes').document(StudentPageState.reference).collection('tests').where('name',isEqualTo: name.replaceAll('.mp4','.txt')).getDocuments().then((docs){
      try {
        if (docs.documents[0].exists) {
          sneeze = true;
        }
      }catch(e){
        sneeze = false;
      }
    });
//    Firestore.instance.collection('tests').where('name',isEqualTo: name.replaceAll('.mp4','.txt')).getDocuments().then((docs){
//      try {
//        if (docs.documents[0].exists) {
//          sneeze = true;
//        }
//      }catch(e){
//        sneeze = false;
//      }
//    });
    check = false;
    debugPrint('task $task');
    if(task != ''){

      File file = File(task);
      StudentPageState._cachedFile = file;
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
        debugPrint(StudentPageState._cachedFile.toString());
        control = VideoPlayerController.file(StudentPageState._cachedFile)
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
      StudentPageState._cachedFile = file;
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
    QuerySnapshot docs = await Firestore.instance.collection('classes').document(StudentPageState.reference).collection('tests').where('name',isEqualTo: name.replaceAll('.mp4','.txt')).getDocuments();
    try {
      if (docs.documents[0].exists) isThere = true;
    }catch(e){
      if(e.toString() == "RangeError (index): Invalid value: Valid value range is empty: 0") isThere = false;
    }
    return isThere;
  }
  bool hide = true;
  Widget build(BuildContext context){

    return WillPopScope(
      onWillPop: () async => false,
      child: StreamBuilder(
        stream: Firestore.instance.collection('classes').document(StudentPageState.reference).collection('users').where('uid',isEqualTo: RootPageState.uid).snapshots(),
        builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(!snapshot.hasData){
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.orange,
                title: Text(name.replaceAll('.mp4', '')),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          debugPrint('reference ${StudentPageState.reference}');
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
            }
            catch(e){

            }
            return StudentWait(auth: auth, onSignedOut: onSignedOut,);
          }
        }
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
    String filepath = prefs.getString(StudentPageState.code+'Test'+name.replaceAll('.mp4','.txt')) ?? "";
    if(filepath != ""){
      File file = File(filepath);
      return json.decode(file.readAsStringSync());
    }
    if(filepath == "") {
      QuerySnapshot docs = await Firestore.instance.collection('classes').document(StudentPageState.reference).collection('tests').where(
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
      stream: Firestore.instance.collection('classes').document(StudentPageState.reference).collection('users').where('uid',isEqualTo: RootPageState.uid).snapshots(),
      builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(!snapshot.hasData){
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.orange,
              title: Text(name.replaceAll('.mp4', '').replaceAll('.txt', '') + " Quiz"),
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
              title: Text(
                  name.replaceAll('.mp4', '').replaceAll('.txt', '') + " Quiz"),

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
          return StudentWait(auth: auth, onSignedOut: onSignedOut,);
        }
      },
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
