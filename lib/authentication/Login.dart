import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
class LoginPage extends StatefulWidget{
  LoginPage({this.auth,this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  @override
  State<StatefulWidget> createState() {
    return new LoginPageState();
  }

}

enum FormType{
  login,
  register
}

enum AuthStatus{
  student,
  teacher,
  admin
}


class LoginPageState extends State<LoginPage>{
  final formKey = new GlobalKey<FormState>();
  bool a;
  FormType _form = FormType.login;
  static AuthStatus auth = AuthStatus.student;
  String email = '';
  String password = '';
  String name = '';
  bool validateAndSave(){
    final form = formKey.currentState;
    form.save();
    if(form.validate()){
      //debugPrint('$email $password');
      return true;
    }
    else{
      debugPrint('wa');
      return false;
    }
  }
  static bool done;
  void validateAndSubmit()async{
    debugPrint('started');
    debugPrint(auth.toString());
    auth = auth ?? AuthStatus.student;
    if(validateAndSave()){
      try {
        if (_form == FormType.login) {

          String userId = await widget.auth.signInWithEmailAndPassword(email, password,auth);
          debugPrint('User $userId');

        }
        else{
          setState(() {
            isLoading = true;
          });
          String userId = await widget.auth.createUserWithEmailAndPassword(email,password,auth,name);

          debugPrint('Reg $userId');
        }
        widget.onSignedIn();
      }
      catch(e){
        debugPrint('Error $e');
        setState(() {
          isLoading = false;
        });
      }

    }
    debugPrint('started2');
    debugPrint(auth.toString());
    auth = auth ?? AuthStatus.student;
    if(validateAndSave()){
      try {
        if (_form == FormType.login) {

          String userId = await widget.auth.signInWithEmailAndPassword(email, password,auth);
          debugPrint('User $userId');

        }
        else{
          setState(() {
            isLoading = true;
          });
          String userId = await widget.auth.createUserWithEmailAndPassword(email,password,auth,name);

          debugPrint('Reg $userId');
        }
        widget.onSignedIn();
      }
      catch(e){
        debugPrint('Error $e');
        setState(() {
          isLoading = false;
        });
      }

    }
  }

  void reg(){
    formKey.currentState.reset();
    setState(() {
      _form = FormType.register;
    });

  }

  void log(){
    formKey.currentState.reset();
    setState(() {
      _form = FormType.login;
    });
  }
  static bool isLoading = false;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Name"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Stack(
            children: <Widget>[
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: buildInputs(),
                ),
              ),
              isLoading ?  Align(
                  child: Container(
                    color: Colors.grey[200],
                    width:70.0,
                    height: 70.0,
                    child: new Padding(padding: EdgeInsets.all(5.0),child: Center(child: CircularProgressIndicator())),
                  ),
                alignment: Alignment.center,
              ) : Container(),
            ],
          ),
        ),
      ),
    );
  }
  int val = 0;
  List<Widget> buildInputs(){

    if(_form == FormType.login){

      return [
        TextFormField(
        decoration: InputDecoration(labelText:'Email'),
        validator: (value)=>value.isEmpty ? 'Email can\'t be empty':null,
        onSaved: (value)=>email = value,
      ),
      TextFormField(
        decoration: InputDecoration(labelText:'Password'),
        obscureText: true,
        validator: (value)=>value.isEmpty ? 'Password can\'t be empty':null,
        onSaved: (value)=> password= value,
      ),
      RaisedButton(
        child: Text('Login',style: TextStyle(fontSize:20.0)),
        onPressed: (){
          validateAndSubmit();

        },

      ),
      RaisedButton(
        child: Text('Create an Account',style: TextStyle(fontSize:20.0)),
        onPressed: reg,
      ),
      RaisedButton(
        child: Text('Forgot Password',style: TextStyle(fontSize: 20.0)),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Forgot()));
        }
      ),
      ];

    }
    else if (_form == FormType.register){
      return [
        TextFormField(
          decoration: InputDecoration(labelText:'Name'),
          validator: (value)=>value.isEmpty ? 'Name can\'t be empty':null,
          onSaved: (value)=>name = value,
        ),
        TextFormField(
        decoration: InputDecoration(labelText:'Email'),
        validator: (value)=>value.isEmpty ? 'Email can\'t be empty':null,
        onSaved: (value)=>email = value,
      ),
      TextFormField(
        decoration: InputDecoration(labelText:'Password'),
        obscureText: true,
        validator: (value)=>value.isEmpty ? 'Password can\'t be empty':null,
        onSaved: (value)=> password= value,
      ),
      RaisedButton(
        child: Text('Register',style: TextStyle(fontSize:20.0)),
        onPressed: (){
          validateAndSubmit();

        },

      ),
      RaisedButton(
        child: Text('Login to Your Account',style: TextStyle(fontSize:20.0)),
        onPressed: log,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Student'),
          Radio(
            value: 0,
            groupValue: val,
            onChanged: (int vallue){
              setState(() {
                val = vallue;
                auth = AuthStatus.student;
                debugPrint(val.toString());
              });


            },
          ),
          Text('Teacher'),
          Radio(
            value: 1,
            groupValue: val,
            onChanged: (int value){
              setState(() {
                val = value;
                auth = AuthStatus.teacher;
                debugPrint(val.toString());
              });
            },
          ),

        ],
      ),

      ];

    }

  }
}
class Forgot extends StatefulWidget {
  @override
  ForgotState createState() => ForgotState();
}

class ForgotState extends State<Forgot> {
  bool validateAndSave(){
    final form = formKey.currentState;
    form.save();
    if(form.validate()){
      //debugPrint('$email $password');
      return true;
    }
    else{
      debugPrint('wa');
      return false;
    }
  }
  String email;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Reset'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (value) => value.isEmpty ? "Email can't be empty": null,
                onSaved: (value) => email = value,

              ),
              RaisedButton(
                onPressed:(){
                  if(validateAndSave()){
                    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((_){
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sending Email'),
                        ),
                      );
                    }
                    ).catchError((error){
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Password Reset Failed')
                        ),
                      );
                    });
                  }
                },
                child: Text('Send Reset Email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
