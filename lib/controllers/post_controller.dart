import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pet_friendly/controllers/firestore_controller.dart';
import 'package:pet_friendly/controllers/providers/post_provider.dart';
import 'package:pet_friendly/models/comment_model.dart';
import 'package:pet_friendly/models/post_model.dart';
import 'package:pet_friendly/models/user_model.dart';
import 'package:pet_friendly/utils/my_print.dart';
import 'package:provider/provider.dart';

class PostController {
  Future<List<PostModel>> getPosts(BuildContext context) async {
    List<PostModel> posts = [];

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirestoreController().firestore.collection("posts").orderBy("createdTime", descending: true).get();
    querySnapshot.docs.forEach((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      if(documentSnapshot.data()?.isNotEmpty ?? false) posts.add(PostModel.fromMap(documentSnapshot.data()!));
    });
    PostProvider postProvider = Provider.of(context, listen: false);
    postProvider.posts = posts;

    return posts;
  }

  Future<bool> likeUnlikePost(PostModel postModel, UserModel userModel, {bool isLike = true}) async {
    bool isSuccess = false;

    try {
      Map<String, dynamic> postdata = {};
      postdata['likesCount'] = FieldValue.increment(isLike ? 1 : -1);

      Map<String, dynamic> userdata = {};
      userdata['myLikedPosts'] = isLike ? FieldValue.arrayUnion([postModel.id]) : FieldValue.arrayRemove([postModel.id]);

      int count = 0;
      Function whenComplete = () => count++;

      FirestoreController().firestore.collection("posts").doc(postModel.id).update(postdata).whenComplete(() {
        whenComplete();
      });
      FirestoreController().firestore.collection("users").doc(userModel.id).update(userdata).whenComplete(() {
        whenComplete();
      });

      while(count < 2) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      if(isLike) {
        postModel.likesCount++;
        userModel.myLikedPosts.add(postModel.id);
      }
      else {
        postModel.likesCount--;
        userModel.myLikedPosts.remove(postModel.id);
      }
      isSuccess = true;
    }
    catch(e) {
      MyPrint.printOnConsole("Error in Like:${e}");
    }

    return isSuccess;
  }

  Future<bool> commentOnPost(UserModel userModel, PostModel postModel, String comment) async {
    bool isSuccess = false;

    try {
      CommentModel commentModel = CommentModel();
      commentModel.comment = comment;
      commentModel.createdById = userModel.id;
      commentModel.createdByName = userModel.name;
      commentModel.createdByImage = userModel.image;
      commentModel.createdTime = Timestamp.now();

      await FirestoreController().firestore.collection("posts").doc(postModel.id).update({"comments" : FieldValue.arrayUnion([commentModel.tomap()])});
      isSuccess = true;
      postModel.comments.add(commentModel);
    }
    catch(e) {
      MyPrint.printOnConsole("Error in Commenting On Post:${e}");
    }

    return isSuccess;
  }
}