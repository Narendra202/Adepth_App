import 'package:expedition_poc/screens/application/expeditions/tools/tool_form.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/widgets/popup_menu.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ToolCard extends StatelessWidget {
  final Map<String, dynamic> item;
  Function(dynamic expeditionId) initCall;
  Function(String name, String key, String type) showConfirmationDialog;
  Function(dynamic)? editformData;

  ToolCard(
      {required this.initCall,
      required this.item,
      required this.showConfirmationDialog, this.editformData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {},
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
                                      child: ToolForm(arguments: {
                                        "toolId": item['_key'],
                                        "expeditionId": item["expeditionId"]
                                      },
                                        formData: (value){
                                           editformData!(value);
                                           finish(context);
                                        },
                                   )
                                  ),);
                              }
                          )

                              // Navigator.pushNamed(context, AppPaths.toolForm,
                              //     arguments: {
                              //       "toolId": item['_key'],
                              //       "expeditionId": item["expeditionId"]
                              //     }).then(
                              //     (value) => {initCall(item["expeditionId"])})
                            }
                      },
                      {
                        "name": "Delete",
                        "value": "delete",
                        "method": () => {
                              showConfirmationDialog(item["name"], item["_key"],
                                  DELETE_TYPE.TOOL.index.toString())
                            }
                      }
                    ])
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ReadOnlyField(
                    title: 'Serial Number', value: item["serialNumber"]),
                ReadOnlyField(title: 'Mark', value: item["mark"])
              ],
            ),
          ),
        ));
  }
}
