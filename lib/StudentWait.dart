import 'package:flutter/material.dart';
import 'package:prsd/authentication/auth.dart';
import 'authentication/root_page.dart';
import 'authentication/Login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'studentHub.dart';
class StudentWait extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  StudentWait({this.auth,this.onSignedOut});
  @override
  StudentWaitState createState() => StudentWaitState(auth: auth, onSignedOut: onSignedOut);
}

class StudentWaitState extends State<StudentWait> {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  bool yay = true;
  StudentWaitState({this.auth, this.onSignedOut});
  FirebaseMessaging messaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  @override
  void initState(){
    super.initState();
    messaging.configure(
      onLaunch: (Map<String, dynamic> map){
        debugPrint('onLaunch called');
      },
      onMessage: (Map<String, dynamic> map)async{
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
        await flutterLocalNotificationsPlugin.show(
            0, title, body, platform);
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
  }
  void _signOut()async{
    try {
      await Auth.signOut();
      debugPrint('here');
//      setState(() {
//        RootPageState.authStatus = AuthStat.notSignedIn;
//        LoginPageState.isLoading = false;
//        Auth.done = false;
//        yay = false;
//        Auth.remail = '';
//        Auth.rname = '';
//        Auth.rstatus = null;
//      });
      RootPageState.authStatus = AuthStat.notSignedIn;
      LoginPageState.isLoading = false;
      Auth.done = false;
      yay = false;
      Auth.remail = '';
      Auth.rname = '';
      Auth.rstatus = null;
    }catch(e){
      debugPrint('e $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    debugPrint('yayay');
    return yay ? Scaffold(
      appBar: AppBar(
        title: Text('You have not been approved'),
        backgroundColor: Colors.orange,


      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
                child: Image.asset('images/PalamLogo.png')
            ),
            ListTile(
              title: Text('Back to Hub'),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context)=> StudentHub(auth: widget.auth, onSignedOut: widget.onSignedOut)));
              }
            ),
            ListTile(
                title: Text('Home'),
                onTap: (){
                  Navigator.pop(context);
                }
            ),
            ListTile(
                title: Text('Sign Out'),
                onTap: () {
                  _signOut();
                  Navigator.pop(context);
                }
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          '''You have not been approved so please come back at another time or contact your teacher''',textAlign: TextAlign.center,
          style: TextStyle(fontFamily: "Serif",fontSize: 16.0),
        ),
      ),
    ) : RootPage(auth: new Auth());
  }
}
