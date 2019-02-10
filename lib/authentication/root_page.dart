import 'package:flutter/material.dart';
import 'Login.dart';
import 'auth.dart';
import 'package:prsd/studentHub.dart';
import 'package:prsd/teacher_page.dart';
import 'package:prsd/Wait.dart';
import 'package:prsd/admin_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:prsd/teacherHub.dart';
class RootPage extends StatefulWidget{
  RootPage({@required this.auth});
  final BaseAuth auth;
  @override
  State<StatefulWidget> createState() {
    return new RootPageState();
  }

}

enum AuthStat{
  notSignedIn,
  signedIn
}
enum Auther{
  notApproved,approved
}
class RootPageState extends State<RootPage>{
  static String uuserId = '';
  static AuthStat authStatus = AuthStat.notSignedIn;
  LoginPageState l;
  static String uid;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  String name;
  @override
  void initState() {

    widget.auth.currentUser().then((userId){
      try {
        setState(() {
          authStatus =
          userId == null ? AuthStat.notSignedIn : AuthStat.signedIn;
          uid = userId;
          uuserId = userId;
          debugPrint('auth: $auth');

        });
      }catch(e){
        if(e.toString() != "NoSuchMethodError: The getter 'uid' was called on null."){
          debugPrint('e $e');
        }
      }

    });
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher.png');
    var ios = new IOSInitializationSettings();
    var platform = new InitializationSettings(android,ios);
    flutterLocalNotificationsPlugin.initialize(platform);
    Firestore.instance.collection('users').where('uid',isEqualTo: uid).getDocuments().then((docs) {
      messaging.configure(
        onLaunch: (Map<String, dynamic> map) {
          debugPrint('onLaunch called');
        },
        onMessage: (Map<String, dynamic> map) async {
          //debugPrint('onMessage called ${map['title']}');
          flutterLocalNotificationsPlugin =
          new FlutterLocalNotificationsPlugin();
          debugPrint('1');
          var android = new AndroidNotificationDetails(
              'channel_id', 'CHANNEL NAME', 'channel Description',
              icon: '@mipmap/ic_launcher.png');
          debugPrint('2');
          var ios = new IOSNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true,);
          debugPrint('3');
          var platform = new NotificationDetails(android, ios);
          debugPrint('4');
          String title = map['title'];
          String body = map['body'];
//          await flutterLocalNotificationsPlugin.show(
//              0, title, body, platform);
          debugPrint('finished');
        },
        onResume: (Map<String, dynamic> map) {
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
      messaging.onIosSettingsRegistered.listen((
          IosNotificationSettings settings) {
        debugPrint('IOS Settings Registered');
      });
      messaging.getToken().then((token) {
        debugPrint(token);
        docs.documents[0].reference.updateData({
          'fcmtoken': token
        });
      });
    });
    l = new LoginPageState();

    super.initState();
  }
  Future onSelectNotification(String payload){
    debugPrint('payload $payload');
  }
  void _signedIn(){
    setState(() {
      authStatus = AuthStat.signedIn;
    });
  }
  void _signedOut(){
    setState(() {
      authStatus = AuthStat.notSignedIn;
      LoginPageState.isLoading = false;
      Auth.done = false;
      Auth.remail = '';
      Auth.rname = '';
      Auth.rstatus = null;
    });

  }
  void tryAgain(){
    setState(() {
      auth = LoginPageState.auth;
      auth = Auth.bauth;

    });
  }
  FirebaseMessaging messaging = new FirebaseMessaging();
  static void check()async{
    debugPrint('userId $uuserId');
    QuerySnapshot docs = await Firestore.instance.collection('users').where('uid',isEqualTo: uid).getDocuments();
    if(docs.documents[0].exists){
      if(!docs.documents[0].data['approved']){
        auther = Auther.notApproved;
      }
      else if (docs.documents[0].data['approved']){
        debugPrint('docs ${docs.documents[0].data['approved']}');
        auther = Auther.approved;
      }
      debugPrint('auther '+auther.toString());
    }

  }
  static AuthStatus auth;
  static Auther auther;
  @override
  Widget build(BuildContext context) {

    if(authStatus == AuthStat.signedIn){
      tryAgain();

      debugPrint('now $auth');
      if(auth == AuthStatus.admin){
        auther = Auther.approved;
      }
      check();
      debugPrint('autherr $auther');
      return StreamBuilder(
          stream: Firestore.instance.collection('users').where('uid',isEqualTo: uuserId).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if(!snapshot.hasData){
              return Scaffold(
                  appBar: AppBar(
                    title: Text('Getting Data'),
                    automaticallyImplyLeading: false,
                  ),
                  body: Center(child: CircularProgressIndicator())
              );
            }
            try {
              if(snapshot.data.documents[0].exists) {
                auther = snapshot.data.documents[0].data['approved'] ? Auther.approved : Auther.notApproved;
                if(snapshot.data.documents[0].data['status'] == 'student')
                  auth = AuthStatus.student;
                else if (snapshot.data.documents[0].data['status'] == 'teacher')
                  auth = AuthStatus.teacher;
                else if (snapshot.data.documents[0].data['status'] == 'admin')
                  auth = AuthStatus.admin;
                debugPrint('autther ${snapshot.data.documents[0].data}');


                  if (auth == AuthStatus.student) {
                    Firestore.instance.collection('users').where('uid', isEqualTo: uid).getDocuments().then((docs){
                      if(docs.documents[0].exists){
                        messaging.configure(
                          onLaunch: (Map<String, dynamic> map){
                            debugPrint('onLaunch called');
                          },
                          onMessage: (Map<String, dynamic> map){
                            showNotification(map);
                            debugPrint('onMessage called ${map['title'].toString()}');
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
                        messaging.getToken().then((token){
                          debugPrint(token);
                          docs.documents[0].reference.updateData({
                            'fcmtoken' : token
                          });
                        });
                      }
                    });
                    try{
                      messaging.unsubscribeFromTopic('studentNotifier');
                      messaging.unsubscribeFromTopic('teacherNotifier');
                    }catch(e){

                    }
                    return new StudentHub(
                      auth: widget.auth,
                      onSignedOut: _signedOut,

                    );
                  }
                  if(auther == Auther.approved) {
                    if (auth == AuthStatus.teacher) {
                      debugPrint('sababanana');
                      Firestore.instance.collection('users').where('uid', isEqualTo: uid).getDocuments().then((docs) {
                        if (docs.documents[0].exists) {
                          messaging.configure(
                            onLaunch: (Map<String, dynamic> map) {
                              debugPrint('onLaunch called');
                            },
                            onMessage: (Map<String, dynamic> map) {
                              showNotification(map);
                              debugPrint('onMessage called');
                            },
                            onResume: (Map<String, dynamic> map) {
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
                          messaging.onIosSettingsRegistered.listen((
                              IosNotificationSettings settings) {
                            debugPrint('IOS Settings Registered');
                          });
                          messaging.getToken().then((token) {
                            debugPrint(token);
                            docs.documents[0].reference.updateData({
                              'fcmtoken': token
                            });
                          });

                          messaging.subscribeToTopic('studentNotifier');
                          try {
                            messaging.unsubscribeFromTopic('teacherNotifier');
                          } catch (e) {

                          }
                        }
                      });
                      return TeacherHub(
                        auth: widget.auth,
                        onSignedOut: _signedOut,
                      );
//                      return new TeacherPage(
//                        auth: widget.auth,
//                        onSignedOut: _signedOut,
//                      );
                    }
                  }
                  if (auth == AuthStatus.admin) {

                    Firestore.instance.collection('users').where('uid', isEqualTo: uid).getDocuments().then((docs){
                      if(docs.documents[0].exists){
                        messaging.configure(
                          onLaunch: (Map<String, dynamic> map){
                            debugPrint('onLaunch called');
                          },
                          onMessage: (Map<String, dynamic> map)async{
                            //debugPrint('onMessage called ${map['title']}');
                            flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
                            debugPrint('1');
                            var android = new AndroidNotificationDetails('channel_id', 'CHANNEL NAME', 'channel Description',icon: '@mipmap/ic_launcher.png');
                            debugPrint('2');
                            var ios = new IOSNotificationDetails(presentAlert: true,presentBadge: true,presentSound: true,);
                            debugPrint('3');
                            var platform = new NotificationDetails(android, ios);
                            debugPrint('4');
                            await flutterLocalNotificationsPlugin.show(0, map['title'].toString(), map['body'].toString(), platform);
                            debugPrint('finished');
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
                        messaging.getToken().then((token){
                          debugPrint(token);
                          docs.documents[0].reference.updateData({
                            'fcmtoken' : token
                          });
                        });

                        messaging.subscribeToTopic('studentNotifier');
                        messaging.subscribeToTopic('teacherNotifier');
                      }
                    });
                    return new AdminPage(
                      auth: widget.auth,
                      onSignedOut: _signedOut,
                      uid: uid,
                    );
                  }


                  return new Wait(auth: widget.auth, onSignedOut: _signedOut);

              }
            } catch (e) {
              debugPrint(e.toString());
            }
          }
      );
    }
    return new LoginPage(auth: widget.auth,onSignedIn: _signedIn,);

  }
  showNotification(Map<String, dynamic> map)async{
    var android = new AndroidNotificationDetails('channel_id', 'CHANNEL NAME', 'channel Description');
    var ios = new IOSNotificationDetails(presentAlert: true,presentBadge: true,presentSound: true,);
    var platform = new NotificationDetails(android, ios);
    await flutterLocalNotificationsPlugin.show(0, map['title'], map['body'], platform);
    debugPrint('finished');
  }
}