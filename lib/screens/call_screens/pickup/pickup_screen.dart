import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:u_connect/models/call.dart';
import 'package:u_connect/res/call_methods.dart';
import 'package:u_connect/screens/chat_screen/widgets/cached_image.dart';
import 'package:u_connect/utils/permissions.dart';

import '../call_screen.dart';
class PickUpScreen extends StatelessWidget {
  final Call call;
  final CallMethods callMethods = CallMethods();
  PickUpScreen({@required this.call});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Incoming call...',
              style: GoogleFonts.openSans(
                fontSize: 30,
                color: Colors.green
              ),
            ),
            CachedImage(
              call.callerPic,
              isRound: true,
              radius: 180,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              call.callerName,
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),
            ),
            SizedBox(
              height: 75,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call_end, color: Colors.redAccent,),
                  onPressed: ()async{
                    await callMethods.endCall(call: call);
                  },
                ),
                SizedBox(
                  width: 25,
                ),
                IconButton(
                  icon: Icon(Icons.call, color: Colors.greenAccent,),
                  onPressed: () async => await Permissions.cameraAndMicrophonePermissionsGranted() ? Navigator.push(context,MaterialPageRoute(builder: (context) => CallScreen(call: call))) : {},
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}