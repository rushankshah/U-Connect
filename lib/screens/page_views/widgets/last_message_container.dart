import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:u_connect/models/message.dart';

class LastMessageContainer extends StatelessWidget {
  final stream;
  LastMessageContainer({@required this.stream});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(snapshot.hasData){
          var docs = snapshot.data.documents;
          if(docs.isNotEmpty){
            Message message = Message.fromMap(docs.last.data);
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(
                message.message,
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            );
          }
          return Text(
              'No message'
            );
        }
        return Text(
              '..'
            );
      },
    );
  }
}