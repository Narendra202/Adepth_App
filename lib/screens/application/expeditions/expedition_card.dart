import 'package:expandable/expandable.dart';
import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/widgets/popup_menu.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import 'expedition_form.dart';

enum ExpandableContent { none, add, operations }

class ExpeditionCard extends StatefulWidget {
  final Map<String, dynamic> item;
  Function() initCall;
  Function(String name, String key) showConfirmationDialog;

  ExpeditionCard(
      {super.key,
      required this.item,
      required this.initCall,
      required this.showConfirmationDialog});

  @override
  State<ExpeditionCard> createState() => _ExpeditionCardState();
}

class _ExpeditionCardState extends State<ExpeditionCard> {
  final ExpandableController _expandableController =
      ExpandableController(initialExpanded: true);
  ExpandableContent _selectedPanel = ExpandableContent.none;
  Widget _selectedPanelContent = const Text("");

  bool isReportApiInProgress = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {

              Navigator.pushNamed(context, AppPaths.area,
                      arguments: {"expeditionId": widget.item["_key"]})
                  .then((value) => {widget.initCall()})
            },
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.only(right: 18,left: 13,top: 10,bottom: 10),
          elevation: 1,
          shadowColor: Colors.grey.shade600,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.grey, width: 0.3),
            borderRadius: BorderRadius.circular(10),
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
                          fontSize: 18, fontWeight: FontWeight.w500,),
                    ),
                    PopupMenu(menuList: [
                      {
                        "name": "Area",
                        "value": "area",
                        "method": () => {
                              Navigator.pushNamed(context, AppPaths.area,
                                  arguments: {
                                    "expeditionId": widget.item['_key']
                                  }).then((value) => {widget.initCall()})
                            }
                      },
                      {
                        "name": "Platform",
                        "value": "platform",
                        "method": () => {
                              Navigator.pushNamed(context, AppPaths.platform,
                                  arguments: {
                                    "expeditionId": widget.item['_key']
                                  })
                            }
                      },
                      {
                        "name": "Tool",
                        "value": "tool",
                        "method": () => {
                              Navigator.pushNamed(context, AppPaths.tool,
                                  arguments: {
                                    "expeditionId": widget.item['_key']
                                  })
                            }
                      },
                      {
                        "name": "Data",
                        "value": "data",
                        "method": () => {
                              Navigator.pushNamed(context, AppPaths.data,
                                  arguments: {
                                    "expeditionId": widget.item['_key']
                                  })
                            }
                      },
                      {
                        "name": "Edit",
                        "value": "edit",
                        "method": () => {
                              // Navigator.pushNamed(
                              //     context, AppPaths.expeditionForm, arguments: {
                              //   "expeditionId": widget.item['_key']
                              // }).then((value) => {widget.initCall()}
                              // )
                              showDialog(
                              context: context,
                              builder: (BuildContext context) {
                             return  AlertDialog(
                             contentPadding: EdgeInsets.zero,
                             content: Container(
                             width: MediaQuery.of(context).size.width,
                             child: ExpeditionForm(arguments: {
                                   "expeditionId": widget.item['_key']
                                  },)
                                  ),);
                               }
                               ).then((value) => {widget.initCall()})
                        }
                      },
                      {
                        "name": "Delete",
                        "value": "delete",
                        "method": () => {
                              widget.showConfirmationDialog(
                                  widget.item["name"], widget.item["_key"])
                            }
                      },
                      {
                        "name": "Report",
                        "value": "excel",
                        "method": () {
                          if(isReportApiInProgress) {
                            const snackBar = SnackBar(
                              content: Text('Generating report wait for sometime...'),
                              duration: Duration(seconds: 3),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            return;
                          }
                          exportJsonToExcel(context);
                        }
                      }
                    ])
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                ReadOnlyField(title: 'Company', value: widget.item["company"]),
                ReadOnlyField(
                    title: 'Date',
                    value: widget.item["startDate"] +
                        " - " +
                        widget.item["endDate"]),
                ReadOnlyField(
                    title: 'Vessel', value: widget.item["vessel"] ?? ""),
                const SizedBox(
                  height: 5,
                ),
                ExpandablePanel(
                  header: Row(
                    children: [
                      if (widget.item["ongoingDetails"] != null)
                        TextButton(
                          onPressed: () {
                            if (_selectedPanel == ExpandableContent.add) {
                              setState(() {
                                _selectedPanel = ExpandableContent.none;
                              });
                            } else {
                              setState(() {
                                _selectedPanel = ExpandableContent.add;
                              });
                            }
                            selectedPanelContent();
                          },
                          child: Text(
                            'Add',
                            style: TextStyle(
                                color:
                                    selectedPanelColor(ExpandableContent.add)),
                          ),
                        ),
                      TextButton(
                        onPressed: () {
                          if (_selectedPanel == ExpandableContent.operations) {
                            setState(() {
                              _selectedPanel = ExpandableContent.none;
                            });
                          } else {
                            setState(() {
                              _selectedPanel = ExpandableContent.operations;
                            });
                          }
                          selectedPanelContent();
                        },
                        child: Text(
                          'Operation ',
                          style: TextStyle(
                              color: selectedPanelColor(
                                  ExpandableContent.operations)),
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
        )
    );
  }

  Future<void> exportJsonToExcel(BuildContext context) async {

    // bool isPerssionGiven = false;
    // print(Platform.version);
    //
    // if (Platform.isAndroid && Platform.version.startsWith('Android 13')) {
    //   // Android 13 or higher, permission not required
    //   print("111");
    //   isPerssionGiven = true;
    // } else {
    //   // Request permission for Android versions below 13
    //   PermissionStatus status = await Permission.manageExternalStorage.request();
    //   print("22222");
    //   if (status.isGranted) {
    //     isPerssionGiven = true;
    //   } else {
    //     isPerssionGiven = false;
    //   }
    // }
    //
    // if(!isPerssionGiven) return;

    const snackBar = SnackBar(
      content: Text('Generating report...'),
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    setState(() {
      isReportApiInProgress = true;
    });
    final response =  await ApiProvider().get(AppConsts.baseURL + AppConsts.generateReport + widget.item["_key"]);
    setState(() {
      isReportApiInProgress = false;
    });

    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    final data = response; // json.decode(response) as List<dynamic>;

    if (data.isNotEmpty) {
      final columnNames = (data.first as Map<String, dynamic>).keys.toList();

      for (var col = 0; col < columnNames.length; col++) {
        sheet
            .cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: col))
            .value = columnNames[col];
      }

      for (var row = 0; row < data.length; row++) {
        final rowData = data[row] as Map<String, dynamic>;
        for (var col = 0; col < columnNames.length; col++) {
          final cellValue = rowData[columnNames[col]];
          sheet
              .cell(CellIndex.indexByColumnRow(
                  rowIndex: row + 1, columnIndex: col))
              .value = cellValue;
        }
      }
    }

    final excelBytes = excel.encode();
    String fileName = 'Report_Adepth.xlsx';

    try {
      const downloadsDirectory = '/storage/emulated/0/Download';
      final downloadDir = Directory(downloadsDirectory);
      if (!downloadDir.existsSync()) {
        downloadDir.createSync(recursive: true);
      }

      var filePath = '$downloadsDirectory/$fileName';
      var file = File(filePath);

      // Check if the file already exists
      if (file.existsSync()) {
        var fileCount = 1;
        while (file.existsSync()) {
          fileName = 'Report_Adepth ($fileCount).xlsx';
          filePath = '$downloadsDirectory/$fileName';
          fileCount++;
          file = File(filePath);
        }
      }

      await file.writeAsBytes(excelBytes!);

      final savedPath = file.path;

      var snackBar = SnackBar(
        content: Text('$fileName saved in Download'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // print('Excel file saved at $savedPath');
    } catch (error) {
      print('Error saving Excel file: $error');
    }
    // } else {
    //   print('Storage permission denied');
    // }
  }

  Color selectedPanelColor(ExpandableContent content) {
    return _selectedPanel == content
        ? ColorUtils.textButtonSelected
        : ColorUtils.primaryColor;
  }

  selectedPanelContent() {
    if (_selectedPanel == ExpandableContent.add) {
      setState(() {
        _selectedPanelContent = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppPaths.location, arguments: {
                  "areaId": widget.item["ongoingDetails"]["areaId"],
                  "expeditionId": widget.item["_key"]
                });
              },
              child: Chip(
                label: const Text(
                  "Dive",
                  style: TextStyle(fontSize: 12),
                ),
                backgroundColor: ColorUtils.platformChip,
                deleteIcon: const Icon(
                  Icons.add,
                  size: 18,
                ),
                onDeleted: () => {},
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppPaths.dive, arguments: {
                  "locationId": widget.item["ongoingDetails"]["locationId"],
                  "areaId": widget.item["ongoingDetails"]["areaId"],
                  "expeditionId": widget.item["_key"]
                });
              },
              child: Chip(
                label: const Text(
                  "Sample",
                  style: TextStyle(fontSize: 12),
                ),
                backgroundColor: ColorUtils.platformChip,
                deleteIcon: const Icon(
                  Icons.add,
                  size: 18,
                ),
                onDeleted: () => {},
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppPaths.sample, arguments: {
                  "locationId": widget.item["ongoingDetails"]["locationId"],
                  "areaId": widget.item["ongoingDetails"]["areaId"],
                  "expeditionId": widget.item["_key"],
                  "diveId": ""
                });
              },
              child: Chip(
                label: const Text(
                  "Analysis",
                  style: TextStyle(fontSize: 12),
                ),
                backgroundColor: ColorUtils.platformChip,
                deleteIcon: const Icon(
                  Icons.add,
                  size: 18,
                ),
                onDeleted: () => {},
              ),
            )
          ],
        );
      });
    } else if (_selectedPanel == ExpandableContent.operations) {
      setState(() {
        _selectedPanelContent = SizedBox(
          height: 200.0, // Replace with the desired height
          child: ListView.builder(
            itemCount: widget.item["ongoingDives"].length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppPaths.dive, arguments: {
                    "locationId": widget.item["ongoingDetails"]["locationId"],
                    "areaId": widget.item["ongoingDetails"]["areaId"],
                    "expeditionId": widget.item["_key"]
                  }).then((value) => {widget.initCall()});
                },
                child: Column(
                  children: <Widget>[
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(widget.item["ongoingDives"][index]["name"]),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      });
    } else {
      _selectedPanelContent = const Text("");
    }
  }
}


