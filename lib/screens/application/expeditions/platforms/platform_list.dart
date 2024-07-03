import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:expedition_poc/screens/application/expeditions/platforms/platform_card.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:flutter/material.dart';

class PlatformList extends StatefulWidget {
  List platformList = [];
  Function(dynamic item) initCall;
  Function(String name, String key, String type) showConfirmationDialog;
  final void Function(dynamic) editformData;
  PlatformList(
      {Key? key,
      required this.initCall,
      required this.platformList,
      required this.showConfirmationDialog, required this.editformData})
      : super(key: key);

  @override
  State<PlatformList> createState() => _PlatformListState();
}

class _PlatformListState extends State<PlatformList> {
  late List platformList = [];
  late Function(dynamic item) initialize;
  late Function(String name, String key, String type) showConfirmationDialog;

  @override
  void initState() {
    super.initState();
    platformList = widget.platformList;
    initialize = widget.initCall;
    showConfirmationDialog = widget.showConfirmationDialog;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      mobile: ListView.builder(
        itemCount: platformList.length, // The number of items in the list
        itemBuilder: (BuildContext context, int index) {
          // Build a widget for each item in the list
          return PlatformCard(
              item: platformList[index],
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog,
              editformData: (value){
                widget.editformData(value);
          }
          );
        },
      ),
      tablet: DynamicHeightGridView(
        itemCount: platformList.length,
        crossAxisCount: 2,
        builder: (context , index) {
          return PlatformCard(
              item: platformList[index],
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog,
              editformData: (value){
                widget.editformData(value);
              }
          );
        },
      ),
      desktop: DynamicHeightGridView(
        itemCount: platformList.length,
        crossAxisCount: 3,
        builder: (context , index) {
          return PlatformCard(
              item: platformList[index],
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
