import 'package:provider/provider.dart';
import 'package:u_connect/provider/image_upload_provider.dart';
import 'package:u_connect/provider/user_provider.dart';
import 'package:u_connect/screens/chat_screen/chat_screen.dart';
import 'package:u_connect/screens/search_screen.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:u_connect/res/firebase_repository.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseRepository _firebaseRepository = FirebaseRepository();
  @override
  Widget build(BuildContext context) {
    return MultiProvider (
        providers: [
          ChangeNotifierProvider(create: (context) => ImageUploadProvider(),),
          ChangeNotifierProvider(create: (context) => UserProvider(),),
        ],
          child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.orange
        ),
        title: 'U Connect',
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/searchScreen' : (context) => SearchScreen(),
          '/chatScreen' : (context) => ChatScreen(),
        },
        home: FutureBuilder(
          future: _firebaseRepository.getCurrentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot){
              if(snapshot.hasData){
                return HomeScreen();
              }else{
                return LoginScreen();
              }
          },
          )
      ),
    );
  }
}