import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/dive_form.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/dive_list.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/utils/AppButtonCirculer.dart';
import 'package:expedition_poc/utils/colors.dart';
import 'package:expedition_poc/widgets/add_floatingButton.dart';
import 'package:expedition_poc/widgets/confirmation_dialog.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class Dives extends StatefulWidget {
  const Dives({super.key});

  @override
  State<Dives> createState() => _DivesState();
}

class _DivesState extends State<Dives> {
  late List divesList = [];
  bool _isLoading = false;
  String title = "Location ";
  var data;
  late String areaId, expeditionId, locationId;
  bool isOpen = false;
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
    areaId = (arguments)["areaId"];
    locationId = (arguments)["locationId"];
    initialize(locationId);
  }

  initialize(locationId) async {
    setState(() {
      _isLoading = true;
    });
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.diveList + locationId);
    setState(() {
      _isLoading = false;
    });
    setState(() {
      divesList.clear();
      title = response["location"];
      data = response;
      divesList.addAll(response["data"]);
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final arguments = ModalRoute.of(context)!.settings.arguments;
  //   expeditionId = (arguments as Map)["expeditionId"];
  //   areaId = (arguments)["areaId"];
  //   locationId = (arguments)["locationId"];
  //   initialize(locationId);
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          // Pass a result back to the parent screen
          Navigator.pop(context, true);

          // Return true to allow the user to navigate back
          return Future.value(true);
        },
        child: Stack(
          children: [
            Scaffold(
                appBar: AppBar(
                    backgroundColor: primaryColor,
                    centerTitle: true,
                    iconTheme: IconThemeData(color: Colors.white),
                    title: Text(title, style: TextStyle(color: Colors.white),),
                    actions: <Widget>[
                      IconButton(
                          icon: isOpen
                              ? const Icon(Icons.keyboard_arrow_up_outlined)
                              : const Icon(Icons.keyboard_arrow_down_outlined),
                          onPressed: () {
                            setState(() {
                              isOpen = !isOpen;
                            });
                          }),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(Icons.home),
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppPaths.home,
                              (route) => false,
                            );
                          },
                        ),
                      )
                    ],
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(isOpen ? 60 : 0),
                      child: isOpen && data != null
                          ? serviceDetailsCard()
                          : Container(),
                    )),
                body: Column(
                  children: [
                    Expanded(
                      child: DiveList(
                          diveList: divesList,
                          initCall: initialize,
                          showConfirmationDialog: showConfirmationDialog),
                    ),
                    // const SizedBox(
                    //   height: 50,
                    // )
                  ],
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
                floatingActionButton: AppCircleButton(
                  icon: Icons.add,
                  onPressed: (){

                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return  AlertDialog(
                            contentPadding: EdgeInsets.zero,
                            content: Container(
                                width: MediaQuery.of(context).size.width,
                                child: DiveForm(
                                  arguments: {
                                    "areaId": areaId,
                                    "expeditionId": expeditionId,
                                    "locationId": locationId,
                                  },
                            ),
                          ));
                        }
                    ).then((value) => {initialize(locationId)});

                    // Navigator.pushNamed(context, AppPaths.diveForm,
                    //                   arguments: {
                    //                     "areaId": areaId,
                    //                     "expeditionId": expeditionId,
                    //                     "locationId": locationId,
                    //                   }).then((value) => {initialize(locationId)});
                  }
                ) ),
                // floatingActionButton: AddFloatingButton(
                //     event: () => {
                //           Navigator.pushNamed(context, AppPaths.diveForm,
                //               arguments: {
                //                 "areaId": areaId,
                //                 "expeditionId": expeditionId,
                //                 "locationId": locationId,
                //               }).then((value) => {initialize(locationId)})
                //         })
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
        ));
  }

  Widget serviceDetailsCard() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 5, bottom: 5),
      child:  Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              const SizedBox(
                height: 5,
              ),
              ReadOnlyField(title: 'Expedition', value: data["expedition"], color: Colors.white),
              ReadOnlyField(title: 'Area', value: data["area"], color: Colors.white)
            ],
          ),
        ),
    );
  }

  showConfirmationDialog(String name, String key) async {
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
      final obj = {"key": key};

      // save to db
      await ApiProvider().post(AppConsts.baseURL + AppConsts.deleteDive, obj);

      setState(() {
        divesList.removeWhere((element) => element["_key"] == key);
        _isLoading = false;
      });
    }
  }
}
