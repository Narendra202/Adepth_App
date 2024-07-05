// import 'dart:js_interop';

import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/location_form.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/location_list.dart';
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

class Locations extends StatefulWidget {
  const Locations({super.key});

  @override
  State<Locations> createState() => _LocationsState();
}

class _LocationsState extends State<Locations> {
  late List locationList = [];
  bool _isLoading = false;
  String title = "Area ";
  var data;
  late String expeditionId, areaId;
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
    areaId = arguments["areaId"];
    initialize(areaId);

  }

  initialize(areaId) async {
    setState(() {
      _isLoading = true;
    });
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.locationList + areaId);
    setState(() {
      _isLoading = false;
      locationList.clear();
      title = response["area"];
      data = response;
      locationList.addAll(response["data"]);
    });


  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final arguments = ModalRoute.of(context)!.settings.arguments;
  //   expeditionId = (arguments as Map)["expeditionId"];
  //   areaId = arguments["areaId"];
  //   initialize(areaId);
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
                backgroundColor: primaryColor,
                iconTheme: IconThemeData(color: Colors.white),
                title: Text(title,style: TextStyle(color: Colors.white),),
                actions: [
                  IconButton(
                      icon: isOpen ? const Icon(Icons.keyboard_arrow_up_outlined) : const Icon(Icons.keyboard_arrow_down_outlined),
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
                  preferredSize: Size.fromHeight(isOpen ? 40 : 0),
                  child: isOpen && data != null
                      ? serviceDetailsCard()
                      : Container(),
                )),
            body: Column(
              children: [
                Expanded(
                  child: LocationList(
                      locationList: locationList,
                      initCall: initialize,
                      showConfirmationDialog: showConfirmationDialog,
                      editformData: (value){
                        for(int i = 0; i< locationList.length; i++) {
                          if(locationList[i]['_key'] == value['_key']) {
                            locationList[i] = value;
                          }
                        }
                      },
                  ),
                ),
                const SizedBox(
                  height: 25,
                )
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

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
                            child: LocationForm(
                              arguments: {
                                 "areaId": areaId,
                                 "expeditionId": expeditionId,
                              },
                              formData: (value){
                                formData = value;
                                locationList.add(formData);
                                finish(context);
                              },

                            )
                        ),
                      );
                    }
                );


                // Navigator.pushNamed(context, AppPaths.locationForm,
                //                   arguments: {
                //                     "areaId": areaId,
                //                     "expeditionId": expeditionId
                //                   }).then((value) => {initialize(areaId)});
              },
            ),
            // floatingActionButton: AddFloatingButton(
            //     event: () => {
            //           Navigator.pushNamed(context, AppPaths.locationForm,
            //               arguments: {
            //                 "areaId": areaId,
            //                 "expeditionId": expeditionId
            //               }).then((value) => {initialize(areaId)})
            //         })
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

  Widget serviceDetailsCard() {
    return Container(
      margin: const EdgeInsets.only(left: 15, right: 5, bottom: 5),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            ReadOnlyField(title: 'Expedition', value: data["expedition"], color: Colors.white)
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
      await ApiProvider()
          .post(AppConsts.baseURL + AppConsts.deleteLocation, obj);

      setState(() {
        locationList.removeWhere((element) => element["_key"] == key);
        _isLoading = false;
      });
    }
  }
}
