import 'dart:io';

import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/areas.dart';
import 'package:expedition_poc/services/generate_image_url.dart';
import 'package:expedition_poc/services/location_service.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/widgets/gallery_item.dart';
import 'package:expedition_poc/widgets/imageUpload.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class RecordForm extends StatefulWidget {
  const RecordForm({super.key});

  @override
  _RecordFormState createState() => _RecordFormState();
}

class _RecordFormState extends State<RecordForm> {
  String recordId = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late String areaId, expeditionId, diveId, locationId, toolId;

  String name = "", protocol = "";
  final _cmController = TextEditingController();
  final _commentController = TextEditingController();
  final _linkController = TextEditingController();

  var _recordTypeValue;
  final List _recordTypeList = [];
  final List _fieldsList = ["1", "3"];

  String currentDate = "", currentTime = "", latitude = "", longitude = "";

  final List<File> _photos = <File>[];
  final List<String> _photosUrls = <String>[];
  final List<String> _s3KeysList = <String>[];

  final List<PhotoSource> _photosSources = <PhotoSource>[];
  final List<PhotoStatus> _photosStatus = <PhotoStatus>[];
  final List<GalleryItem> _galleryItems = <GalleryItem>[];

  bool _isTypeDropdownEnabled = true;

  @override
  void dispose() {
    super.dispose();
    _cmController.dispose();
    _commentController.dispose();
    _linkController.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments;
    expeditionId = (arguments as Map)["expeditionId"];
    diveId = (arguments)["diveId"];
    areaId = (arguments)["areaId"];
    locationId = (arguments)["locationId"];
    toolId = (arguments)["toolId"];
    setState(() {
      _isLoading = true;
    });
    await initLookupData();
    if (arguments.containsKey("recordId")) {
      recordId = (arguments)["recordId"];
      await getData();
    }
    setState(() {
      _isLoading = false;
    });
  }

  initLookupData() async {
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.dataRecordList + expeditionId);
    setState(() {
      _recordTypeList.addAll(response);
    });
  }

  getData() async {
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.recordDocument + recordId);

    List picturesList = response["pictures"] ?? [];

    List<String> urlList = <String>[];
    List<File> fileList = <File>[];
    for (int i = 0; i < picturesList.length; i++) {
      GenerateImageUrl generateImageUrl = GenerateImageUrl();
      String url = await generateImageUrl.getImageUrl(picturesList[i]);
      urlList.add(url);
    }
    for(var i= 0; i< urlList.length ; i++){
      fileList.add(File('/path/to/my/file.txt'));
    }

    setState(() {
      name = response["name"];
      protocol = response["protocol"];
      _recordTypeValue = response["recordTypeId"];
      _isTypeDropdownEnabled = false;

      for (var i = 0; i < response["fieldsList"].length; i++) {
        _fieldsList.add(response["fieldsList"][i]);
      }

      if (_fieldsList.contains(Enum.dataFields["CM"])) {
        _cmController.text = response["cm"] ?? "";
      }
      if (_fieldsList.contains(Enum.dataFields["STAMP"])) {
        latitude = response["lat"] ?? "";
        longitude = response["long"] ?? "";
        currentDate = response["date"] ?? "";
        currentTime = response["time"] ?? "";
      }
      if (_fieldsList.contains(Enum.dataFields["COMMENT"])) {
        _commentController.text = response["comment"] ?? "";
      }
      if (_fieldsList.contains(Enum.dataFields["LINK"])) {
        _linkController.text = response["link"] ?? "";
      }

      // photos add
      for(var i= 0; i< picturesList.length ; i++) {
        _s3KeysList.add(picturesList[i]);
      }
      _photosUrls.addAll(urlList);
      _photos.addAll(fileList);
      for(var i= 0; i< urlList.length ; i++){
        _photosStatus.add(PhotoStatus.LOADED);
        _photosSources.add(PhotoSource.NETWORK);
        _galleryItems.add(
            GalleryItem(
              id: "1",
              resource: "image",
              isSvg: false,
            )
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              title: const Text('Record'),
            ),
            body: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(15.0),
                child: Form(
                  key: _formKey,
                  child: formUI(),
                ),
              ),
            ),
            bottomNavigationBar: Container(
              height: 50,
              color: ColorUtils.secondaryColor,
              child: InkWell(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    saveArea();
                  }
                },
                child: const Center(
                  child: Text(
                    "Save",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            )),
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

  onTypeChange(newValue) async {
    int index = _recordTypeList.indexWhere((f) => f['_key'] == newValue);

    setState(() {
      _recordTypeValue = newValue;
      _fieldsList.clear();
      _fieldsList.addAll(_recordTypeList[index]["fieldsList"]);
      protocol = _recordTypeList[index]["protocol"];
    });

    // generate analysis name
    generateName();

    // re-initialize stamp data
    if (_fieldsList.contains(Enum.dataFields["STAMP"])) {
      LocationData locationData = await LocationService().getLocation();

      setState(() {
        DateTime now = DateTime.now();
        currentDate = "${now.month}/${now.day}/${now.year}";
        currentTime = "${now.hour}:${now.minute}:${now.second}";

        if (latitude.isEmpty && locationData != null) {
          latitude = (locationData.latitude).toString();
          longitude = (locationData.longitude).toString();
        }
      });
    }
  }

  generateName() async {
    setState(() {
      _isLoading = true;
    });
    String sampleName = await ApiProvider().get(
        "${AppConsts.baseURL}${AppConsts.generateNameRecord}$diveId/$_recordTypeValue");
    setState(() {
      _isLoading = false;
      name = sampleName;
    });
  }

  Widget formUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReadOnlyField(title: 'Record', value: name),
        ReadOnlyField(title: 'Protocol', value: protocol),
        DropdownButtonFormField(
          value: _recordTypeValue,
          items: _recordTypeList
              .map((value) => DropdownMenuItem(
                    value: value["_key"],
                    child: Text(value["name"]!),
                  ))
              .toList(),
          onChanged: _isTypeDropdownEnabled ? onTypeChange : null,
          decoration: const InputDecoration(
            labelText: 'Type',
          ),
        ),
        if (_recordTypeValue != null) ...[
          if (_fieldsList.contains(Enum.dataFields["STAMP"])) ...stampWidgets(),
          if (_fieldsList.contains(Enum.dataFields["CM"]))
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Cm',
              ),
              controller: _cmController,
            ),
          if (_fieldsList.contains(Enum.dataFields["COMMENT"]))
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Comment',
              ),
              controller: _commentController,
            ),
          if (_fieldsList.contains(Enum.dataFields["LINK"]))
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Link',
              ),
              controller: _linkController,
            ),
          if (_fieldsList.contains(Enum.dataFields["PICTURE"]))
            ImageUpload(
                folderName: PictureFolderName.record.toString().split('.')[1],
                photos: _photos,
                photosUrls: _photosUrls,
                s3KeysList: _s3KeysList,
                photosSources: _photosSources,
                photosStatus: _photosStatus),
        ]
      ],
    );
  }

  List stampWidgets() {
    return [
      const SizedBox(
        height: 15,
      ),
      Column(
        children: [
          ReadOnlyField(title: 'Date', value: currentDate),
          ReadOnlyField(title: 'Time', value: currentTime),
          ReadOnlyField(title: 'Latitude', value: latitude),
          ReadOnlyField(title: 'Longitude', value: longitude),
        ],
      )
    ];
  }

  Future saveArea() async {
    setState(() {
      _isLoading = true;
    });
    final obj = {
      "areaId": areaId,
      "diveId": diveId,
      "toolId": toolId,
      "expeditionId": expeditionId,
      "locationId": locationId,
      "name": name,
      "protocol": protocol,
      "recordTypeId": _recordTypeValue,
    };
    if (_fieldsList.contains(Enum.dataFields["CM"])) {
      obj["cm"] = _cmController.text;
    }
    if (_fieldsList.contains(Enum.dataFields["STAMP"])) {
      obj["lat"] = latitude;
      obj["long"] = longitude;
      obj["date"] = currentDate;
      obj["time"] = currentTime;
    }
    if (_fieldsList.contains(Enum.dataFields["COMMENT"])) {
      obj["comment"] = _commentController.text;
    }
    if (_fieldsList.contains(Enum.dataFields["LINK"])) {
      obj["link"] = _linkController.text;
    }
    if (_fieldsList.contains(Enum.dataFields["PICTURE"])) {
      obj["pictures"] = _s3KeysList;
    }
    if (recordId.isNotEmpty) {
      obj["_key"] = recordId;
    }
    // save to db
    final response =
        await ApiProvider().post(AppConsts.baseURL + AppConsts.saveRecord, obj);
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context, MaterialPageRoute(builder: (context) => Areas()));
  }
}
