import 'package:flutter/cupertino.dart';
import 'package:pet_friendly/models/post_model.dart';

class PostProvider extends ChangeNotifier {
  List<PostModel> posts = [];
}