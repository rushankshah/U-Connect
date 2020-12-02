import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:u_connect/models/contact.dart';
import 'package:u_connect/provider/user_provider.dart';
import 'package:u_connect/res/firebase_methods.dart';
import 'package:u_connect/screens/page_views/widgets/contact_view.dart';
import 'package:u_connect/screens/page_views/widgets/new_chat_button.dart';
import 'package:u_connect/screens/page_views/widgets/quiet_box.dart';
import 'package:u_connect/screens/page_views/widgets/user_circle.dart';
import 'package:u_connect/widgets/custom_app_bar.dart';
class ChatListScreen extends StatelessWidget {
  CustomAppBar customAppBar(BuildContext context){
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.notifications,
          color: Colors.black,
        ),
        onPressed: (){},
      ),
      title: Row(
        children: <Widget>[
          UserCircle(),
          Flexible(child: Image.asset('images/logo_size.jpg')),
        ],
      ),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.black,
          ),
          onPressed: (){
            Navigator.pushNamed(context, '/searchScreen');
          },
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Colors.black,
          ),
          onPressed: (){},
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context),
      floatingActionButton: ChatButton(),
      body: ChatListContainer(),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  final FirebaseMethods firebaseMethods = FirebaseMethods();
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: firebaseMethods.fetchContacts(userId: userProvider.getUser.uid),
        builder: (context, snapshot)
        {
          if(snapshot.hasData){
            var docs = snapshot.data.documents;
            if(docs.isEmpty)
              return QuietBox();
            return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context,index){
            Contact contact = Contact.fromMap(snapshot.data.documents[index].data);
            return ContactView(
              contact: contact
            );
          },
        );
        }else{
          return Center(child: CircularProgressIndicator(
            backgroundColor: Colors.orangeAccent,
          ),);
        }
          
        }
      ),
    );
  }
}

  