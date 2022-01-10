import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_friendly/models/comment_model.dart';

class PostModel {
  String id = "", description = "", type = "", createdById = "", createdByName = "", createdByImage = "";
  List<String> images = [];
  List<CommentModel> comments = [];
  Timestamp? createdTime;
  int likesCount = 0;

  PostModel();

  PostModel.fromMap(Map<String, dynamic> map) {
    id = map['id']?.toString() ?? "";
    description = map['description']?.toString() ?? "";
    type = map['type']?.toString() ?? "";
    createdById = map['createdById']?.toString() ?? "";
    createdByName = map['createdByName']?.toString() ?? "";
    createdByImage = map['createdByImage']?.toString() ?? "";
    createdTime = map['createdTime'];
    likesCount = map['likesCount'] ?? 0;

    try {
      List<String> list = List.castFrom(map['images'] ?? []);
      images = list;
    }
    catch(e) {}

    try {
      List<Map<String, dynamic>> list = List.castFrom(map['comments'] ?? []);
      comments = list.map((e) => CommentModel.fromMap(e)).toList();
    }
    catch(e) {}

  }

  void updateFromMap(Map<String, dynamic> map) {
    id = map['id']?.toString() ?? "";
    description = map['description']?.toString() ?? "";
    type = map['type']?.toString() ?? "";
    createdById = map['createdById']?.toString() ?? "";
    createdByName = map['createdByName']?.toString() ?? "";
    createdByImage = map['createdByImage']?.toString() ?? "";
    createdTime = map['createdTime'];
    likesCount = map['likesCount'] ?? 0;

    try {
      List<String> list = List.castFrom(map['images'] ?? []);
      images = list;
    }
    catch(e) {}

    try {
      List<Map<String, dynamic>> list = List.castFrom(map['comments'] ?? []);
      comments = list.map((e) => CommentModel.fromMap(e)).toList();
    }
    catch(e) {}

  }

  Map<String, dynamic> tomap() {
    List<Map<String, dynamic>> list = [];
    list.addAll(comments.map((e) => e.tomap()).toList());

    return {
      "id" : id,
      "description" : description,
      "type" : type,
      "createdById" : createdById,
      "createdByName" : createdByName,
      "createdByImage" : createdByImage,
      "createdTime" : createdTime,
      "likesCount" : likesCount,
      "images" : images,
      "comments" : comments,
    };
  }

  @override
  String toString() {
    return "id:${id}, description:$description, type:$type, createdById:$createdById, createdByName:$createdByName,"
        " createdByImage:$createdByImage, createdTime:$createdTime, likesCount:$likesCount, images:$images, "
        "comments:$comments";
  }
}