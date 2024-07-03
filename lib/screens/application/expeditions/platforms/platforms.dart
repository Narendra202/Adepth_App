import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/platforms/platform_form.dart';
import 'package:expedition_poc/screens/application/expeditions/platforms/platform_list.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/utils/AppButtonCirculer.dart';
import 'package:expedition_poc/utils/colors.dart';
import 'package:expedition_poc/widgets/add_floatingButton.dart';
import 'package:expedition_poc/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class Platforms extends StatefulWidget {
  Platforms({
    super.key,
  });

  @override
  State<Platforms> createState() => _PlatformsState();
}

class _PlatformsState extends State<Platforms> {
  late List platformList = [];
  bool _isLoading = false;
  String title = "Platform";
  var data;
  late String expeditionId = "";

  late Map formData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Code to execute after the build is complete
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final arguments = ModalRoute.of(context)!.settings.arguments;
    expeditionId = (arguments as Map)["expeditionId"];
    initialize(expeditionId);
  }

  initialize(expeditionId) async {
    setState(() {
      _isLoading = true;
    });
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.platformList + expeditionId);
    setState(() {
      _isLoading = false;
    });

    setState(() {
      platformList.clear();
      title = response["expedition"];
      data = response;
      platformList.addAll(response["data"]);
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final arguments = ModalRoute.of(context)!.settings.arguments;
  //   expeditionId = (arguments as Map)["expeditionId"];
  //   initialize(expeditionId);
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
          ),

          body: PlatformList(
              platformList: platformList,
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog,
              editformData: (value) {
                for(int i = 0; i < platformList.length; i++) {
                  if(platformList[i]['_key'] == value['_key']) {
                    platformList[i] = value;
                  }
                }
              }),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: AppCircleButton(
            icon: Icons.add,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      contentPadding: EdgeInsets.zero,
                      content: Container(
                        width: MediaQuery.of(context).size.width,
                        child: PlatformForm(
                          arguments: {"expeditionId": expeditionId},
                          formData: (value) {
                            formData = value;
                            platformList.add(formData);
                            finish(context);
                          },
                        ),
                      ),
                    );
                  });

              // Navigator.pushNamed(context, AppPaths.platformForm,
              //                       arguments: {"expeditionId": expeditionId})
              //                   .then((value) => {initialize(expeditionId)});
            },
          ),
          // floatingActionButton: AddFloatingButton(
          //     event: () => {
          //           Navigator.pushNamed(context, AppPaths.platformForm,
          //                    arguments: {"expeditionId": expeditionId})
          //               .then((value) => {initialize(expeditionId)})
          //         }),
        ),
        if (_isLoading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.grey),
          ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  showConfirmationDialog(String name, String key, String type) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Confirmation',
          message: "Are you sure you want delete $name?",
          confirmText: 'Yes',
          cancelText: 'No',
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      final obj = {"key": key, "id": type};

      // save to db
      await ApiProvider().post(AppConsts.baseURL + AppConsts.softDelete, obj);

      setState(() {
        platformList.removeWhere((element) => element["_key"] == key);
        _isLoading = false;
      });
    }
  }
}
