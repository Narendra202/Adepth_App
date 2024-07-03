import 'package:expedition_poc/screens/application/expeditions/expedition_card.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';


class ExpeditionsList extends StatefulWidget {
  List expeditionsList = [];
  Function() initCall;
  Function(String name, String key) showConfirmationDialog;
  ExpeditionsList(
      {Key? key,
      required this.expeditionsList,
      required this.initCall,
      required this.showConfirmationDialog})
      : super(key: key);

  @override
  State<ExpeditionsList> createState() => _ExpeditionsListState();
}

class _ExpeditionsListState extends State<ExpeditionsList> {
  late List expeditionsList = [];
  late Function() initialize;
  late Function(String name, String key) showConfirmationDialog;

  @override
  void initState() {
    super.initState();
    expeditionsList = widget.expeditionsList;
    initialize = widget.initCall;
    showConfirmationDialog = widget.showConfirmationDialog;
  }

  @override
  Widget build(BuildContext context) {

    return  ResponsiveApp(
      mobile: ListView.builder(
          itemCount: expeditionsList.length, // The number of items in the list
          itemBuilder: (BuildContext context, int index) {
            // Build a widget for each item in the list
            return ExpeditionCard(
                item: expeditionsList[index],
                initCall: initialize,
                showConfirmationDialog: showConfirmationDialog);
          },
      ),
      tablet: DynamicHeightGridView(
          itemCount: expeditionsList.length,
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          builder: (ctx, index) {
            return ExpeditionCard(
              item: expeditionsList[index],
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog,
            );
          }
      ),
      desktop: DynamicHeightGridView(
          itemCount: expeditionsList.length,
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          builder: (ctx, index) {
            return ExpeditionCard(
                        item: expeditionsList[index],
                        initCall: initialize,
                        showConfirmationDialog: showConfirmationDialog,
                      );
          }
      ),
      // GridView.builder(
      //   padding: const EdgeInsets.all(10),
      //   shrinkWrap: true,
      //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //     crossAxisCount: 3,
      //     crossAxisSpacing: 10,
      //     mainAxisSpacing: 10,
      //     // childAspectRatio: 1, // Adjust this value to control the width
      //   ),
      //   itemCount: expeditionsList.length,
      //   itemBuilder: (context, index) {
      //     return IntrinsicHeight(
      //       child: ExpeditionCard(
      //         item: expeditionsList[index],
      //         initCall: initialize,
      //         showConfirmationDialog: showConfirmationDialog,
      //       ),
      //     );
      //   },
      // )
    );
  }
}
