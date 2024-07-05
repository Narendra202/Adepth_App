import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/samples/analysis/analysis_list.dart';
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

import 'analysis_form.dart';

class Analysis extends StatefulWidget {
  const Analysis({super.key});

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  late List analysisList = [];
  bool _isLoading = false;
  String title = "Sample ";
  var data;
  late String sampleId, areaId, expeditionId, diveId, locationId;
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
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    diveId = (arguments)["diveId"];
    expeditionId = (arguments)["expeditionId"];
    areaId = (arguments)["areaId"];
    sampleId = (arguments)["sampleId"];
    locationId = (arguments)["locationId"];
    initialize(sampleId);
  }



  //
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final arguments = ModalRoute.of(context)!.settings.arguments as Map;
  //   diveId = (arguments)["diveId"];
  //   expeditionId = (arguments)["expeditionId"];
  //   areaId = (arguments)["areaId"];
  //   sampleId = (arguments)["sampleId"];
  //   locationId = (arguments)["locationId"];
  //   initialize(sampleId);
  // }

  initialize(sampleId) async {
    setState(() {
      _isLoading = true;
    });
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.analysisList + sampleId);
    setState(() {
      _isLoading = false;
    });
    setState(() {
      analysisList.clear();
      title = "Sample " + response["sample"];
      data = response;
      analysisList.addAll(response["data"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
              backgroundColor: primaryColor,
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
                  preferredSize: Size.fromHeight(isOpen ? 85 : 0),
                  child: isOpen && data != null
                      ? serviceDetailsCard()
                      : Container(),
                )),
            body: Column(
              children: [
                Expanded(
                  child: AnalysisList(
                      analysisList: analysisList,
                      initCall: initialize,
                      showConfirmationDialog: showConfirmationDialog),
                )
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: AppCircleButton(
              icon: Icons.add,
              onPressed:  () => {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return  AlertDialog(
                          contentPadding: EdgeInsets.zero,
                          content: Container(
                            width: MediaQuery.of(context).size.width,
                            child: AnalysisForm(
                              arguments: {
                                "areaId": areaId,
                                "expeditionId": expeditionId,
                                "diveId": diveId,
                                "locationId": locationId,
                                "sampleId": sampleId
                              },
                            ),
                          ));
                    }
                ).then((value) => {initialize(sampleId)})


                        // Navigator.pushNamed(context, AppPaths.analysisForm,
                        //     arguments: {
                        //       "areaId": areaId,
                        //       "expeditionId": expeditionId,
                        //       "diveId": diveId,
                        //       "locationId": locationId,
                        //       "sampleId": sampleId
                        //     }).then((value) => {initialize(sampleId)})
                      }),
            ),
            // floatingActionButton: AddFloatingButton(
            //     event: () => {
            //           Navigator.pushNamed(context, AppPaths.analysisForm,
            //               arguments: {
            //                 "areaId": areaId,
            //                 "expeditionId": expeditionId,
            //                 "diveId": diveId,
            //                 "locationId": locationId,
            //                 "sampleId": sampleId
            //               }).then((value) => {initialize(sampleId)})
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
            ReadOnlyField(title: 'Location', value: data["location"], color: Colors.white),
            ReadOnlyField(title: 'Dive', value: data["dive"], color: Colors.white)
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
      final obj = {"key": key, "id": DELETE_TYPE.ANALYSIS.index.toString()};

      // save to db
      await ApiProvider().post(AppConsts.baseURL + AppConsts.softDelete, obj);

      setState(() {
        analysisList.removeWhere((element) => element["_key"] == key);
        _isLoading = false;
      });
    }
  }
}
