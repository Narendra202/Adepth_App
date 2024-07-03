import 'package:expedition_poc/screens/application/expeditions/data/data_form.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/widgets/popup_menu.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class DataCard extends StatelessWidget {
  final Map<String, dynamic> item;
  Function(dynamic expeditionId) initCall;
  Function(String name, String key, String type) showConfirmationDialog;
  Function(dynamic)? editformData;

  DataCard(
      {super.key,
      required this.item,
      required this.initCall,
      required this.showConfirmationDialog , this.editformData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {
              // Navigator.pushNamed(context, "/expedition/area/dive", arguments: {
              //   "areaId": item['_key'],
              //   "expeditionId": item["expeditionId"]
              // })
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
                    PopupMenu(menuList: [
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
                                      child: DataForm(arguments: {
                                          "expeditionId": item["expeditionId"],
                                          "dataId": item['_key'],
                                      },
                                        formData: (value) {
                                          editformData!(value);
                                          finish(context);
                                        },
                                      )
                                  ),);
                              }
                          )

                              // Navigator.pushNamed(context, AppPaths.dataForm,
                              //     arguments: {
                              //       "expeditionId": item["expeditionId"],
                              //       "dataId": item['_key'],
                              //     }).then(
                              //     (value) => {initCall(item["expeditionId"])})
                            }
                      },
                      {
                        "name": "Delete",
                        "value": "delete",
                        "method": () => {
                              showConfirmationDialog(item["name"], item["_key"],
                                  DELETE_TYPE.DATA.index.toString())
                            }
                      }
                    ])
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  item["type"],
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ));
  }
}
