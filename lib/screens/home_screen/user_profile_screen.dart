import 'package:flutter/material.dart';
import 'package:pet_friendly/controllers/authentication_controller.dart';
import 'package:pet_friendly/screens/common/components/MyCupertinoAlertDialogWidget.dart';
import 'package:pet_friendly/screens/common/components/modal_progress_hud.dart';
import 'package:pet_friendly/utils/SizeConfig.dart';
import 'package:pet_friendly/utils/my_print.dart';
import 'package:pet_friendly/utils/styles.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        body: Center(
          child: singleOption1(
              iconData: Icons.logout,
              option: "Logout",
              ontap: () async {
                MyPrint.printOnConsole("logout");
                setState(() {
                  isLoading = true;
                });
                bool? isLogout = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return MyCupertinoAlertDialogWidget(
                      title: "Logout",
                      description: "Are you sure want to logout?",
                      negativeCallback: () {
                        Navigator.pop(context, false);
                      },
                      positiviCallback: () {
                        Navigator.pop(context, true);
                      },
                    );
                  },
                );

                if(isLogout != null && isLogout) await AuthenticationController().logout(context);
                setState(() {
                  isLoading = false;
                });
              }
          ),
        ),
      ),
    );
  }

  Widget singleOption1({required IconData iconData, required String option, Function? ontap}) {
    return InkWell(
      onTap: ()async {
        if(ontap != null) ontap();
      },
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: MySize.size10!),
        decoration: BoxDecoration(
          color: Styles.bottomAppbarColor,
          borderRadius: BorderRadius.circular(MySize.size10!),
        ),
        padding: EdgeInsets.symmetric(vertical: MySize.size16!, horizontal: MySize.size10!),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Icon(
                iconData,
                size: MySize.size22,
                color: Styles.onBackground,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: MySize.size16!),
                child: Text(option,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Container(
              child: Icon(Icons.arrow_forward_ios_rounded,
                size: MySize.size22,
                color: Styles.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
