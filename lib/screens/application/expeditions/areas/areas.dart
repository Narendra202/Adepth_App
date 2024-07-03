import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/area_form.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/area_list.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/utils/AppButtonCirculer.dart';
import 'package:expedition_poc/utils/colors.dart';
import 'package:expedition_poc/widgets/add_floatingButton.dart';
import 'package:expedition_poc/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';

class Areas extends StatefulWidget {
  const Areas({super.key});

  @override
  State<Areas> createState() => _AreasState();
}

class _AreasState extends State<Areas> {
  late List areaList = [];
  bool _isLoading = false;
  String title = "Area";
  var data;
  late String expeditionId;

  @override
  void initState() {
    super.initState();
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
        .get(AppConsts.baseURL + AppConsts.areaList + expeditionId);
    setState(() {
      _isLoading = false;
    });

    setState(() {
      areaList.clear();
      title = response["expedition"];
      data = response;
      areaList.addAll(response["data"]);
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
                iconTheme: const IconThemeData(color: Colors.white),
                centerTitle: true,
                title: Text(title, style: TextStyle(color: Colors.white),),
                actions: <Widget>[
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
            ]),
            body: AreaList(
                areaList: areaList,
                initCall: initialize,
                showConfirmationDialog: showConfirmationDialog),
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
                            child: AreaForm(arguments: {"expeditionId": expeditionId},)
                        ),
                      );
                    }
                ).then((value) => {initialize(expeditionId)});

                // Navigator.pushNamed(context, AppPaths.areaForm,
                //                       arguments: {"expeditionId": expeditionId})
                //                   .then((value) => {initialize(expeditionId)});
              },
            ),
            // floatingActionButton: AddFloatingButton(
            //     event: () => {
            //           Navigator.pushNamed(context, AppPaths.areaForm,
            //                   arguments: {"expeditionId": expeditionId})
            //               .then((value) => {initialize(expeditionId)})
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
      await ApiProvider().post(AppConsts.baseURL + AppConsts.deleteArea, obj);

      setState(() {
        areaList.removeWhere((element) => element["_key"] == key);
        _isLoading = false;
      });
    }
  }
}
