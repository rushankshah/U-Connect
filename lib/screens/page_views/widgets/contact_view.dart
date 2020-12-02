import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:u_connect/models/contact.dart';
import 'package:u_connect/models/user.dart';
import 'package:u_connect/provider/user_provider.dart';
import 'package:u_connect/res/firebase_methods.dart';
import 'package:u_connect/screens/chat_screen/widgets/cached_image.dart';
import 'package:u_connect/screens/page_views/widgets/state_indicator.dart';
import 'package:u_connect/widgets/custom_tile.dart';

import 'last_message_container.dart';
class ContactView extends StatelessWidget {
  final FirebaseMethods firebaseMethods = FirebaseMethods();
  final Contact contact;
  ContactView({this.contact});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: firebaseMethods.getUserDetailsById(id: contact.uid),
      builder: (context, snapshot){
        if(snapshot.hasData){
          User user = snapshot.data;
          return ViewLayout(contact: user,);
        }
        else{
          return Center(child: CircularProgressIndicator(),);
        }
      },
    );
  }
}
class ViewLayout extends StatelessWidget {
  final User contact;
  final FirebaseMethods firebaseMethods = FirebaseMethods();
  ViewLayout({this.contact});
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
     return CustomTile(
            mini: false,
            onTap: (){
              Navigator.pushNamed(context,'/chatScreen',arguments: contact);
            },
            title: Text(
                    contact?.name ?? 'U Connect User', 
                    style: GoogleFonts.openSans(
                      color: Colors.black,
                      fontSize: 20
                    )
                ),
            subtitle: LastMessageContainer(
              stream: firebaseMethods.fetchLastMessageBetween(senderId: userProvider.getUser.uid, recieverId: contact.uid),
            ),
            leading: Container(
            constraints: BoxConstraints(
                maxHeight: 60,
                maxWidth: 60
              ),
                  child: Stack(
                    children: <Widget>[
                      CachedImage(
                        contact.profilePhoto,
                        isRound: true,
                        radius: 80,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: StateIndicator(uid: contact.uid,)
                      ),
                    ],
                  ),
                ),
          );
  }
}