import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_connect/models/call.dart';
import 'package:u_connect/provider/user_provider.dart';
import 'package:u_connect/res/call_methods.dart';
import 'package:u_connect/screens/call_screens/pickup/pickup_screen.dart';
class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();
  PickupLayout({@required this.scaffold});
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return (userProvider != null && userProvider.getUser != null)?
    StreamBuilder<DocumentSnapshot>(
      stream: callMethods.callStream(uid: userProvider.getUser.uid),
      builder: (context, snapshot){
        if(snapshot.hasData && snapshot.data.data!=null){
          Call call = Call.fromMap(snapshot.data.data);
          return call.hasDialled ? scaffold : PickUpScreen(call: call);
        }else{
          return scaffold;
        }
      },
    ):
    Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}