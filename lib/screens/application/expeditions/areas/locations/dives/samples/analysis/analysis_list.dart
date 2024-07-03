import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/samples/analysis/analysis_card.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:flutter/material.dart';

class AnalysisList extends StatefulWidget {
  List analysisList = [];
  Function(dynamic expeditionId) initCall;
  Function(String name, String key) showConfirmationDialog;
  AnalysisList({Key? key, required this.analysisList, required this.initCall,
    required this.showConfirmationDialog})
      : super(key: key);

  @override
  State<AnalysisList> createState() => _AnalysisListState();
}

class _AnalysisListState extends State<AnalysisList> {
  late List analysisList = [];
  late Function(dynamic expeditionId) initialize;
  late Function(String name, String key) showConfirmationDialog;

  @override
  void initState() {
    super.initState();
    analysisList = widget.analysisList;
    initialize = widget.initCall;
    showConfirmationDialog = widget.showConfirmationDialog;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      mobile: ListView.builder(
        itemCount: analysisList.length, // The number of items in the list
        itemBuilder: (BuildContext context, int index) {
          // Build a widget for each item in the list
          return AnalysisCard(
              item: analysisList[index],
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog
          );
        },
      ),
      tablet: DynamicHeightGridView(
        itemCount: analysisList.length,
        crossAxisCount: 2,
        builder: (context , index) {
          return AnalysisCard(
              item: analysisList[index],
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog
          );
        },
      ),
      desktop: DynamicHeightGridView(
        itemCount: analysisList.length,
        crossAxisCount: 3,
        builder: (context , index) {
          return AnalysisCard(
              item: analysisList[index],
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog
          );
        },
      ),
    );
  }
}
