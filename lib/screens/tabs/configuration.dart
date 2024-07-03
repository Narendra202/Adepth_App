import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/data/data_list.dart';
import 'package:expedition_poc/screens/application/expeditions/platforms/platform_list.dart';
import 'package:expedition_poc/screens/application/expeditions/tools/tool_list.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/appPaths.dart';
import 'package:expedition_poc/utils/AppButtonCirculer.dart';
import 'package:expedition_poc/widgets/add_floatingButton.dart';
import 'package:expedition_poc/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  var expandedValue;
  String headerValue;
  bool isExpanded;

  Item copyWith({
    Widget? expandedValue,
    String? headerValue,
    bool? isExpanded,
  }) {
    return Item(
      expandedValue: expandedValue ?? this.expandedValue,
      headerValue: headerValue ?? this.headerValue,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

class Configuration extends StatefulWidget {
  final String expeditionId;

  Configuration({Key? key, required this.expeditionId}) : super(key: key);

  @override
  State<Configuration> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration> {
  String expeditionId = "";
  late List platformList = [], toolList = [], dataList = [];
  bool _isLoading = false;

  List<Item> _items = [];

  int selectedPanel = -1;
  List formPathList = [
    AppPaths.platformForm,
    AppPaths.toolForm,
    AppPaths.dataForm
  ];

  @override
  void initState() {
    super.initState();
    expeditionId = widget.expeditionId;
    initialize();
  }

  initializePlatform(expeditionId) async {
    setState(() {
      _isLoading = true;
    });
    final platformResponse = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.platformList + expeditionId);
    setState(() {
      _isLoading = false;
    });

    setState(() {
      platformList.clear();
      platformList.addAll(platformResponse["data"]);
    });
  }

  initializeTool(expeditionId) async {
    setState(() {
      _isLoading = true;
    });
    final toolResponse = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.toolList + expeditionId);
    setState(() {
      _isLoading = false;
    });

    setState(() {
      toolList.clear();
      toolList.addAll(toolResponse["data"]);
    });
  }

  initializeData(expeditionId) async {
    setState(() {
      _isLoading = true;
    });
    final dataResponse = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.dataList + expeditionId);
    setState(() {
      _isLoading = false;
    });

    setState(() {
      dataList.clear();
      dataList.addAll(dataResponse["data"]);
    });
  }

  initialize() async {
    if (expeditionId.isNotEmpty) {
      await initializePlatform(expeditionId);
      await initializeTool(expeditionId);
      await initializeData(expeditionId);

      setState(() {
        _items.clear();
        _items.add(Item(
          headerValue: 'Platforms',
          expandedValue: SizedBox(
            height: 400,
            child: PlatformList(
                platformList: platformList,
                initCall: initializePlatform,
                showConfirmationDialog: showConfirmationDialog,
                editformData: (value) {},

            ),
          ),
          isExpanded: false,
        ));
        _items.add(Item(
          headerValue: 'Tools',
          expandedValue: SizedBox(
            height: 400,
            child: ToolList(
                toolList: toolList,
                initCall: initializeTool,
                showConfirmationDialog: showConfirmationDialog),
          ),
          isExpanded: false,
        ));
        _items.add(Item(
          headerValue: 'Data',
          expandedValue: SizedBox(
            height: 400,
            child: DataList(
                dataList: dataList,
                initCall: initializeData,
                showConfirmationDialog: showConfirmationDialog, editformData: (value) {  },),
          ),
          isExpanded: false,
        ));
      });
    }
  }

  @override
  void didUpdateWidget(Configuration oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.expeditionId != expeditionId) {
      expeditionId = widget.expeditionId;
      initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: ExpansionPanelList(
                elevation: 2,
                expandedHeaderPadding: EdgeInsets.zero,
                dividerColor: Colors.grey,
                animationDuration: const Duration(milliseconds: 300),
                children: _items.map<ExpansionPanel>((Item item) {
                  return ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(
                          item.headerValue,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    body: item.expandedValue,
                    isExpanded: item.isExpanded,
                  );
                }).toList(),
                expansionCallback: (int panelIndex, bool isExpanded) {
                  print(isExpanded);

                  setState(() {
                    _items = _items.map((Item item) {
                      return item.copyWith(
                        isExpanded:
                            item.headerValue == _items[panelIndex].headerValue
                                ? !isExpanded
                                : false,
                      );
                    }).toList();
                    if(isExpanded){
                      selectedPanel = -1;
                    }else{
                      selectedPanel = panelIndex;
                    }
                  });
                },
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: AppCircleButton(
            icon: Icons.add,
            onPressed:  () => {
                      if (selectedPanel > -1)
                        {
                          Navigator.pushNamed(context, formPathList[selectedPanel],
                              arguments: {"expeditionId": expeditionId})
                          .then((value) => {initialize()})
                        }
                    }),
          ),
          // floatingActionButton: AddFloatingButton(
          //     event: () => {
          //           if (selectedPanel > -1)
          //             {
          //               Navigator.pushNamed(context, formPathList[selectedPanel],
          //                   arguments: {"expeditionId": expeditionId})
          //               .then((value) => {initialize()})
          //             }
          //         }),
        if (_isLoading)
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.grey),
          ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  showConfirmationDialog(String name, String key, String type) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Confirmation',
          message: "Are you sure you want delete $name?",
          confirmText: 'Yes',
          cancelText: 'No',
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      final obj = {"key": key, "id": type};

      // save to db
      await ApiProvider().post(AppConsts.baseURL + AppConsts.softDelete, obj);

      setState(() {
        platformList.removeWhere((element) => element["_key"] == key);
        _isLoading = false;
      });
    }
  }
}
