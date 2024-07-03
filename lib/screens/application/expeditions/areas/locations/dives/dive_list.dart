import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/dive_card.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:flutter/material.dart';

class DiveList extends StatefulWidget {
  List diveList = [];
  Function(dynamic areaId) initCall;
  Function(String name, String key) showConfirmationDialog;
  DiveList({Key? key, required this.diveList, required this.initCall,
    required this.showConfirmationDialog})
      : super(key: key);

  @override
  State<DiveList> createState() => _DiveListState();
}

class _DiveListState extends State<DiveList> {
  late List diveList = [];
  late Function(dynamic areaId) initialize;
  late Function(String name, String key) showConfirmationDialog;

  @override
  void initState() {
    super.initState();
    diveList = widget.diveList;
    initialize = widget.initCall;
    showConfirmationDialog = widget.showConfirmationDialog;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      mobile: ListView.builder(
        itemCount: diveList.length, // The number of items in the list
        itemBuilder: (BuildContext context, int index) {
          // Build a widget for each item in the list
          return DiveCard(
              item: diveList[index],
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog
          );
        },
      ),
      tablet: DynamicHeightGridView(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        itemCount: diveList.length,
        builder: (context , index) {
          return DiveCard(
              item: diveList[index],
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog
          );
        },
      ),
      desktop: DynamicHeightGridView(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        itemCount: diveList.length,
        builder: (context , index) {
          return DiveCard(
              item: diveList[index],
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog
          );
        },
      ),
    );
  }
}
