import 'package:expedition_poc/screens/application/expeditions/areas/locations/location_card.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';


class LocationList extends StatefulWidget {
  List locationList = [];
  Function(dynamic areaId) initCall;
  Function(String name, String key) showConfirmationDialog;
  Function(dynamic)? editformData;


  LocationList({Key? key, required this.locationList, required this.initCall,
    required this.showConfirmationDialog, this.editformData})
      : super(key: key);

  @override
  State<LocationList> createState() => _LocationListState();
}

class _LocationListState extends State<LocationList> {
  late List locationList = [];
  late Function(dynamic areaId) initialize;
  late Function(String name, String key) showConfirmationDialog;

  @override
  void initState() {
    super.initState();
    locationList = widget.locationList;
    initialize = widget.initCall;
    showConfirmationDialog = widget.showConfirmationDialog;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      mobile: ListView.builder(
        itemCount: locationList.length, // The number of items in the list
        itemBuilder: (BuildContext context, int index) {
          // Build a widget for each item in the list
          return LocationCard(
              item: locationList[index],
              initCall: initialize,
              showConfirmationDialog: showConfirmationDialog,
              editformData: (value){
                widget.editformData!(value);
              },
          );
        },
      ),
      tablet: DynamicHeightGridView(
          itemCount: locationList.length,
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          builder: (context , index) {
            return  LocationCard(
                item: locationList[index],
                initCall: initialize,
                showConfirmationDialog: showConfirmationDialog,
                editformData: (value){
                 widget.editformData!(value);
              },
            );


          }
      ),
      desktop: DynamicHeightGridView(
        itemCount: locationList.length,
        crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        builder: (context , index) {
          return  LocationCard(
          item: locationList[index],
          initCall: initialize,
           showConfirmationDialog: showConfirmationDialog,
            editformData: (value){
              widget.editformData!(value);
            },
          );


         }
      ),
    );
  }
}
