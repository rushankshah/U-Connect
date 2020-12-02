import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Img;
import 'package:path_provider/path_provider.dart';
import 'package:u_connect/enums/user_state.dart';

class Utils{
  static String getUserName(String email){
    return 'u_c:${email.split('@')[0]}';
  }
  static String getInitials(String displayName){
    List<String> nameSplit = displayName.split(" ");
    String firstNameInitial = nameSplit[0][0];
    String lastNameInitial = nameSplit[1][0];
    return firstNameInitial+lastNameInitial;
  }
  static Future<File> pickImage({@required ImageSource source})async{
    PickedFile selectedImage = await ImagePicker().getImage(source: source);
    return compressImage(File(selectedImage.path));
  }
  static Future<File> compressImage(File imageToCompress)async{
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    int random = Random().nextInt(1000);
    Img.Image image = Img.decodeImage(imageToCompress.readAsBytesSync());
    Img.copyResize(image, width: 500, height: 500);
    return File('$path/img_$random.jpg')..writeAsBytesSync(Img.encodeJpg(image, quality: 90));
  }
  static int stateToNum(UserState userState){
    switch(userState){
      case UserState.Offline:
        return 0;
        break;
      case UserState.Online:
        return 1;
        break;
      case UserState.Waiting:
        return 2;
        break;
      default:
        return -1;
        break;
    }
  }
  static UserState numToState(int num){
    switch(num){
      case 0:
        return UserState.Offline;
        break;
      case 1:
        return UserState.Online;
        break;
      case 2:
        return UserState.Waiting;
        break;
      default:
        return null;
    }
  }
}