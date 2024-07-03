import 'dart:io';

import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/areas.dart';
import 'package:expedition_poc/services/generate_image_url.dart';
import 'package:expedition_poc/services/location_service.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/utils/AppTextFormField.dart';
import 'package:expedition_poc/widgets/gallery_item.dart';
import 'package:expedition_poc/widgets/imageUpload.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../../../../../../../../utils/colors.dart';

class AnalysisForm extends StatefulWidget {
  const AnalysisForm({super.key});

  @override
  _AnalysisFormState createState() => _AnalysisFormState();
}

class _AnalysisFormState extends State<AnalysisForm> {
  String analysisId = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isSaved = false;
  late String areaId, expeditionId, diveId, sampleId, locationId;

  String name = "", protocol = "";
  final _cmController = TextEditingController();
  final _commentController = TextEditingController();
  final _linkController = TextEditingController();

  var _analysisTypeValue;
  final List _analysisTypeList = [];
  final List _fieldsList = [];

  String currentDate = "", currentTime = "", latitude = "", longitude = "";

  final List<File> _photos = <File>[];
  final List<String> _photosUrls = <String>[];
  final List<String> _s3KeysList = <String>[];

  final List<PhotoSource> _photosSources = <PhotoSource>[];
  final List<PhotoStatus> _photosStatus = <PhotoStatus>[];
  final List<GalleryItem> _galleryItems = <GalleryItem>[];

  bool _isTypeDropdownEnabled = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Code here runs after the first frame is rendered, ensuring context is available.
      _initializeData();
    });
  }
  Future<void> _initializeData() async {
    final arguments = ModalRoute.of(context)!.settings.arguments;
      expeditionId = (arguments as Map)["expeditionId"];
      diveId = (arguments)["diveId"];
      areaId = (arguments)["areaId"];
      locationId = (arguments)["locationId"];
      sampleId = (arguments)["sampleId"];

      setState(() {
        _isLoading = true;
      });
      await initLookupData();
      if (arguments.containsKey("analysisId")) {
        analysisId = (arguments)["analysisId"];
        await getData();
      }
      setState(() {
        _isLoading = false;
      });

  }

  @override
  void dispose() {
    super.dispose();
    _cmController.dispose();
    _commentController.dispose();
    _linkController.dispose();
  }

  // @override
  // void didChangeDependencies() async {
  //   super.didChangeDependencies();
  //   final arguments = ModalRoute.of(context)!.settings.arguments;
  //   expeditionId = (arguments as Map)["expeditionId"];
  //   diveId = (arguments)["diveId"];
  //   areaId = (arguments)["areaId"];
  //   locationId = (arguments)["locationId"];
  //   sampleId = (arguments)["sampleId"];
  //
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   await initLookupData();
  //   if (arguments.containsKey("analysisId")) {
  //     analysisId = (arguments)["analysisId"];
  //     await getData();
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  initLookupData() async {
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.dataListMetaData + expeditionId);
    setState(() {
      _analysisTypeList.addAll(response);
    });
  }

  getData() async {
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.analysisDocument + analysisId);

    List picturesList = response["pictures"] ?? [];

    List<String> urlList = <String>[];
    List<File> fileList = <File>[];
    print(picturesList);
    for (int i = 0; i < picturesList.length; i++) {
      GenerateImageUrl generateImageUrl = GenerateImageUrl();
      String url = await generateImageUrl.getImageUrl(picturesList[i]);
      urlList.add(url);
    }
    for (var i = 0; i < urlList.length; i++) {
      fileList.add(File('/path/to/my/file.txt'));
    }

    setState(() {
      name = response["name"];
      protocol = response["protocol"] ?? "";
      _analysisTypeValue = response["dataTypeId"];
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
      for (var i = 0; i < picturesList.length; i++) {
        _s3KeysList.add(picturesList[i]);
      }
      _photosUrls.addAll(urlList);
      _photos.addAll(fileList);
      for (var i = 0; i < urlList.length; i++) {
        _photosStatus.add(PhotoStatus.LOADED);
        _photosSources.add(PhotoSource.NETWORK);
        _galleryItems.add(GalleryItem(
          id: "1",
          resource: "image",
          isSvg: false,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: primaryColor,
              iconTheme: IconThemeData(color: Colors.white),

              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                  child: IconButton(
                      onPressed: (){
                        setState(() {
                          isSaved = true;
                        });
                        if (_formKey.currentState!.validate()) {
                          saveArea();
                        }
                      },
                      icon: Icon(Icons.save, size: 30,)
                  ),
                )
              ],
              title: const Text('Analysis', style: TextStyle(color: Colors.white),),
            ),
            body: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(15.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: formUI(),
                ),
              ),
            ),
            // bottomNavigationBar: Container(
            //   height: 50,
            //   color: ColorUtils.secondaryColor,
            //   child: InkWell(
            //     onTap: () {
            //       if (_formKey.currentState!.validate()) {
            //         saveArea();
            //       }
            //     },
            //     child: const Center(
            //       child: Text(
            //         "Save",
            //         textAlign: TextAlign.center,
            //         style: TextStyle(color: Colors.white, fontSize: 18),
            //       ),
            //     ),
            //   ),
            // )
        ),
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
    int index = _analysisTypeList.indexWhere((f) => f['_key'] == newValue);

    setState(() {
      _analysisTypeValue = newValue;
      _fieldsList.clear();
      _fieldsList.addAll(_analysisTypeList[index]["fieldsList"]);
      protocol = _analysisTypeList[index]["protocol"];
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
        "${AppConsts.baseURL}${AppConsts.generateNameAnalysis}$sampleId/$_analysisTypeValue");
    setState(() {
      _isLoading = false;
      name = sampleName;
    });
  }

  Widget formUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReadOnlyField(title: 'Analysis', value: name),
        ReadOnlyField(title: 'Protocol', value: protocol),
        SizedBox(height: 15,),
        AppDropDownKeyNameField(
            labelText: 'Type *',
            hintText: 'Type *',
            value: _analysisTypeValue,
            items: _analysisTypeList,
            onChanged: _isTypeDropdownEnabled ? onTypeChange : null,
          validator: (value) {
            if (_analysisTypeValue == null) {
              return 'Please select an option';
            }
            return null; // Return null if the value is valid
          },

        ),
        const SizedBox(height: 5,),

        // DropdownButtonFormField(
        //   value: _analysisTypeValue,
        //   items: _analysisTypeList
        //       .map((value) => DropdownMenuItem(
        //             value: value["_key"],
        //             child: Text(value["name"]!),
        //           ))
        //       .toList(),
        //   onChanged: _isTypeDropdownEnabled ? onTypeChange : null,
        //   decoration: const InputDecoration(
        //     labelText: 'Type *',
        //   ),
        //   validator: (value) {
        //     if (_analysisTypeValue == null) {
        //       return 'Please select an option';
        //     }
        //     return null; // Return null if the value is valid
        //   },
        // ),

        if (_analysisTypeValue != null) ...[
          if (_fieldsList.contains(Enum.dataFields["STAMP"])) ...stampWidgets(),
          if (_fieldsList.contains(Enum.dataFields["CM"]))
            // TextFormField(
            //   decoration: const InputDecoration(
            //     labelText: 'Cm',
            //   ),
            //   controller: _cmController,
            // ),
            AppFormTextField(
              labelText: 'Cm',
              hintText: 'Cm',
              controller: _cmController,
              validator: (value){
                if((value == null || value.isEmpty) && isSaved == true){
                  return "Please Enter Cm";
                } return null;
              },
            ),
          const SizedBox(height: 5,),

          if (_fieldsList.contains(Enum.dataFields["COMMENT"]))
            // TextFormField(
            //   decoration: const InputDecoration(
            //     labelText: 'Comment',
            //   ),
            //   controller: _commentController,
            // ),
            AppFormTextField(
              labelText: 'Comment',
              hintText: 'Comment',
              controller: _commentController,
              validator: (value){
                if((value == null || value.isEmpty) && isSaved == true){
                  return "Please Enter Comment";
                } return null;
              },
            ),
          const SizedBox(height: 5,),

          if (_fieldsList.contains(Enum.dataFields["LINK"]))
            // TextFormField(
            //   decoration: const InputDecoration(
            //     labelText: 'Link',
            //   ),
            //   controller: _linkController,
            // ),
            AppFormTextField(
              labelText: 'Link',
              hintText: 'Link',
              controller: _linkController,
              validator: (value){
                if((value == null || value.isEmpty) && isSaved == true){
                  return "Please Enter Link";
                } return null;
              },
            ),
          const SizedBox(height: 5,),

          if (_fieldsList.contains(Enum.dataFields["PICTURE"]))
            ImageUpload(
                folderName: PictureFolderName.analysis.toString().split('.')[1],
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final obj = {
      "areaId": areaId,
      "diveId": diveId,
      "sampleId": sampleId,
      "expeditionId": expeditionId,
      "locationId": locationId,
      "name": name,
      "protocol": protocol,
      "dataTypeId": _analysisTypeValue,
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
    if (analysisId.isNotEmpty) {
      obj["_key"] = analysisId;
    }
    // save to db
    final response = await ApiProvider()
        .post(AppConsts.baseURL + AppConsts.saveAnalysis, obj);
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context, MaterialPageRoute(builder: (context) => Areas()));
  }
}
