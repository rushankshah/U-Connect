import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:u_connect/constants/strings.dart';
import 'package:u_connect/enums/view_state.dart';
import 'package:u_connect/models/message.dart';
import 'package:u_connect/models/user.dart';
import 'package:u_connect/provider/image_upload_provider.dart';
import 'package:u_connect/res/firebase_repository.dart';
import 'package:u_connect/screens/chat_screen/widgets/cached_image.dart';
import 'package:u_connect/utils/call_utilities.dart';
import 'package:u_connect/utils/permissions.dart';
import 'package:u_connect/utils/utilities.dart';
import 'package:u_connect/widgets/custom_app_bar.dart';
import 'package:u_connect/widgets/custom_tile.dart';
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _controller = TextEditingController();
  FirebaseRepository _repository = FirebaseRepository();
  bool isWriting = false, showEmojiPicker = false;
  User sender;
  String currentUserId;
  ScrollController _scrollController = ScrollController();
  FocusNode textFieldFocus = FocusNode();
  ImageUploadProvider _imageUploadProvider;

  initState(){
    super.initState();
    _repository.getCurrentUser().then(
      (user){
        currentUserId = user.uid;
        setState(() {
          sender = User(
            uid: user.uid,
            name: user.displayName,
            profilePhoto: user.photoUrl
          );
        });
      }
    );
  }

  addMediaModel(context){
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context, 
      builder: (context){
        return Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Context and tools',
                        style: GoogleFonts.openSans(
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                children: <Widget>[
                  ModalTile(
                    title: 'Media',
                    subtitle: 'Share photos and videos',
                    icon: Icons.image,
                    onPressed: () => pickImage(source: ImageSource.gallery),
                  ),
                  ModalTile(
                        title: "File",
                        subtitle: "Share files",
                        icon: Icons.tab),
                    ModalTile(
                        title: "Contact",
                        subtitle: "Share contacts",
                        icon: Icons.contacts),
                    ModalTile(
                        title: "Location",
                        subtitle: "Share a location",
                        icon: Icons.add_location),
                    ModalTile(
                        title: "Schedule Call",
                        subtitle: "Arrange a Call and get reminders",
                        icon: Icons.schedule),
                    ModalTile(
                        title: "Create Poll",
                        subtitle: "Share polls",
                        icon: Icons.poll),
                ],
              ),
            ),
          ],
        );
      }
      );
  }

  showKeyboard() => textFieldFocus.requestFocus();
  hideKeyboard() => textFieldFocus.unfocus();
  hideEmojiContainer(){
    setState(() {
      showEmojiPicker = false;
    });
  }
  showEmojiContainer(){
    setState(() {
      showEmojiPicker = true;
    });
  }
  
  Widget chatControls(){
      return Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                   shape: BoxShape.circle, 
              ),
              child: IconButton(
                onPressed: (){
                  addMediaModel(context);
                },

                  icon: Icon(
                  Icons.add,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.centerRight,
                    children: 
                    [
                      TextField(
                        onTap: () => hideEmojiContainer(),
                        focusNode: textFieldFocus,
                    controller: _controller,
                    style: GoogleFonts.openSans(
                      color: Colors.black,
                      fontSize: 16
                    ),
                    onChanged: (value){
                      if(value.length>0 && value.trim() != '' ){
                          setState(() {
                          isWriting = true;
                        });
                      }
                      else{
                        setState(() {
                        isWriting = false;
                      });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Write a message..',
                      hintStyle: GoogleFonts.openSans(
                          color: Colors.grey,
                          fontSize: 12
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                ),
                IconButton(
                  icon: Icon(Icons.tag_faces,color: Colors.black,),
                  onPressed: (){
                    if(!showEmojiPicker){
                      showEmojiContainer();
                      hideKeyboard();
                    }else{
                      hideEmojiContainer();
                      showKeyboard();
                    }
                  },
                ),
              ]
              ),
            ),
            isWriting ? Container() : Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.5),
              child: IconButton(
                              icon: Icon(
                  Icons.keyboard_voice,
                  color: Colors.black,
                ),
                onPressed: (){},
              ),
            ),
            isWriting ? Container() : IconButton(
                          icon: Icon(
                Icons.photo_camera,
                color: Colors.black,
              ),
              onPressed: (){
                pickImage(source: ImageSource.camera);
              },
            ),
            isWriting ? Container(
              margin: EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle
              ),
              child: IconButton(
                  icon: Icon(
                  Icons.send,
                  color: Colors.orange,
                ),
                onPressed: (){
                  sendMessage();
                },
              ),
            ) : Container(),
          ],
        ),
      );
  }
  pickImage({@required ImageSource source})async{
    File selectedImage = await Utils.pickImage(source: source);
    _repository.uploadImage(image: selectedImage, recieverId: _reciever.uid, senderId: sender.uid, imageUploadProvider: _imageUploadProvider);
  }

  sendMessage(){
    var text = _controller.text;
    Message _message = Message(
      recieverId: _reciever.uid,
      senderId: sender.uid,
      message: text,
      timeStamp: Timestamp.now(),
      type: 'text'
    );
    setState(() {
      isWriting = false;
      _controller.clear();
      _repository.addMessageToDB(_message, sender, _reciever);
    });
  }

  Widget messageList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection(MESSAGES_COLLECTION)
          .document(currentUserId)
          .collection(_reciever.uid)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }
        // SchedulerBinding.instance.addPostFrameCallback((_) { 
        //   _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: Duration(microseconds: 250), curve: Curves.easeInOut);
        // });
        return ListView.builder(
          padding: EdgeInsets.all(10),
          reverse: true,
          controller: _scrollController,
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            return chatMessageItem(snapshot.data.documents[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Container(
        alignment: _message.senderId == currentUserId ? Alignment.centerRight : Alignment.centerLeft,
        child: _message.senderId == currentUserId ? senderLayout(_message) : receiverLayout(_message),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message)
      ),
    );
  }

  getMessage(Message message){
    return message.type != MESSAGE_TYPE_IMAGE ?
    Text(
      message.message,
      style: GoogleFonts.openSans(
        fontSize: 16,

      ),
    ):
    message.photoUrl != null ? CachedImage(message.photoUrl,height: 250, width: 250, radius: 10,):Text('Null URL');
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message)
      ),
    );
  }

  User _reciever;
  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    final User reciever = ModalRoute.of(context).settings.arguments;
    _reciever = reciever;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context),
      body: Column(
        children: <Widget>[
          Flexible(
            child: messageList(),
          ),
          _imageUploadProvider.getViewState == ViewState.LOADING ? Container(
              child: CircularProgressIndicator(),
              margin: EdgeInsets.only(right: 15),
              alignment: Alignment.centerRight,
            ) : 
            Container(),
          chatControls(),
          showEmojiPicker ? Container(child: emojiContainer(),) : Container(),
        ],
      ),
    );
  }

  Widget emojiContainer(){
    return EmojiPicker(
      bgColor: Colors.white,
      indicatorColor: Colors.orange,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category){
          setState(() {
            isWriting = true;
          });
          _controller.text = _controller.text + emoji.emoji;
      },
      recommendKeywords: ['face','happy','party'],
      numRecommended: 50,
    );
  }

  CustomAppBar customAppBar(context){
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),
        onPressed: (){
            Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        _reciever.name,
        style: GoogleFonts.openSans(
          color: Colors.black,
          fontSize: 20
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.video_call,
            color: Colors.black,
          ),
          onPressed: ()async => await Permissions.cameraAndMicrophonePermissionsGranted() ? CallUtils.dial(context: context, from: sender, to: _reciever) : {},
        ),
        IconButton(
          icon: Icon(
            Icons.call,
            color: Colors.black,
          ),
          onPressed: (){},
        ),
      ],
    );
  }
}
class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onPressed;
  ModalTile({@required this.title, @required this.icon, @required this.subtitle, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        onTap: onPressed,
        mini: false,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.black
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Colors.orange,
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.openSans(
            color: Colors.black,
            fontSize: 14
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.openSans(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}