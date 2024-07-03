import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/samples/sample_card.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:flutter/material.dart';

class SampleList extends StatefulWidget {
  List sampleList = [];
  bool showAllOngoing;
  Function(dynamic key) initCall;
  Function(String name, String key) showConfirmationDialog;
  SampleList(
      {Key? key,
      required this.sampleList,
      required this.initCall,
      required this.showAllOngoing,
      required this.showConfirmationDialog})
      : super(key: key);

  @override
  State<SampleList> createState() => _SampleListState();
}

class _SampleListState extends State<SampleList> {
  late List sampleList = [];
  late bool onGoingValue;
  late Function(dynamic key) initialize;
  late Function(String name, String key) showConfirmationDialog;

  @override
  void initState() {
    super.initState();
    sampleList = widget.sampleList;
    initialize = widget.initCall;
    onGoingValue = widget.showAllOngoing;
    showConfirmationDialog = widget.showConfirmationDialog;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      mobile: ListView.builder(
        itemCount: sampleList.length, // The number of items in the list
        itemBuilder: (BuildContext context, int index) {
          // Build a widget for each item in the list
          return SampleCard(
              item: sampleList[index],
              initCall: initialize,
              showAllOngoing: onGoingValue,
              showConfirmationDialog: showConfirmationDialog
          );
        },
      ),
      tablet: DynamicHeightGridView(
        itemCount: sampleList.length,
        crossAxisCount: 2,
        builder: (context , index) {
          return SampleCard(
              item: sampleList[index],
              initCall: initialize,
              showAllOngoing: onGoingValue,
              showConfirmationDialog: showConfirmationDialog
          );
        },
      ),
      desktop: DynamicHeightGridView(
        itemCount: sampleList.length,
        crossAxisCount: 3,
        builder: (context , index) {
          return SampleCard(
              item: sampleList[index],
              initCall: initialize,
              showAllOngoing: onGoingValue,
              showConfirmationDialog: showConfirmationDialog
          );
        },
      ),
    );
  }
}
