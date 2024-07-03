import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/services/generate_image_url.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/widgets/circle_with_number_text.dart';
import 'package:expedition_poc/widgets/image_gridview.dart';
import 'package:expedition_poc/widgets/popup_menu.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/material.dart';

enum ExpandableContent { none, picture, comment }

class SampleCard extends StatefulWidget {
  final Map<String, dynamic> item;
  bool showAllOngoing;
  Function(dynamic key) initCall;
  Function(String name, String key) showConfirmationDialog;

  SampleCard(
      {super.key,
      required this.item,
      required this.initCall,
      required this.showAllOngoing,
      required this.showConfirmationDialog});

  @override
  State<SampleCard> createState() => _SampleCardState();
}

class _SampleCardState extends State<SampleCard> {
  List<String> urlList = <String>[];

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
    getImageList();
  }

  getImageList() async {
    List picturesList = widget.item["pictures"] ?? [];
    setState(() {
      urlList.clear();
    });

    for (int i = 0; i < picturesList.length; i++) {
      GenerateImageUrl generateImageUrl = GenerateImageUrl();
      String url = await generateImageUrl.getImageUrl(picturesList[i]);
      setState(() {
        urlList.add(url);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {
              Navigator.pushNamed(context, AppPaths.analysis, arguments: {
                "sampleId": widget.item["_key"],
                "diveId": widget.item["diveId"],
                "areaId": widget.item['areaId'],
                "expeditionId": widget.item["expeditionId"],
                "locationId": widget.item["locationId"]
              })
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
                        NumbeWithTitle(number: widget.item["analysisCount"], text: 'analysis', color: ColorUtils.analysisColor
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        PopupMenu(menuList: [
                          {
                            "name": "+ Analysis",
                            "value": "analysis",
                            "method": () => {
                              Navigator.pushNamed(
                                  context, AppPaths.analysisForm,
                                  arguments: {
                                    "areaId": widget.item["areaId"],
                                    "expeditionId": widget.item["expeditionId"],
                                    "diveId": widget.item["diveId"],
                                    "locationId": widget.item["locationId"],
                                    "sampleId": widget.item["_key"]
                                  })
                            }
                          },
                          {
                            "name": "Edit",
                            "value": "edit",
                            "method": () => {
                              Navigator.pushNamed(context, AppPaths.sampleForm,
                                  arguments: {
                                    "expeditionId": widget.item["expeditionId"],
                                    "areaId": widget.item['areaId'],
                                    "diveId": widget.item["diveId"],
                                    "locationId": widget.item["locationId"],
                                    "sampleId": widget.item["_key"]
                                  }).then((value) {
                                widget.showAllOngoing
                                    ? widget
                                    .initCall(widget.item["locationId"])
                                    : widget.initCall(widget.item["diveId"]);
                                setState(() {
                                  _selectedPanel = ExpandableContent.none;
                                });
                                selectedPanelContent();
                              })
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
                    )
                  ],
                ),
                ReadOnlyField(
                    title: 'Date-Time',
                    value: widget.item["date"] + " " + widget.item["time"]),
                ReadOnlyField(title: 'Type', value: widget.item["type"]),
                ExpandablePanel(
                  header: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          if (_selectedPanel == ExpandableContent.picture) {
                            setState(() {
                              _selectedPanel = ExpandableContent.none;
                            });
                          } else {
                            setState(() {
                              _selectedPanel = ExpandableContent.picture;
                            });
                          }
                          selectedPanelContent();
                        },
                        child: Text(
                          'Pictures',
                          style: TextStyle(
                              color: selectedPanelColor(
                                  ExpandableContent.picture)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          getImageList();
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
    if (_selectedPanel == ExpandableContent.picture) {
      setState(() {
        _selectedPanelContent = ImageGridView(imageUrls: urlList);
      });
    } else if (_selectedPanel == ExpandableContent.comment) {
      setState(() {
        _selectedPanelContent = commentWidget();
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
                  overflow: TextOverflow.ellipsis, // Add this line to handle long texts
                  maxLines: 5, // Add this line to handle long texts
                ),
              ),
              // Text(widget.item["comment"] ?? ""),
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
      "collectionType": DELETE_TYPE.SAMPLE.index
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
}
