import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:u_connect/models/message.dart';
import 'package:u_connect/models/user.dart';
import 'package:u_connect/provider/image_upload_provider.dart';
import 'package:u_connect/res/firebase_methods.dart';

class FirebaseRepository{
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  Future<FirebaseUser> getCurrentUser() => _firebaseMethods.getCurrentUser();
  Future<FirebaseUser> signIn() => _firebaseMethods.signIn();
  Future<bool> authenticateUser(FirebaseUser user) => _firebaseMethods.authenticateUser(user);
  Future<void> addDataToDB(FirebaseUser user) => _firebaseMethods.addDataToDB(user);
  Future<void> signOut() => _firebaseMethods.signOut();
  Future<List<User>> fetchAllUsers(FirebaseUser user) => _firebaseMethods.fetchAllUsers(user);
  Future<void> addMessageToDB(Message message, User sender, User reciever) => _firebaseMethods.addMessagetoDB(message, sender,reciever);
  Future<void> uploadImage({@required File image,@required String recieverId,@required String senderId,@required ImageUploadProvider imageUploadProvider}) => _firebaseMethods.uploadImage(image: image, recieverId: recieverId, senderId: senderId, imageUploadProvider: imageUploadProvider);
  Future<User> getUserDetails() => _firebaseMethods.getUserDetails();
}