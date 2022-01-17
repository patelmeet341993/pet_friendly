import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pet_friendly/controllers/post_controller.dart';
import 'package:pet_friendly/controllers/providers/user_provider.dart';
import 'package:pet_friendly/models/post_model.dart';
import 'package:pet_friendly/screens/home_screen/comments_screen.dart';
import 'package:pet_friendly/utils/SizeConfig.dart';
import 'package:pet_friendly/utils/my_print.dart';
import 'package:pet_friendly/utils/styles.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

class PostWidget extends StatefulWidget {
  PostModel postModel;
  PostWidget({Key? key, required this.postModel}) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLiked = false;

  Future<void> likePost() async {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    bool isSuccess = await PostController().likeUnlikePost(widget.postModel, userProvider.userModel!, isLike: !userProvider.userModel!.myLikedPosts.contains(widget.postModel.id));
    MyPrint.printOnConsole("Is Like Success:${isSuccess}");
    MyPrint.printOnConsole("Post Like:${widget.postModel.likesCount}");
    MyPrint.printOnConsole("User MyLikes:${userProvider.userModel!.myLikedPosts}");
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: MySize.size3!, horizontal: MySize.size5!),
      padding: EdgeInsets.symmetric(horizontal: MySize.size10!),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(MySize.size5!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getHeader(widget.postModel),
          getDescription(widget.postModel.description),
          getImagesSlider(widget.postModel.images),
          getButtonRow(),
        ],
      ),
    );
  }

  Widget getHeader(PostModel postModel) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: MySize.size5!),
      child: Row(
        children: [
          Container(
            height: MySize.size30!,
            width: MySize.size30!,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(MySize.size100!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MySize.size100!),
              child: postModel.createdByImage.isNotEmpty ? CachedNetworkImage(
                imageUrl: postModel.createdByImage,
                fit: BoxFit.cover,
                placeholder: (_, __) {
                  return const SpinKitFadingCircle(color: Styles.primaryColor,);
                },
                errorWidget: (_, __, ___) {
                  return const Center(child: Icon(Icons.info, color: Styles.primaryColor,),);
                },
              ) : Image.asset("assets/male profile vector.png", fit: BoxFit.cover,),
            ),
          ),
          SizedBox(width: MySize.size10!,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  postModel.createdByName,
                  style: TextStyle(
                    color: Styles.primaryColor,
                    fontSize: MySize.size16!
                  ),
                ),
                Text(
                  postModel.type,
                  style: TextStyle(
                      color: Styles.primaryColor,
                      fontSize: MySize.size12!
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getDescription(String description) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: MySize.size5!),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(description),
    );
  }

  Widget getImagesSlider(List<String> list) {
    //MyPrint.printOnConsole("Iages:${list}");
    if(list.isEmpty) return const SizedBox();

    return Container(
      margin: EdgeInsets.symmetric(vertical: MySize.size5!),
      child: AspectRatio(
        aspectRatio: 1,
        child: PhotoViewGallery(
          gaplessPlayback: true,
          pageOptions: List.generate(list.length, (index) {
            String imageUrl = list[index];
            return PhotoViewGalleryPageOptions(
              filterQuality: FilterQuality.high,
              imageProvider: CachedNetworkImageProvider(imageUrl),
              initialScale: PhotoViewComputedScale.contained * 1,
              minScale: PhotoViewComputedScale.contained * 1,
              maxScale: PhotoViewComputedScale.contained * 5,

            );
          }),
          loadingBuilder: (context, event) {
            return const Center(child: SpinKitFadingCircle(color: Styles.primaryColor,),);
          },
        ),
      ),
    );
  }

  Widget getButtonRow() {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: MySize.size5!),
      child: Row(
        children: [
          Expanded(
            child: getButton(
              count: widget.postModel.likesCount,
              iconData: (userProvider.userModel?.myLikedPosts.contains(widget.postModel.id) ?? false) ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
              text: "Like",
              onTap: () {
                likePost();
              }
            ),
          ),
          Expanded(
            child: getButton(
              count: widget.postModel.comments.length,
              iconData: Icons.message,
              text: "Comments",
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => CommentsScreen(postModel: widget.postModel)));
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getButton({required int count, required IconData iconData, required String text, required Function onTap}) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(MySize.size5!),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
            SizedBox(width: MySize.size5!,),
            Icon(iconData, color: Styles.primaryColor, size: MySize.size22!,),
            SizedBox(width: MySize.size5!,),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: MySize.size12!,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
