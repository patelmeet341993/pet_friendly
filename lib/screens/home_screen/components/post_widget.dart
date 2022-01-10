import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pet_friendly/controllers/providers/user_provider.dart';
import 'package:pet_friendly/models/post_model.dart';
import 'package:pet_friendly/utils/SizeConfig.dart';
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
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
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
      child: Row(
        children: [
          Container(
            height: MySize.size50!,
            width: MySize.size50!,
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
          Expanded(
            child: Column(
              children: [
                Text(postModel.createdByName),
                Text(postModel.type),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getDescription(String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(description),
    );
  }

  Widget getImagesSlider(List<String> list) {
    return AspectRatio(
      aspectRatio: 9 / 16,
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
    );
  }

  Widget getButtonRow() {
    UserProvider userProvider = Provider.of<UserProvider>(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: MySize.size5!, vertical: MySize.size5!),
      child: Row(
        children: [
          Expanded(
            child: getButton(
              (userProvider.userModel?.myLikedPosts.contains(widget.postModel.id) ?? false) ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
              "Like",
              () {

              }
            ),
          ),
          Expanded(
            child: getButton(
                (userProvider.userModel?.myLikedPosts.contains(widget.postModel.id) ?? false) ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                "Comment",
                () {

                }
            ),
          ),
        ],
      ),
    );
  }

  Widget getButton(IconData iconData, String text, Function onTap) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(MySize.size5!),
        child: Column(
          children: [
            Icon(iconData, color: Styles.primaryColor,),
            SizedBox(height: MySize.size3!,),
            Text(text),
          ],
        ),
      ),
    );
  }
}
