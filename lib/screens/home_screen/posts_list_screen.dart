import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pet_friendly/controllers/post_controller.dart';
import 'package:pet_friendly/models/post_model.dart';
import 'package:pet_friendly/screens/common/components/app_bar.dart';
import 'package:pet_friendly/screens/home_screen/components/post_widget.dart';
import 'package:pet_friendly/utils/SizeConfig.dart';
import 'package:pet_friendly/utils/styles.dart';

class PostsListScreen extends StatefulWidget {
  const PostsListScreen({Key? key}) : super(key: key);

  @override
  _PostsListScreenState createState() => _PostsListScreenState();
}

class _PostsListScreenState extends State<PostsListScreen> {
  bool isFirst = true;

  late Future<List<PostModel>> futurePosts;

  @override
  Widget build(BuildContext context) {
    if(isFirst) {
      isFirst = false;
      futurePosts = PostController().getPosts(context);
    }

    return Container(
      color: Styles.background,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Styles.background,
          body: Column(
            children: [
              MyAppBar(title: "Pet Friendly", backbtnVisible: false, color: Colors.white, rightrow: getRefreshButton(),),
              Expanded(
                child: FutureBuilder<List<PostModel>>(
                  future: futurePosts,
                  builder: (BuildContext context, AsyncSnapshot<List<PostModel>> snapshot) {
                    if(snapshot.connectionState == ConnectionState.done) {
                      return getPostsListScreen(snapshot.data ?? []);
                    }
                    else {
                      return const Center(child: SpinKitFadingCircle(color: Styles.primaryColor,),);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getPostsListScreen(List<PostModel> posts) {
    if(posts.isEmpty) return const Center(child: Text("No Posts"),);

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        PostModel postModel = posts[index];
        return PostWidget(postModel: postModel);
      },
    );
  }

  Widget getRefreshButton() {
    return InkWell(
      onTap: () {
        futurePosts = PostController().getPosts(context);
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.all(MySize.size10!),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
