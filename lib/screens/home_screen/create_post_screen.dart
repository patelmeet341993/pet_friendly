import 'package:flutter/material.dart';
import 'package:pet_friendly/screens/common/components/app_bar.dart';
import 'package:pet_friendly/utils/styles.dart';

class CreatePostScreen extends StatefulWidget {
  static const String routeName = "/CreatePostScreen";

  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Styles.background,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Styles.background,
          body: Column(
            children: [
              MyAppBar(title: "Create Post", backbtnVisible: true,),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      getImageSelectionListWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getImageSelectionListWidget() {
    return Container();
  }
}
