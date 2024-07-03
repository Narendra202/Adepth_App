import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/utils/context_extension.dart';
import 'package:expedition_poc/screens/tabs/configuration.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/colors.dart';
import 'application/expeditions/expedition_with_list.dart';

class HomePage extends StatefulWidget {
  // const BottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String expeditionId = "", userName = "", userEmail = "";

  late List expeditionsList = [];
  bool _isLoading = false;
  List<String> appbarTitles = ["Home", "Configuration"];

  late List<Widget> _widgetOptions = [];

  initialize() async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await ApiProvider().get(AppConsts.baseURL + AppConsts.expeditionsList);
    setState(() {
      _isLoading = false;
      expeditionsList.clear();
      expeditionsList.addAll(response);
    });

    if (expeditionsList.isNotEmpty) {
      expeditionId = expeditionsList[0]["_key"];
    }
    _widgetOptions = [
      ExpeditionsWithList(
          expeditionsList: expeditionsList, initialize: initialize),
      Configuration(
        expeditionId: expeditionId,
      )
    ];
  }

  init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('userName') ?? "";
    String email = prefs.getString('userEmail') ?? "";
    setState(() {
      userName = name;
      userEmail = email;
    });

    await initialize();
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(appbarTitles.elementAt(_selectedIndex),style: TextStyle(color: Colors.white),),
      ),
      drawer:  Drawer(
              elevation: 8,
              child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 70, right: 10),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: <Color>[
                                  primaryDarkColor,
                                  primaryColor
                                ]),
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(24.0),
                                    topRight: Radius.circular(24.0))),
                            /*User Profile*/
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                    child: Text(
                                      userName.isNotEmpty ? userName
                                          .substring(0, 1) : "",
                                      style: const TextStyle(fontSize: 40.0,
                                          color: primaryColor),),
                                    // backgroundImage: AssetImage(login2,),
                                    radius: 40,
                                ),
                                // backgroundImage: NetworkImage(t2_profile), radius: 40),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: <Widget>[
                                        Text(userName, style:const TextStyle(
                                            color: Colors.white, fontSize: 20,fontWeight: FontWeight.w800)),
                                        const SizedBox(height: 8),
                                        Text(userEmail,
                                            style: const TextStyle(
                                                color: Colors.white,fontSize: 15)),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        // const SizedBox(height: 30),
                        ListView.builder(
                          shrinkWrap: true,
                        itemCount: expeditionsList.length,
                        itemBuilder: (BuildContext context, int index) {


                          final item = expeditionsList[index];

                          // Display the ListTile with the item's title and trailing icon
                          return Column(
                            children: [
                              ListTile(
                                title: Text(item["name"], style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.w600),),
                                trailing: const Icon(Icons.arrow_forward,color: Colors.black,),
                                onTap: () async {
                                  if (item["_key"] != expeditionId) {
                                    final SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString('userId', item["_key"]);
                                    setState(() {
                                      expeditionId = item["_key"];
                                      _widgetOptions[1] =
                                          Configuration(expeditionId: expeditionId);
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                                                ),

                        // ListTile(
                        //   title: const Text('Logout', style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.w600),),
                        //   trailing: const Icon(Icons.logout,color: redColor,),
                        //   onTap: () async {
                        //     // Perform logout action
                        //     final SharedPreferences prefs =
                        //     await SharedPreferences.getInstance();
                        //     await prefs.remove('userId');
                        //     await prefs.remove('userName');
                        //     await prefs.remove('userEmail');
                        //     // Navigator.pop(context); // Close the drawer
                        //     Navigator.pushNamedAndRemoveUntil(context, AppPaths.login, (route) => false);
                        //   },
                        // ),

                        Container(
                          margin: EdgeInsets.only(top: 200),
                          child: ListTile(
                            title: const Text('Logout', style: TextStyle(color: Colors.black, fontSize: 18,fontWeight: FontWeight.w600),),
                            trailing: const Icon(Icons.logout,color: redColor,),
                            onTap: () async {
                              // Perform logout action
                              final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                              await prefs.remove('userId');
                              await prefs.remove('userName');
                              await prefs.remove('userEmail');
                              // Navigator.pop(context); // Close the drawer
                              Navigator.pushNamedAndRemoveUntil(context, AppPaths.login, (route) => false);
                            },
                          ),
                        ),
                                          //
                      ]
                  )
              )
          ),


      body: _widgetOptions.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              gap: 8,
              activeColor: Colors.black,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[100]!,
              color: Colors.black,
              tabs: [
                createGButton(primaryColor, 'Home', Icons.home),
                createGButton(primaryColor, 'Config', Icons.settings),
                // createGButton(ColorUtils.diveBar, 'Dive', Icons.location_pin),
                // createGButton(ColorUtils.dataBar, 'Data',
                //     Icons.data_thresholding_outlined),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  GButton createGButton(Color color, String title, IconData icon) {
    const padding = EdgeInsets.symmetric(horizontal: 18, vertical: 12);
    double gap = 10;
    return GButton(
      gap: gap,
      iconActiveColor: color,
      iconColor: Colors.black,
      textColor: color,
      backgroundColor: color.withOpacity(.1),
      iconSize: 24,
      padding: padding,
      icon: icon,
      text: title,
    );
  }

}
