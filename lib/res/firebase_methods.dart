import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_connect/constants/strings.dart';
import 'package:u_connect/enums/user_state.dart';
import 'package:u_connect/models/contact.dart';
import 'package:u_connect/models/message.dart';
import 'package:u_connect/models/user.dart';
import 'package:u_connect/provider/image_upload_provider.dart';
import 'package:u_connect/utils/utilities.dart';
StorageReference _storageReference;
class FirebaseMethods{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  User user = User();
  static final Firestore fireStore = Firestore.instance;
  static final CollectionReference _userCollection = fireStore.collection(USERS_COLLECTION);
  final CollectionReference _messageCollection = fireStore.collection(MESSAGES_COLLECTION);
  Future<FirebaseUser> getCurrentUser()async{
      FirebaseUser currentUser;
      currentUser = await _auth.currentUser();
      return currentUser;
  }
  Future<FirebaseUser> signIn()async{
      GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication _signInAuthentication = await _signInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: _signInAuthentication.idToken, accessToken: _signInAuthentication.accessToken);
      AuthResult result = await _auth.signInWithCredential(credential);
      FirebaseUser user = result.user;
      return user;
  }
  Future<bool> authenticateUser(FirebaseUser user)async{
    QuerySnapshot result = await fireStore.collection(USERS_COLLECTION).where(EMAIL_FIELD,isEqualTo: user.email).getDocuments();
    final List<DocumentSnapshot> docs = result.documents;
    return docs.length == 0? true:false;
  }
  Future<void> addDataToDB(FirebaseUser currentUser)async{
    String username = Utils.getUserName(currentUser.email);
    user = User(
      uid: currentUser.uid,
      email: currentUser.email,
      name: currentUser.displayName,
      profilePhoto: currentUser.photoUrl,
      username: username,
    );
    fireStore.collection(USERS_COLLECTION).document(currentUser.uid).setData(user.toMap(user));
  }
  Future<bool> signOut()async{
    try{
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    }catch(e){
      print(e);
      return false;
    }
  }
  Future<List<User>> fetchAllUsers(FirebaseUser user)async{
    List<User> usersList = List<User>();
    QuerySnapshot querySnapshot = await fireStore.collection(USERS_COLLECTION).getDocuments();
    for(int i = 0; i < querySnapshot.documents.length; i++){
        if(querySnapshot.documents[i].documentID != user.uid){
          usersList.add(User.fromMap(querySnapshot.documents[i].data));
        }
    }
    print(user.uid);
    return usersList;
  } 
  Future<void> addMessagetoDB(Message message, User sender, User reciever)async{
    var map = message.toMap();
    await _messageCollection.document(message.senderId).collection(message.recieverId).add(map);
    addToContacts(senderId: message.senderId, recieverId: message.recieverId);
    return await fireStore.collection(MESSAGES_COLLECTION).document(message.recieverId).collection(message.senderId).add(map);
  }
  DocumentReference getContactsDocuments({String of, String forContact}) =>_userCollection.document(of).collection(CONTACT_COLLECTION).document(forContact);
  addToContacts({senderId, recieverId}) async{
    Timestamp currentTime = Timestamp.now();
    _userCollection.document(senderId).collection(CONTACT_COLLECTION).document(recieverId);
    await addToSendersContact(senderId: senderId, reciverId: recieverId, currentTime: currentTime.toString());
    await addToRecieversContact(senderId: senderId, reciverId: recieverId, currentTime: currentTime.toString());
  }
  Future<void> addToSendersContact({String senderId, String reciverId, currentTime})async{
    DocumentSnapshot senderSnapshot = await getContactsDocuments(of: senderId, forContact: reciverId).get();
    if(!senderSnapshot.exists){
      Contact recieverContact = Contact(uid: reciverId, addedOn: currentTime);
      var reciverMap = recieverContact.toMap(recieverContact);
      await getContactsDocuments(of: senderId, forContact: reciverId).setData(reciverMap);
    }
  }
  Future<void> addToRecieversContact({String senderId, String reciverId, currentTime})async{
    DocumentSnapshot recieverSnapshot = await getContactsDocuments(of: reciverId, forContact: senderId).get();
    if(!recieverSnapshot.exists){
      Contact senderContact = Contact(uid: senderId, addedOn:  currentTime);
      var senderMap = senderContact.toMap(senderContact);
      await getContactsDocuments(of: reciverId, forContact: senderId).setData(senderMap);
    }
  }
  Future<String> uploadImageToStorage(File image)async{
    try{
      _storageReference = FirebaseStorage.instance.ref().child('${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask _storageUploadTask = _storageReference.putFile(image);
    return await (await _storageUploadTask.onComplete).ref.getDownloadURL();}
    catch(e){
      print(e);
      return null;
    }
  }
  setImageMessage(String url, String recieverId, String senderId)async{
    Message _message;
    _message = Message.imageMessage(
      message: 'IMAGE',
      photoUrl: url,
      recieverId: recieverId,
      senderId: senderId,
      timeStamp: Timestamp.now(),
      type: 'image'
    );
    var map = _message.toImageMap();
    await _messageCollection.document(senderId).collection(recieverId).add(map);
    await _messageCollection.document(recieverId).collection(senderId).add(map);
  }
  Future<void> uploadImage({File image, String recieverId, String senderId, ImageUploadProvider imageUploadProvider})async{
    imageUploadProvider.setToLoading();
    String url = await uploadImageToStorage(image);
    imageUploadProvider.setToIdle();
    setImageMessage(url, recieverId, senderId);
  }
  Future<User> getUserDetails()async{
    FirebaseUser currentUser = await getCurrentUser();
    DocumentSnapshot documentSnapshot = await _userCollection.document(currentUser.uid).get();
    return User.fromMap(documentSnapshot.data);
  }
  Future<User> getUserDetailsById({String id}) async {
    try{
      DocumentSnapshot documentSnapshot = await _userCollection.document(id).get();
      return User.fromMap(documentSnapshot.data);
    }catch(e){
      print(e);
      return null;
    }
  }
  Stream<QuerySnapshot> fetchContacts({String userId}) => _userCollection.document(userId).collection(CONTACT_COLLECTION).snapshots();
  Stream<QuerySnapshot> fetchLastMessageBetween({@required String senderId,@required String recieverId}) => _messageCollection.document(senderId).collection(recieverId).orderBy(TIMESTAMP_FIELD).snapshots();
  void setUserState({@required String userId, @required UserState userState}){
    int stateNum = Utils.stateToNum(userState);
    _userCollection.document(userId).updateData({STATE_FIELD : stateNum});
  }
  Stream<DocumentSnapshot> getUserStream(String uid){
    return _userCollection.document(uid).snapshots();
  }
}