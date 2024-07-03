import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/data/data_form.dart';
import 'package:expedition_poc/screens/application/expeditions/data/data_list.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/widgets/add_floatingButton.dart';
import 'package:expedition_poc/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../utils/AppButtonCirculer.dart';

class Data extends StatefulWidget {
  const Data({super.key});

  @override
  State<Data> createState() => _DataState();
}

class _DataState extends State<Data> {
  late List dataList = [];
  bool _isLoading = false;
  String title = "Data";
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
        .get(AppConsts.baseURL + AppConsts.dataList + expeditionId);
    setState(() {
      _isLoading = false;
    });

    setState(() {
      dataList.clear();
      title = response["expedition"];
      data = response;
      dataList.addAll(response["data"]);
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
            centerTitle: true,
            title: Text(title),
          ),
          body: DataList(
              dataList: dataList,
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog,
              editformData: (value) {
                for(int i = 0; i < dataList.length; i++) {
                  if(dataList[i]['_key'] == value['_key']) {
                    dataList[i] = value;
                  }
                }
              },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: AppCircleButton(
            icon: Icons.add,
            onPressed: (){

              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      contentPadding: EdgeInsets.zero,
                      content: Container(
                        width: MediaQuery.of(context).size.width,
                        child: DataForm(
                          arguments: {"expeditionId": expeditionId},
                          formData: (value){
                            formData = value;
                            dataList.add(formData);
                            finish(context);
                          },
                          // formData: (value){
                          //   formData = value;
                          //   toolList.add(formData);
                          //   finish(context);
                          // },
                        ),
                      ),
                    );
                  });

              // Navigator.pushNamed(context, AppPaths.dataForm,
              //                       arguments: {"expeditionId": expeditionId})
              //                   .then((value) => {initialize(expeditionId)});
            },
          ),
          // floatingActionButton: AddFloatingButton(
          //     event: () => {
          //           Navigator.pushNamed(context, AppPaths.dataForm,
          //                   arguments: {"expeditionId": expeditionId})
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

  navigateToForm(item) {
    return () => {
          Navigator.pushNamed(context, AppPaths.dataForm, arguments: {
            "dataId": item['_key'],
            "expeditionId": item["expeditionId"]
          }).then((value) => {initialize(expeditionId)})
        };
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
        dataList.removeWhere((element) => element["_key"] == key);
        _isLoading = false;
      });
    }
  }
}
