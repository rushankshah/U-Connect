import 'package:flutter/material.dart';
import 'package:u_connect/enums/user_state.dart';
import 'package:u_connect/models/user.dart';
import 'package:u_connect/res/firebase_methods.dart';
import 'package:u_connect/utils/utilities.dart';

class StateIndicator extends StatelessWidget {
  final FirebaseMethods firebaseMethods = FirebaseMethods();
  final String uid;
  StateIndicator({@required this.uid});
  getColor(int inp){
    switch(Utils.numToState(inp)){
      case UserState.Offline:
        return Colors.red;
      case UserState.Online:
        return Colors.green;
      default:
        return Colors.white;
    }
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firebaseMethods.getUserStream(uid),
      builder: (context, snapshot){
        User user = User();
        if(snapshot.hasData && snapshot.data.data != null)
          {
            user = User.fromMap(snapshot.data.data);
            return Container(
              height: 10,
              width: 10,
              margin: EdgeInsets.only(right: 8, top: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: getColor(user?.state),
              ),
            );
          }
          return CircularProgressIndicator();
      },
    );
  }
}