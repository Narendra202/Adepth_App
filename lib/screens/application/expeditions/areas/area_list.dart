import 'package:expedition_poc/screens/application/expeditions/areas/area_card.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';


class AreaList extends StatefulWidget {
  List areaList = [];
  Function(dynamic expeditionId) initCall;
  Function(String name, String key) showConfirmationDialog;
  AreaList({Key? key, required this.areaList, required this.initCall,
    required this.showConfirmationDialog})
      : super(key: key);

  @override
  State<AreaList> createState() => _AreaListState();
}

class _AreaListState extends State<AreaList> {
  late List areaList = [];
  late Function(dynamic expeditionId) initialize;
  late Function(String name, String key) showConfirmationDialog;

  @override
  void initState() {
    super.initState();
    areaList = widget.areaList;
    initialize = widget.initCall;
    showConfirmationDialog = widget.showConfirmationDialog;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
        mobile: ListView.builder(
          itemCount: areaList.length, // The number of items in the list
          itemBuilder: (BuildContext context, int index) {
            // Build a widget for each item in the list
            return AreaCard(
                item: areaList[index],
                initCall: initialize,
                showConfirmationDialog: showConfirmationDialog
            );
          },
        ),
        tablet: DynamicHeightGridView(
            itemCount: areaList.length,
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            builder: (ctx, index) {
              return AreaCard(
                  item: areaList[index],
                  initCall: initialize,
                  showConfirmationDialog: showConfirmationDialog
              );
            }
        ),
        desktop: DynamicHeightGridView(
            itemCount: areaList.length,
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            builder: (ctx, index) {
              return AreaCard(
                          item: areaList[index],
                          initCall: initialize,
                          showConfirmationDialog: showConfirmationDialog
                      );
            }
        ),
    );
    //   GridView.count(
    //   crossAxisCount: 3,
    //   childAspectRatio: (1 / .25),
    //   children: List.generate(areaList.length, (index) {
    //     return AreaCard(
    //                 item: areaList[index],
    //                 initCall: initialize,
    //                 showConfirmationDialog: showConfirmationDialog
    //             );
    //   }),
    // );
    //
  }
}
