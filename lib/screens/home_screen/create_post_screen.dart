import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_friendly/controllers/data_controller.dart';
import 'package:pet_friendly/controllers/firestore_controller.dart';
import 'package:pet_friendly/controllers/post_controller.dart';
import 'package:pet_friendly/controllers/providers/user_provider.dart';
import 'package:pet_friendly/models/post_model.dart';
import 'package:pet_friendly/screens/common/components/app_bar.dart';
import 'package:pet_friendly/screens/common/components/modal_progress_hud.dart';
import 'package:pet_friendly/utils/SizeConfig.dart';
import 'package:pet_friendly/utils/my_print.dart';
import 'package:pet_friendly/utils/snakbar.dart';
import 'package:pet_friendly/utils/styles.dart';
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  static const String routeName = "/CreatePostScreen";

  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final picker = ImagePicker();

  bool isLoading = false;

  List<File> images = [];
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController descriptionController = TextEditingController();
  List<String> types = [
    "Pet Food", "Pet Adoption", "Pet Donation", "Pet Surgery", "Pet Help"
  ];
  String? selectedType;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery,);
    print("Picked File: ${pickedFile}");

    if(pickedFile != null) {
      File? newImage = await ImageCropper.cropImage(
        compressQuality: 70,
        compressFormat: ImageCompressFormat.jpg,
        sourcePath: pickedFile.path,
        cropStyle: CropStyle.rectangle,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: const AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.red,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        iosUiSettings: const IOSUiSettings(
          minimumAspectRatio: 1.0,
          aspectRatioLockEnabled: true,
        ),
      );

      setState(() {
        if(newImage == null) {
          print("image file null");
        }
        else {
          print("image file not null");
          images.add(File(newImage.path));
        }
      });
    }
  }

  Future<List<String>> uploadImages({required String postId, required List<File> images}) async {
    List<String> downloadUrls = [];

    await Future.wait(images.map((File file) async {
      Uint8List bytes = file.readAsBytesSync();

      String fileName = file.path.substring(file.path.lastIndexOf("/") + 1);
      Reference reference = FirebaseStorage.instance.ref().child("posts").child(postId).child(fileName);
      UploadTask uploadTask = reference.putData(bytes);
      TaskSnapshot storageTaskSnapshot;

      TaskSnapshot snapshot = await uploadTask.then((TaskSnapshot snapshot) => snapshot);
      if (snapshot.state == TaskState.success) {
        storageTaskSnapshot = snapshot;
        final String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);

        print('$fileName Upload success, url:${downloadUrl}');
      }
      else {
        print('Error from image repo uploading $fileName: ${snapshot.toString()}');
        //throw ('This file is not an image');
      }
    }),
        eagerError: true, cleanUp: (_) {
          print('eager cleaned up');
        });

    return downloadUrls;
  }

  Future<void> createPost() async {
    setState(() {
      isLoading = true;
    });

    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    String newId = await DataController().getNewDocId();

    List<String> imageUrls = await uploadImages(postId: newId, images: images);

    PostModel postModel = PostModel();
    postModel.id = newId;
    postModel.description = descriptionController.text;
    postModel.type = selectedType ?? "";
    postModel.images = imageUrls;
    postModel.createdById = userProvider.userModel?.id ?? "";
    postModel.createdByName = userProvider.userModel?.name ?? "";
    postModel.createdByImage = userProvider.userModel?.image ?? "";

    Map<String, dynamic> data = postModel.tomap();
    data['createdTime'] = FieldValue.serverTimestamp();

    bool isSuccess = await FirestoreController().firestore.collection("posts").doc(postModel.id).set(data).then((value) {
      MyPrint.printOnConsole("Post Created");
      return true;
    })
    .catchError((e) {
      MyPrint.printOnConsole("Error in Creating Post:${e}");
      return false;
    });

    setState(() {
      isLoading = false;
    });

    if(isSuccess) {
      PostController().getPosts(context);
      Navigator.pop(context);
    }
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
                  MyAppBar(title: "Create Post", backbtnVisible: true, color: Colors.white,),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            getImageSelectionListWidget(),
                            getDescriptionTextField(),
                            getTypeDropdown(),
                            getCreatePostButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //Main UI Components
  Widget getImageSelectionListWidget() {
    int length = images.length + 1;
    return Container(
      margin: EdgeInsets.only(top: MySize.size10!),
      height: MySize.size100!,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            length,
            (index) {
              if(index == length - 1) {
                if(images.length < 5) {
                  return getBlankAddImageButton(() {
                    getImage();
                  });
                }
                else {
                  return const SizedBox();
                }
              }

              return Container(margin: EdgeInsets.symmetric(horizontal: MySize.size10!), child: getImageButton(images[index]));
            },
          ),
        ),
      ),
    );
  }

  Widget getDescriptionTextField() {
    return Container(
      margin: EdgeInsets.only(top: MySize.size10!),
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MySize.size10!),
      ),
      child: TextFormField(
        controller: descriptionController,
        validator: (val) => (val?.isNotEmpty ?? false) ? null : "*required",
        decoration: InputDecoration(
          hintText: "Description",
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MySize.size5!),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MySize.size5!),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MySize.size5!),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
        ),
        cursorColor: Colors.white,
        textCapitalization: TextCapitalization.sentences,
        minLines: 5,
        maxLines: 10,
      ),
    );
  }

  Widget getTypeDropdown() {
    return Container(
      margin: EdgeInsets.only(top: MySize.size10!),
      child: DropdownButton<String>(
        onChanged: (String? value) {
          selectedType = value;
          setState(() {});
        },
        value: selectedType,
        hint: const Text("Select Post Type"),
        items: types.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
      ),
    );
  }

  Widget getCreatePostButton() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(const Radius.circular(8)),
      ),
      child: FlatButton(
        onPressed: () async {
          if(_formKey.currentState!.validate() && selectedType != null && images.isNotEmpty) {
            print("Valid Fields");

            await createPost();
            /*for(int i = 10; i < 20; i++) {
              nameController.text = "Name${i+1}";
              descriptionController.text = "Description${i+1}";
              print(i);
              await addProduct();
            }*/
          }
          else {
            print("Invalid Fields");

            if(selectedType == null) {
              Snakbar().showErrorSnakbar(context: context, error_message: "Select Post Type");
            }
            else if(images.isEmpty) {
              Snakbar().showErrorSnakbar(context: context, error_message: "Images Cannot Be Empty");
            }
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        color: Styles.primaryColor,
        splashColor: Colors.white.withAlpha(150),
        highlightColor: Styles.primaryColor,
        padding: const EdgeInsets.only(
            left: 24, right: 24),
        child: const Text(
          "Create Post",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }


  //Supporting UI Components
  Widget getBlankAddImageButton(Function ontap) {
    return InkWell(
      onTap: () {
        ontap();
      },
      child: Container(
        height: MySize.size100!,
        width: MySize.size100!,
        margin: const EdgeInsets.only(left: 5),
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Color(0xffe0e0e0),
          borderRadius:
          const BorderRadius.all(Radius.circular(16.0)),
        ),
        child: const Center(child: Icon(Icons.add, color: Styles.primaryColor,)),
      ),
    );
  }

  Widget getImageButton(File file) {
    return Stack(
        children: [
          Container(
            height: 100,
            width: 100,
            margin: const EdgeInsets.only(left: 5),
            padding: const EdgeInsets.all(5),
            child: Center(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                child:Image.file(file),
                //Image.network(category.img)
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () {
                setState(() {
                  images.remove(file);
                });
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Styles.primaryColor,
                ),
                child: const Icon(Icons.close, size: 13, color: Colors.white,),
              ),
            ),
          ),
        ]
    );
  }
}
