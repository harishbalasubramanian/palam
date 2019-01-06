import 'package:flutter/material.dart';
import 'package:prsd/authentication/auth.dart';
import 'package:prsd/authentication/root_page.dart';
void main(){

  runApp(
//    new MaterialApp(
//      home: SecondHome()
//    )
  Home()
  );
}
class SecondHome extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text('Hello')
      ),
    );
  }

}
class Home extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: RootPage(auth: new Auth()),
      theme: ThemeData(
        primarySwatch:  Colors.orange
      ),
      title: "Palam",
      debugShowCheckedModeBanner: false,
    );
  }
}