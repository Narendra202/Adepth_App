import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/samples/sample_list.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/utils/AppButtonCirculer.dart';
import 'package:expedition_poc/utils/colors.dart';
import 'package:expedition_poc/widgets/add_floatingButton.dart';
import 'package:expedition_poc/widgets/confirmation_dialog.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/material.dart';

class Samples extends StatefulWidget {
  const Samples({super.key});

  @override
  State<Samples> createState() => _SamplesState();
}

class _SamplesState extends State<Samples> {
  late List samplesList = [];
  bool _isLoading = false;
  String title = "Dive";
  var data;
  late String areaId, expeditionId, diveId, locationId;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Code to execute after the build is complete
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    setState(() {
      diveId = (arguments)["diveId"];
    });
    expeditionId = (arguments)["expeditionId"];
    areaId = (arguments)["areaId"];
    locationId = (arguments)["locationId"];
    if (diveId.isEmpty) {
      initializeForLocation(locationId);
    } else {
      initialize(diveId);
    }
  }


  initialize(diveId) async {
    setState(() {
      _isLoading = true;
    });
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.sampleList + diveId);
    setState(() {
      _isLoading = false;
    });
    setState(() {
      samplesList.clear();
      title = response["dive"];
      data = response;
      samplesList.addAll(response["data"]);
    });
  }

  // init for ongoing location, get all dive samples
  initializeForLocation(locationId) async {
    setState(() {
      _isLoading = true;
    });
    final response = await ApiProvider().get(
        AppConsts.baseURL + AppConsts.sampleListOngoingLocation + locationId);
    setState(() {
      _isLoading = false;
    });
    if (response == null) return;
    setState(() {
      samplesList.clear();
      title = response["location"];
      data = response;
      samplesList.addAll(response["data"]);
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final arguments = ModalRoute.of(context)!.settings.arguments as Map;
  //   setState(() {
  //     diveId = (arguments)["diveId"];
  //   });
  //   expeditionId = (arguments)["expeditionId"];
  //   areaId = (arguments)["areaId"];
  //   locationId = (arguments)["locationId"];
  //   if (diveId.isEmpty) {
  //     initializeForLocation(locationId);
  //   } else {
  //     initialize(diveId);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
                backgroundColor: primaryColor,
                iconTheme: const IconThemeData(color: Colors.white),
                centerTitle: true,
                title: Text(title,style: TextStyle(color: Colors.white),),
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
                  preferredSize: Size.fromHeight(isOpen ? 70 : 0),
                  child: isOpen && data != null
                      ? serviceDetailsCard()
                      : Container(),
                )),
            body: Column(
              children: [
                Expanded(
                  child: SampleList(
                      sampleList: samplesList,
                      // ignore: unnecessary_null_comparison
                      showAllOngoing: diveId.isEmpty ? true : false,
                      initCall:
                          // ignore: unnecessary_null_comparison
                          diveId.isEmpty ? initializeForLocation : initialize,
                      showConfirmationDialog: showConfirmationDialog),
                ),
                // const SizedBox(
                //   height: 50,
                // )
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: Visibility(
              visible:
              // ignore: unnecessary_null_comparison
              diveId.isNotEmpty,
              child: AppCircleButton(
                  icon: Icons.add,
                  onPressed: () => {
                            Navigator.pushNamed(context, AppPaths.sampleForm,
                                arguments: {
                                  "areaId": areaId,
                                  "expeditionId": expeditionId,
                                  "locationId": locationId,
                                  "diveId": diveId
                                }).then((value) => {initialize(diveId)})
                          }),
            )
            // floatingActionButton: Visibility(
            //   visible:
            //       // ignore: unnecessary_null_comparison
            //       diveId.isNotEmpty,
            //   child: AddFloatingButton(
            //       event: () => {
            //             Navigator.pushNamed(context, AppPaths.sampleForm,
            //                 arguments: {
            //                   "areaId": areaId,
            //                   "expeditionId": expeditionId,
            //                   "locationId": locationId,
            //                   "diveId": diveId
            //                 }).then((value) => {initialize(diveId)})
            //           }),
            // )
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
            ReadOnlyField(title: 'Expedition', value: data["expedition"], color: Colors.white),
            ReadOnlyField(title: 'Area', value: data["area"], color: Colors.white),
            ReadOnlyField(title: 'Location', value: data["location"], color: Colors.white)
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
      await ApiProvider().post(AppConsts.baseURL + AppConsts.deleteSample, obj);

      setState(() {
        samplesList.removeWhere((element) => element["_key"] == key);
        _isLoading = false;
      });
    }
  }
}
