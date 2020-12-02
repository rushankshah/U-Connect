import 'package:flutter/material.dart';

class ChatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        child: Icon(Icons.chat_bubble_outline, color: Colors.white,),
        backgroundColor: Colors.orange,
        onPressed: (){
          Navigator.pushNamed(context, '/searchScreen');
        },
        tooltip: 'New chat',
      );
  }
}