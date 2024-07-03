import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:expedition_poc/screens/application/expeditions/tools/tool_card.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:flutter/material.dart';

class ToolList extends StatefulWidget {
  List toolList = [];
  Function(dynamic item) initCall;
  Function(String name, String key, String type) showConfirmationDialog;
  Function(dynamic)? editformData;
  ToolList(
      {Key? key,
      required this.initCall,
      required this.toolList,
      required this.showConfirmationDialog, this.editformData})
      : super(key: key);

  @override
  State<ToolList> createState() => _ToolListState();
}

class _ToolListState extends State<ToolList> {
  late List toolList = [];
  late Function(dynamic item) initialize;
  late Function(String name, String key, String type) showConfirmationDialog;

  @override
  void initState() {
    super.initState();
    toolList = widget.toolList;
    initialize = widget.initCall;
    showConfirmationDialog = widget.showConfirmationDialog;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        child: ResponsiveApp(
          mobile: ListView.builder(
            itemCount: toolList.length, // The number of items in the list
            itemBuilder: (BuildContext context, int index) {
              // Build a widget for each item in the list
              return ToolCard(
                  item: toolList[index],
                  initCall: initialize,
                  showConfirmationDialog: showConfirmationDialog,
                  editformData: (value){
                     widget.editformData!(value);
                  },
              );
            },
          ),
          tablet: DynamicHeightGridView(
            itemCount: toolList.length,
            crossAxisCount: 2,
            builder: (context , index) {
              return ToolCard(
                  item: toolList[index],
                  initCall: initialize,
                  showConfirmationDialog: showConfirmationDialog,
                  editformData: (value){
                   widget.editformData!(value);
                  },
              );
            },
          ),
          desktop: DynamicHeightGridView(
            itemCount: toolList.length,
            crossAxisCount: 3,
            builder: (context , index) {
              return ToolCard(
                  item: toolList[index],
                  initCall: initialize,
                  showConfirmationDialog: showConfirmationDialog,
                  editformData: (value){
                    widget.editformData!(value);
                   },
              );
            },
          ),
        ));
  }
}
