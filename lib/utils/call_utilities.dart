import 'dart:math';

import 'package:flutter/material.dart';
import 'package:u_connect/models/call.dart';
import 'package:u_connect/models/user.dart';
import 'package:u_connect/res/call_methods.dart';
import 'package:u_connect/screens/call_screens/call_screen.dart';

class CallUtils{
  static final CallMethods callMethods = CallMethods();
  static dial({User from, User to,context})async{
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
    );
    bool callMade = await callMethods.makeCall(call);
    call.hasDialled = true;
    if(callMade){
      Navigator.push(context, MaterialPageRoute(builder: (context) => CallScreen(call: call,)));
    }
  }
}