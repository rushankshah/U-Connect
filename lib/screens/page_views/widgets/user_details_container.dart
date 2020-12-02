import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:u_connect/models/user.dart';
import 'package:u_connect/provider/user_provider.dart';
import 'package:u_connect/res/firebase_methods.dart';
import 'package:u_connect/screens/chat_screen/widgets/cached_image.dart';
import 'package:u_connect/screens/login_screen.dart';
import 'package:u_connect/widgets/custom_app_bar.dart';
class UserDetailsContainer extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    signOut()async{
    final bool isSignedOut = await FirebaseMethods().signOut();
    if(isSignedOut)
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginScreen()), (route) => false);
  }
    return Container(
      margin: EdgeInsets.only(top: 25),
      child: Column(
        children: <Widget>[
          CustomAppBar(
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            centerTitle: true,
            title: Image.asset('images/logo_size.jpg'),
            actions: <Widget>[
              FlatButton(
                onPressed: () => signOut(),
                child: Icon(
                  Icons.exit_to_app,
                  color: Colors.black,
                ),
              )
            ],
          ),
          UserDetailsBody(),
        ],
      ),
    );
  }
}
class UserDetailsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final User user = userProvider.getUser;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: <Widget>[
          CachedImage(
            user.profilePhoto,
            isRound: true,
            radius: 50,
          ),
          SizedBox(width: 15,),
          Column(
            children: <Widget>[
              Text(
                user.name,
                style: GoogleFonts.openSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black
                ),
              ),
              SizedBox(height: 10,),
              Text(
                user.email,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  color: Colors.black
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}