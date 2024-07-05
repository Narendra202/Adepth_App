import 'package:expedition_poc/screens/application/expeditions/areas/locations/location_form.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/utilities/hexColor.dart';
import 'package:expedition_poc/widgets/circle_with_number_text.dart';
import 'package:expedition_poc/widgets/popup_menu.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

const statusColors = {"onGoing": "#4CAF50", "onLocation": "#F2CD00"};
const statusValue = {
  "onGoing": "Active",
  "onLocation": "Location",
};

class LocationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  Function(dynamic areaId) initCall;
  Function(String name, String key) showConfirmationDialog;
  Function(dynamic)? editformData;

  LocationCard(
      {super.key,
      required this.item,
      required this.initCall,
      required this.showConfirmationDialog , this.editformData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppPaths.dive, arguments: {
            "locationId": item['_key'],
            "areaId": item['areaId'],
            "expeditionId": item["expeditionId"]
          }).then((value) => initCall(item["areaId"]));
        },
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.only(right: 18,left: 13,top: 10,bottom: 10),
          shadowColor: Colors.grey,
          elevation: 1,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item["name"],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        NumbeWithTitle(number: item["diveCount"], text: 'dives', color: ColorUtils.diveColor),
                        const SizedBox(width: 5,),
                        NumbeWithTitle(number: item["sampleCount"], text: 'samples', color: ColorUtils.sampleColor),
                        const SizedBox(
                          width: 5,
                        ),
                        Container(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      HexColor(statusColors[item["status"]]!),
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: Text(
                              statusValue[item["status"]]!,
                              style: TextStyle(
                                  color:
                                      HexColor(statusColors[item["status"]]!)),
                            )),
                        const SizedBox(
                          width: 5,
                        ),
                        PopupMenu(menuList: [
                          {
                            "name": "+ Dive",
                            "value": "dive",
                            "method": () => {
                                  Navigator.pushNamed(
                                      context, AppPaths.diveForm,
                                      arguments: {
                                        "areaId": item["areaId"],
                                        "expeditionId": item["expeditionId"],
                                        "locationId": item["_key"]
                                      }).then(
                                      (value) => {initCall(item["areaId"])})
                                }
                          },
                          {
                            "name": "Edit",
                            "value": "edit",
                            "method": () => {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return  AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      content: Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: LocationForm(arguments: {
                                             "expeditionId": item["expeditionId"],
                                             "areaId": item['areaId'],
                                             "locationId": item['_key'],
                                             "diveCount" : item['diveCount'],
                                             "sampleCount" : item['sampleCount'],
                                             "status" : item['status'],
                                          },
                                            formData: (value){
                                            editformData!(value);
                                            finish(context);
                                            },
                                          )
                                      ),);
                                  }
                              )
                                  // Navigator.pushNamed(
                                  //     context, AppPaths.locationForm,
                                  //     arguments: {
                                  //       "expeditionId": item["expeditionId"],
                                  //       "areaId": item['areaId'],
                                  //       "locationId": item['_key'],
                                  //     }).then(
                                  //     (value) => {initCall(item["areaId"])})
                                }
                          },
                          {
                            "name": "Delete",
                            "value": "delete",
                            "method": () => {
                                  showConfirmationDialog(
                                      item["name"], item["_key"])
                                }
                          }
                        ])
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                ReadOnlyField(
                    title: 'Dives', value: item["diveCount"].toString()),
                ReadOnlyField(
                    title: 'Samples', value: item["sampleCount"].toString()),
                ReadOnlyField(
                    title: 'Date',
                    value: item["startDate"] + " - " + item["endDate"]),
              ],
            ),
          ),
        ));
  }
}
