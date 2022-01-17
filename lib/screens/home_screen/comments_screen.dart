import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:pet_friendly/controllers/post_controller.dart';
import 'package:pet_friendly/controllers/providers/user_provider.dart';
import 'package:pet_friendly/models/comment_model.dart';
import 'package:pet_friendly/models/post_model.dart';
import 'package:pet_friendly/screens/common/components/app_bar.dart';
import 'package:pet_friendly/screens/common/components/modal_progress_hud.dart';
import 'package:pet_friendly/utils/SizeConfig.dart';
import 'package:pet_friendly/utils/my_print.dart';
import 'package:pet_friendly/utils/styles.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final PostModel postModel;
  const CommentsScreen({Key? key, required this.postModel}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  bool isLoading = false;

  TextEditingController commentController = TextEditingController();

  Future<void> makeAComment() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      isLoading = true;
    });

    bool isSuccess = await PostController().commentOnPost(userProvider.userModel!, widget.postModel, commentController.text);

    if(isSuccess) commentController.clear();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !isLoading;
      },
      child: ModalProgressHUD(
        opacity: 0.3,
        inAsyncCall: isLoading,
        color: Colors.black,
        child: Container(
          color: Styles.background,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Styles.background,
              body: Column(
                children: [
                  MyAppBar(title: "Comments", backbtnVisible: true, color: Colors.white,),
                  Expanded(
                    child: getCommentsListView(widget.postModel.comments),
                  ),
                  getCommentTextField(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getCommentsListView(List<CommentModel> comments) {
    if(comments.isEmpty) return const Center(child: Text("No Comments"));

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: MySize.size5!),
      children: comments.map((e) {
        return getCommentWidget(e, userProvider.userid == e.createdById);
      }).toList(),
    );
  }

  Widget getCommentWidget(CommentModel comment, bool isMyComment) {
    MyPrint.printOnConsole("Created Time:${comment.createdTime}");

    if(isMyComment) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width *0.7
                    ),
                    // padding: EdgeInsets.symmetric(
                    //     horizontal: MySize.getScaledSizeHeight(5),
                    //     vertical: MySize.getScaledSizeHeight(5)
                    // ),
                    padding: EdgeInsets.symmetric(
                        horizontal: MySize.getScaledSizeHeight(7),
                        vertical: MySize.getScaledSizeHeight(7)
                    ),
                    decoration: BoxDecoration(
                      color: Styles.primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(MySize.getScaledSizeHeight(10)),
                        bottomRight: Radius.circular(MySize.getScaledSizeHeight(10)),
                        topLeft: Radius.circular(MySize.getScaledSizeHeight(10)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            comment.createdByName,
                            style: TextStyle(
                              fontSize: MySize.size10,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MySize.size5,
                        ),
                        Flexible(
                          child: Container(
                            child: SelectableText(
                              comment.comment,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: MySize.getScaledSizeHeight(14)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MySize.size5,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            comment.createdTime != null ? DateFormat("dd/MM/yyyy hh:mm:ss").format(comment.createdTime!.toDate()) : "",
                            style: TextStyle(
                              fontSize: MySize.size8,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: MySize.getScaledSizeHeight(5),
          ),
          Container(
            width: MySize.getScaledSizeHeight(40),
            height: MySize.getScaledSizeHeight(40),
            //padding: EdgeInsets.all(MySize.getScaledSizeHeight(2)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, style: BorderStyle.solid, width: MySize.getScaledSizeHeight(2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(240),
              child: CachedNetworkImage(
                imageUrl: comment.createdByImage,
                fit: BoxFit.cover,
                placeholder: (context, _) {
                  return SpinKitFadingCircle(color: Styles.primaryColor,);
                },
                errorWidget: (___, __, _) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey[400],
                    size: MySize.size20!,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: MySize.getScaledSizeHeight(40),
            height: MySize.getScaledSizeHeight(40),
            //padding: EdgeInsets.all(MySize.getScaledSizeHeight(2)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, style: BorderStyle.solid, width: MySize.getScaledSizeHeight(2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(240),
              child: CachedNetworkImage(
                imageUrl: comment.createdByImage,
                fit: BoxFit.cover,
                placeholder: (context, _) {
                  return SpinKitFadingCircle(color: Styles.primaryColor,);
                },
                errorWidget: (___, __, _) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_outlined,
                    color: Colors.grey[400],
                    size: MySize.size20!,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: MySize.getScaledSizeHeight(5),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width *0.7
                    ),
                    // padding: EdgeInsets.symmetric(
                    //     horizontal: MySize.getScaledSizeHeight(5),
                    //     vertical: MySize.getScaledSizeHeight(5)
                    // ),
                    padding: EdgeInsets.symmetric(
                        horizontal: MySize.getScaledSizeHeight(7),
                        vertical: MySize.getScaledSizeHeight(7)
                    ),
                    decoration: BoxDecoration(
                      color: Styles.primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(MySize.getScaledSizeHeight(10)),
                        bottomRight: Radius.circular(MySize.getScaledSizeHeight(10)),
                        topLeft: Radius.circular(MySize.getScaledSizeHeight(10)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            comment.createdByName,
                            style: TextStyle(
                              fontSize: MySize.size10,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MySize.size5,
                        ),
                        Flexible(
                          child: Container(
                            child: SelectableText(
                              comment.comment,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: MySize.getScaledSizeHeight(14)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MySize.size5,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            comment.createdTime != null ? DateFormat("dd/MM/yyyy hh:mm:ss").format(comment.createdTime!.toDate()) : "",
                            style: TextStyle(
                              fontSize: MySize.size8,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget getCommentTextField()  {
    return Container(
      margin: EdgeInsets.symmetric(vertical: MySize.size10!, horizontal: MySize.size16!),
      child: TextFormField(
        controller: commentController,
        onChanged: (String? value) {
          setState(() {});
        },
        decoration: getTextFieldInputDecoration(hintText: "Comment", fillColor: Colors.white).copyWith(
          suffix: commentController.text.isNotEmpty ? InkWell(
            onTap: () {
              if(commentController.text.isNotEmpty) {
                makeAComment();
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: MySize.size10!, vertical: MySize.size5!),
              decoration: BoxDecoration(
                border: Border.all(color: Styles.primaryColor, width: 1),
                borderRadius: BorderRadius.circular(MySize.size5!),
              ),
              child: Text(
              "Comment",
              style: TextStyle(color: Styles.primaryColor, fontSize: MySize.size12!),
              ),
            ),
          ) : null,
        ),
      ),
    );
  }

  InputDecoration getTextFieldInputDecoration({required String hintText, required Color fillColor}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        letterSpacing: 0.1,
        color: Styles.primaryColor,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: fillColor,
      isDense: true,
      contentPadding: const EdgeInsets.all(15),
    );
  }
}
