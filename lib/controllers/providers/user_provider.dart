import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:pet_friendly/models/user_model.dart';
import 'package:pet_friendly/utils/my_print.dart';

class UserProvider extends ChangeNotifier {
  String userid = "";
  User? firebaseUser;
  UserModel? userModel;

  int selectedScreen = 0;

  void setScreen(int index) {
    selectedScreen = index;
    MyPrint.printOnConsole("Selected index:$index");
    notifyListeners();
  }
}