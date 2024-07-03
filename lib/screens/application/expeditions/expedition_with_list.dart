import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/expeditions_list.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:expedition_poc/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';

import '../../../utils/AppButtonCirculer.dart';
import 'expedition_form.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ExpeditionsWithList extends StatefulWidget {
  List expeditionsList = [];
  Function() initialize;
  ExpeditionsWithList(
      {Key? key, required this.expeditionsList, required this.initialize})
      : super(key: key);

  @override
  State<ExpeditionsWithList> createState() => _ExpeditionsWithListState();
}

class _ExpeditionsWithListState extends State<ExpeditionsWithList> {
  late List expeditionsList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    expeditionsList = widget.expeditionsList;
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            body: Container(
              color: Color(0xfff7fbfb),
              child: ExpeditionsList(
                  expeditionsList: expeditionsList,
                  initCall: widget.initialize,
                  showConfirmationDialog: showConfirmationDialog
              ),
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
                            child: ExpeditionForm()
                        ),
                      );
                    }
                ).then((value) => {widget.initialize()});
              },
              // onPressed: () {
              //   Navigator.pushNamed(context, AppPaths.expeditionForm)
              //       .then((value) => {widget.initialize()});
              // },
            )
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
