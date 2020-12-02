import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_connect/constants/strings.dart';

class Contact{
  String uid;
  Timestamp addedOn;
  Contact({this.uid, this.addedOn});
  Map toMap(Contact contact){
    var data = Map<String, dynamic>();
    data[CONTACT_ID] = contact.uid;
    data[ADDED_ON] = contact.addedOn.toString();
    return data;
  }
  Contact.fromMap(Map<String, dynamic> mapData){
    this.uid = mapData[CONTACT_ID];
    this.addedOn = mapData[ADDED_ON];
  }
}