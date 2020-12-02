import 'package:flutter/material.dart';
import 'package:u_connect/res/firebase_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_connect/screens/home_screen.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseRepository _firebaseRepository = FirebaseRepository();
  bool isLoginPressed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Image.asset('images/logo_size.jpg'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Login',
            style: TextStyle(
              color: Colors.black,
              fontSize: 40,
              fontWeight: FontWeight.w900
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Stack(
            children: [
              Center(
                child: loginButton()
                ),
                isLoginPressed?
                Center(
                  child: CircularProgressIndicator(),
                  ):Container(
                  )
                ]
                ),
        ],
      ),
    );
  }
  Widget loginButton(){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(12)
      ),
      margin: EdgeInsets.only(left: 20, right: 20),
      child: FlatButton(
        color: Colors.white,
        padding: EdgeInsets.all(35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: <Widget>[
            Container(
              height: 20,
              width: 20,
              child: Image.asset('images/google.png')
              ),
              SizedBox(
                width: 20,
              ),
            Text('Sign in with google')
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          ),
        onPressed: ()=>performLogin(),
      ),
    );
  }

  void performLogin(){
    print('Performing login');
    setState(() {
      isLoginPressed = true;
    });
    _firebaseRepository.signIn().then((FirebaseUser user){
      print('Login Successful');
        if(user != null){
          authenticateUser(user);
        }
        else{
          print('Error');
        }
    });
  }

  void authenticateUser(FirebaseUser user){
    _firebaseRepository.authenticateUser(user).then((isNewUser){
      setState(() {
        isLoginPressed = false;
      });
        if(isNewUser){
          _firebaseRepository.addDataToDB(user).then((value){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                return HomeScreen();
            }));
          });
        }else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                return HomeScreen();
            }));
        }
    }); 
  }
}