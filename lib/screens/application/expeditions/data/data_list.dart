import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:expedition_poc/screens/application/expeditions/data/data_card.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:flutter/material.dart';

class DataList extends StatefulWidget {
  List dataList = [];
  Function(dynamic item) initCall;
  Function(String name, String key, String type) showConfirmationDialog;
  final void Function(dynamic) editformData;

  DataList(
      {Key? key,
      required this.initCall,
      required this.dataList,
      required this.showConfirmationDialog, required this.editformData})
      : super(key: key);

  @override
  State<DataList> createState() => _DataListState();
}

class _DataListState extends State<DataList> {
  late List dataList = [];
  late Function(dynamic item) initialize;
  late Function(String name, String key, String type) showConfirmationDialog;

  @override
  void initState() {
    super.initState();
    dataList = widget.dataList;
    initialize = widget.initCall;
    showConfirmationDialog = widget.showConfirmationDialog;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      mobile: ListView.builder(
        itemCount: dataList.length, // The number of items in the list
        itemBuilder: (BuildContext context, int index) {
          // Build a widget for each item in the list
          return DataCard(
              item: dataList[index],
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog,
              editformData: (value){
                widget.editformData(value);
              },
          );
        },
      ),
      tablet: DynamicHeightGridView(
        itemCount: dataList.length,
        crossAxisCount: 2,
        builder: (context , index) {
          return DataCard(
              item: dataList[index],
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog,
              editformData: (value){
                widget.editformData(value);
            },
          );
        },
      ),
      desktop: DynamicHeightGridView(
        itemCount: dataList.length,
        crossAxisCount: 3,
        builder: (context , index) {
          return DataCard(
              item: dataList[index],
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog,
              editformData: (value){
               widget.editformData(value);
            }
          );
        },
      ),
    );
  }
}
