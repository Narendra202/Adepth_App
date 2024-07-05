import 'package:expandable/expandable.dart';
import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/locations/dives/dive_form.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/utilities/hexColor.dart';
import 'package:expedition_poc/widgets/circle_with_number_text.dart';
import 'package:expedition_poc/widgets/popup_menu.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/material.dart';

const diveStatusColors = {
  "notStarted": "#3F51B5",
  "onGoing": "#4CAF50",
  "completed": "#FF9800",
  "planned": "#F2CD00"
};
const diveStatusValue = {
  "notStarted": "Pending",
  "onGoing": "Active",
  "completed": "Completed",
  "planned": "Planned"
};

enum ExpandableContent { none, purpose, protocol, comment }

class DiveCard extends StatefulWidget {
  final Map<String, dynamic> item;
  Function(dynamic locationId) initCall;
  Function(String name, String key) showConfirmationDialog;

  DiveCard(
      {super.key,
      required this.item,
      required this.initCall,
      required this.showConfirmationDialog});

  @override
  State<DiveCard> createState() => _DiveCardState();
}

class _DiveCardState extends State<DiveCard> {
  List platformsList = [], toolsList = [];

  final ExpandableController _expandableController =
      ExpandableController(initialExpanded: true);
  ExpandableContent _selectedPanel = ExpandableContent.none;
  Widget _selectedPanelContent = const Text("");
  final _commentController = TextEditingController();

  bool isCommentEditing = false;

  @override
  void initState() {
    super.initState();
    _commentController.text = widget.item["comment"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    platformsList = widget.item["platformsList"];
    toolsList = widget.item["toolsList"];

    return GestureDetector(
        onTap: () => {
              Navigator.pushNamed(context, AppPaths.sample, arguments: {
                "diveId": widget.item["_key"],
                "areaId": widget.item['areaId'],
                "locationId": widget.item['locationId'],
                "expeditionId": widget.item["expeditionId"]
              }).then((value) => widget.initCall(widget.item["locationId"]))
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
                      widget.item["name"],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Row(
                      children: [
                        NumbeWithTitle(
                            number: widget.item["sampleCount"],
                            text: 'samples',
                            color: ColorUtils.sampleColor),
                        const SizedBox(
                          width: 5,
                        ),
                        NumbeWithTitle(
                            number: widget.item["analysisCount"],
                            text: 'analysis',
                            color: ColorUtils.analysisColor),
                        const SizedBox(
                          width: 5,
                        ),
                        Container(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: HexColor(
                                      diveStatusColors[widget.item["status"]]!),
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            child: Text(
                              diveStatusValue[widget.item["status"]]!,
                              style: TextStyle(
                                  color: HexColor(diveStatusColors[
                                      widget.item["status"]]!)),
                            )),
                        const SizedBox(
                          width: 5,
                        ),
                        PopupMenu(menuList: [
                          {
                            "name": "+ Sample",
                            "value": "sample",
                            "method": () => {
                                  Navigator.pushNamed(
                                      context, AppPaths.sampleForm, arguments: {
                                    "areaId": widget.item["areaId"],
                                    "expeditionId": widget.item["expeditionId"],
                                    "locationId": widget.item["locationId"],
                                    "diveId": widget.item["_key"]
                                  }).then((value) => {
                                        widget
                                            .initCall(widget.item["locationId"])
                                      })
                                }
                          },
                          {
                            "name": "Edit",
                            "value": "edit",
                            "method": () {
                              if (_expandableController.value == false) {
                                _expandableController.toggle();
                                setState(() {
                                  _selectedPanel = ExpandableContent.none;
                                });
                              }
                              if (_selectedPanel != ExpandableContent.none) {
                                selectedPanelContent();
                              }

                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                return  AlertDialog(
                                  contentPadding: EdgeInsets.zero,
                                  content: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: DiveForm(
                                        arguments: {
                                          "diveId": widget.item["_key"],
                                          "expeditionId": widget.item["expeditionId"],
                                          "areaId": widget.item["areaId"],
                                          "locationId": widget.item["locationId"],
                                      },
                                      )
                                  ),);
                              }).then((value) => {widget.initCall(widget.item["locationId"])});
                              
                              // Navigator.pushNamed(context, AppPaths.diveForm,
                              //     arguments: {
                              //       "diveId": widget.item["_key"],
                              //       "expeditionId": widget.item["expeditionId"],
                              //       "areaId": widget.item["areaId"],
                              //       "locationId": widget.item["locationId"],
                              //     }).then((value) =>
                              //     {widget.initCall(widget.item["locationId"])});
                            }
                          },
                          {
                            "name": "Delete",
                            "value": "delete",
                            "method": () => {
                                  widget.showConfirmationDialog(
                                      widget.item["name"], widget.item["_key"])
                                }
                          }
                        ])
                      ],
                    ),
                  ],
                ),
                showPlatformAndTool(context),
                ExpandablePanel(
                  header: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          if (_selectedPanel == ExpandableContent.purpose) {
                            setState(() {
                              _selectedPanel = ExpandableContent.none;
                            });
                          } else {
                            setState(() {
                              _selectedPanel = ExpandableContent.purpose;
                            });
                          }
                          selectedPanelContent();
                        },
                        child: Text(
                          'Purpose',
                          style: TextStyle(
                              color: selectedPanelColor(
                                  ExpandableContent.purpose)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_selectedPanel == ExpandableContent.protocol) {
                            setState(() {
                              _selectedPanel = ExpandableContent.none;
                            });
                          } else {
                            setState(() {
                              _selectedPanel = ExpandableContent.protocol;
                            });
                          }
                          selectedPanelContent();
                        },
                        child: Text(
                          'Protocol ',
                          style: TextStyle(
                              color: selectedPanelColor(
                                  ExpandableContent.protocol)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_selectedPanel == ExpandableContent.comment) {
                            setState(() {
                              _selectedPanel = ExpandableContent.none;
                            });
                          } else {
                            setState(() {
                              _selectedPanel = ExpandableContent.comment;
                            });
                          }
                          selectedPanelContent();
                        },
                        child: Text(
                          'Comment',
                          style: TextStyle(
                              color: selectedPanelColor(
                                  ExpandableContent.comment)),
                        ),
                      ),
                    ],
                  ),
                  collapsed: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _selectedPanelContent,
                  ),
                  controller: _expandableController,
                  expanded: Container(),
                  theme: const ExpandableThemeData(
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      iconSize: 15,
                      fadeCurve: Curves.bounceIn),
                ),
              ],
            ),
          ),
        ));
  }

  Color selectedPanelColor(ExpandableContent content) {
    return _selectedPanel == content
        ? ColorUtils.textButtonSelected
        : ColorUtils.primaryColor;
  }

  selectedPanelContent() {
    if (_selectedPanel == ExpandableContent.purpose) {
      setState(() {
        _selectedPanelContent = Text(widget.item["purpose"] ?? "");
      });
    } else if (_selectedPanel == ExpandableContent.comment) {
      setState(() {
        _selectedPanelContent = commentWidget();
      });
    } else if (_selectedPanel == ExpandableContent.protocol) {
      setState(() {
        _selectedPanelContent = Column(
          children: [
            const Text(
              "Platforms",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: platformsList.length,
              itemBuilder: (context, index) {
                final Map platform = platformsList[index];
                return ReadOnlyField(
                    title: platform["name"], value: platform["protocol"] ?? "");
              },
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              "Tools",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: toolsList.length,
              itemBuilder: (context, index) {
                final Map tool = toolsList[index];
                return ReadOnlyField(
                    title: tool["name"], value: tool["protocol"] ?? "");
              },
            )
          ],
        );
      });
    } else {
      _selectedPanelContent = const Text("");
    }
  }

  Widget commentWidget() {
    return !isCommentEditing
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.item["comment"] ?? "",
                  overflow: TextOverflow.ellipsis,
                  // Add this line to handle long texts
                  maxLines: 5, // Add this line to handle long texts
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCommentEditing = true;
                    _selectedPanelContent = commentWidget();
                  });
                },
                child: const Icon(Icons.edit),
              )
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: TextFormField(
                controller: _commentController,
              )),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      await updateDocument(widget.item["_key"]);
                      setState(() {
                        isCommentEditing = false;
                        _selectedPanelContent = commentWidget();
                      });
                    },
                    child: const Icon(Icons.check),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isCommentEditing = false;
                        _selectedPanelContent = commentWidget();
                      });
                    },
                    child: const Icon(Icons.cancel),
                  ),
                ],
              )
            ],
          );
  }

  updateDocument(key) async {
    final obj = {
      "_key": key,
      "data": {"comment": _commentController.text},
      "collectionType": DELETE_TYPE.DIVE.index
    };

    // save to db
    final response = await ApiProvider()
        .post(AppConsts.baseURL + AppConsts.updateDocument, obj);

    if (response != null) {
      setState(() {
        widget.item["comment"] = _commentController.text;
      });
    }
  }

  Widget showPlatformAndTool(BuildContext context) {
    Map argument = {
      "diveId": widget.item["_key"],
      "expeditionId": widget.item["expeditionId"],
      "areaId": widget.item["areaId"],
      "locationId": widget.item["locationId"],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.zero,
          child: Wrap(
            spacing: 5.0, // spacing between adjacent chips
            runSpacing: -10.0, // spacing between lines
            children: platformsList
                .map((e) => Chip(
                padding: EdgeInsets.zero,
                label: Text(
                  e["name"],
                  style: const TextStyle(fontSize: 10),
                ),
                backgroundColor: ColorUtils.platformChip))
                .toList(),
          ),
        ),
        SizedBox(height: 5,),
        Container(
          padding: EdgeInsets.zero,
          child: Wrap(
            spacing: 5.0, // spacing between adjacent chips
            runSpacing: -10.0, // spacing between lines
            children: toolsList
                .map((e) => Chip(
              padding: EdgeInsets.zero,
              label: Text(
                e["name"],
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: ColorUtils.toolChip,
              deleteIcon: Icon(
                e['recordId'] == null ? Icons.add : Icons.edit,
                size: 18,
              ),
              onDeleted: () => {
                argument["toolId"] = e["_key"],
                if (e["recordId"] != null)
                  {argument["recordId"] = e["recordId"]},
                Navigator.pushNamed(context, AppPaths.recordForm,
                    arguments: argument)
                    .then((value) =>
                {widget.initCall(widget.item["locationId"])})
              },
            ))
                .toList(),
          ),
        )
      ],
    );
  }
}
