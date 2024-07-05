import 'package:expedition_poc/screens/application/expeditions/areas/area_form.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/utilities/hexColor.dart';
import 'package:expedition_poc/widgets/circle_with_number_text.dart';
import 'package:expedition_poc/widgets/popup_menu.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class AreaCard extends StatelessWidget {
  final Map<String, dynamic> item;
  Function(dynamic expeditionId) initCall;
  Function(String name, String key) showConfirmationDialog;
  Function(dynamic)? editformData;
  AreaCard({super.key, required this.item, required this.initCall,
    required this.showConfirmationDialog, this.editformData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {
              Navigator.pushNamed(context, AppPaths.location, arguments: {
                "areaId": item['_key'],
                "expeditionId": item["expeditionId"]
              }).then((value) => initCall(item["expeditionId"]))
            },
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.only(right: 18,left: 13,top: 10,bottom: 10),
          shadowColor: Colors.grey.shade600,
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
                        const SizedBox(
                          width: 5,
                        ),
                        if(item["ongoing"] == true)
                        Container(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: HexColor("#4CAF50"),
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: Text(
                              "Active",
                              style: TextStyle(
                                  color: HexColor("#4CAF50")),
                            )),
                        const SizedBox(width: 5,),
                        PopupMenu(menuList: [
                          {
                            "name": "Edit",
                            "value": "edit",
                            "method": () => {
                              //
                              // Navigator.pushNamed(context, AppPaths.areaForm,
                              //     arguments: {
                              //       "expeditionId": item["expeditionId"],
                              //       "areaId": item['_key'],
                              //     }).then(
                              //         (value) => {initCall(item["expeditionId"])})

                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return  AlertDialog(
                                      contentPadding: EdgeInsets.zero,
                                      content: Container(
                                          width: MediaQuery.of(context).size.width,
                                          child: AreaForm(arguments: {
                                            "expeditionId": item["expeditionId"],
                                            "areaId": item['_key'],
                                            "diveCount": item["diveCount"]
                                          }, formData: (value){
                                                editformData!(value);
                                                finish(context);
                                          },)
                                      ),);
                                  }
                              )
                            }
                          },
                          {
                            "name": "Delete",
                            "value": "delete",
                            "method": () =>
                            {showConfirmationDialog(item["name"], item["_key"])}
                          }
                        ])
                      ],
                    ),
                  ],
                ),
                ReadOnlyField(title: 'Days', value: item["operationalDays"]),
                ReadOnlyField(title: 'Target', value: item["targetName"]),
                ReadOnlyField(title: 'Locations', value: item["location"].toString())
              ],
            ),
          ),
        ));
  }
}
