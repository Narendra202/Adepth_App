
import 'package:expedition_poc/utils/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:expedition_poc/utils/colors.dart';

import 'package:expedition_poc/utils/App_Images_Path.dart';




class T2Drawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return T2DrawerState();
  }
}

class T2DrawerState extends State<T2Drawer> {
  var selectedItem = -1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width() * 0.85,
      height: context.height(),
      child:
      Drawer(
          elevation: 8,
          child: Container(
            color: context.scaffoldBackgroundColor,
            child: SingleChildScrollView(
              child: Container(
                width: context.width(),
                color: context.scaffoldBackgroundColor,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 70, right: 20),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
                        decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.only(bottomRight: Radius.circular(24.0), topRight: Radius.circular(24.0))),
                        /*User Profile*/
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                               backgroundImage: AssetImage(login2,),
                                radius: 40
                            ),
                                // backgroundImage: NetworkImage(t2_profile), radius: 40),
                            SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text('hello',),
                                    SizedBox(height: 8),
                                    Text('email',),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text('Share')
                    // getDrawerItem(t2_user, t2_lbl_profile, 1),
                    // getDrawerItem(t2_chat, t2_lbl_message, 2),
                    // getDrawerItem(t2_report, t2_lbl_report, 3),
                    // getDrawerItem(t2_settings, t2_lbl_settings, 4),
                    // getDrawerItem(t2_logout, t2_lbl_sign_out, 5),
                    // SizedBox(height: 30),
                    // Divider(color: t2_view_color, height: 1),
                    // SizedBox(height: 30),
                    // getDrawerItem(t2_share, t2_lbl_share_and_invite, 6),
                    // getDrawerItem(t2_help, t2_lbl_help_and_feedback, 7),
                    // SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

      ),
    );
  }

  // Widget getDrawerItem(String icon, String name, int pos) {
  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         selectedItem = pos;
  //       });
  //     },
  //     child: Container(
  //       color: selectedItem == pos ? t2_colorPrimaryLight : context.scaffoldBackgroundColor,
  //       padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
  //       child: Row(
  //         children: <Widget>[
  //           SvgPicture.asset(icon, width: 20, height: 20, color: appStore.iconColor),
  //           SizedBox(width: 20),
  //           Text(name, style: primaryTextStyle(color: selectedItem == pos ? t2_colorPrimary : appStore.textPrimaryColor, size: 18))
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
