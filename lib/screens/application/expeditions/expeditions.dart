import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/expeditions_list.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/widgets/add_floatingButton.dart';
import 'package:expedition_poc/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Expeditions extends StatefulWidget {
  const Expeditions({Key? key}) : super(key: key);

  @override
  State<Expeditions> createState() => _ExpeditionsState();
}

class _ExpeditionsState extends State<Expeditions> {
  late List expeditionsList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initialize();
    print(expeditionsList);
  }

  initialize() async {
    // const storage = FlutterSecureStorage();
    // await storage.write(key: "userId", value: "41112113");
    setState(() {
      _isLoading = true;
    });
    final response =
        await ApiProvider().get(AppConsts.baseURL + AppConsts.expeditionsList);
    setState(() {
      _isLoading = false;
    });

    setState(() {
      expeditionsList.clear();
      expeditionsList.addAll(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: ExpeditionsList(
              expeditionsList: expeditionsList,
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: AddFloatingButton(
              event: () => {
                    Navigator.pushNamed(context, AppPaths.expeditionForm)
                        .then((value) => {initialize()})
                  }),
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
      final obj = {"key": key, "id": DELETE_TYPE.EXPEDITION.index.toString()};

      // save to db
      await ApiProvider().post(AppConsts.baseURL + AppConsts.softDelete, obj);

      setState(() {
        expeditionsList.removeWhere((element) => element["_key"] == key);
        _isLoading = false;
      });
    }
  }
}
