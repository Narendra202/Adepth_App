import 'dart:io';

import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/platforms/platforms.dart';
import 'package:expedition_poc/services/generate_image_url.dart';
import 'package:expedition_poc/services/location_service.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/utils/AppSigninTextFormField.dart';
import 'package:expedition_poc/utils/AppTextFormField.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:expedition_poc/widgets/gallery_item.dart';
import 'package:expedition_poc/widgets/imageUpload.dart';
import 'package:expedition_poc/widgets/multiSelectWidget.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import '../../../../../../../utils/colors.dart';

class SampleForm extends StatefulWidget {
  const SampleForm({super.key, this.arguments});

  final arguments;

  @override
  _SampleFormState createState() => _SampleFormState();
}

class _SampleFormState extends State<SampleForm> {
  String sampleId = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isSaved = false;

  late String areaId, expeditionId, diveId, locationId;

  String name = "";
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _depthController = TextEditingController();
  final _commentController = TextEditingController();
  final DateTime _datetime = DateTime.now();
  final _date = TextEditingController();
  final _timeController = TextEditingController();
  late String _hour, _minute, _time;
  TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);

  var _typeValue;
  final List _typeList = [];
  List<String> _toolsItems = [];
  final List toolsItemList = [];

  final List<File> _photos = <File>[];
  final List<String> _photosUrls = <String>[];
  final List<String> _s3KeysList = <String>[];

  final List<PhotoSource> _photosSources = <PhotoSource>[];
  final List<PhotoStatus> _photosStatus = <PhotoStatus>[];
  final List<GalleryItem> _galleryItems = <GalleryItem>[];

  final MapController _mapController = MapController();
  LocationData? _currentLocation;
  LatLng? markerLatLong;
  double _mapHeight = 300.0;

  bool _isTypeDropdownEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Code to execute after the build is complete
      _getLocation();
      _initializeData();

    });
    _date.text = "${_datetime.month}/${_datetime.day}/${_datetime.year}";
    _timeController.text = "${_datetime.hour}:${_datetime.minute}";
  }

  Future<void> _initializeData() async {
    final arguments = widget.arguments;
    // final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    diveId = (arguments)["diveId"];
    expeditionId = (arguments)["expeditionId"];
    areaId = (arguments)["areaId"];
    locationId = (arguments)["locationId"];

    // api call's
    setState(() {
      _isLoading = true;
    });
    await initLookupData();
    if (arguments.containsKey("sampleId")) {
      sampleId = (arguments)["sampleId"];
      await getData();
    }
    setState(() {
      _isLoading = false;
    });
  }


  Future<void> _getLocation() async {
    LocationData locationData = await LocationService().getLocation();

    if (locationData != null) {
      setState(() {
        _currentLocation = locationData;
        _mapController.move(
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            14.0);
      });
    }
  }

  showLatLongMarker(bool isShowWarning) {
    if (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty) {
      if (isShowWarning) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please fill Latitude and Longitude'),
              duration: Duration(seconds: 3)),
        );
      }
      return;
    }
    setState(() {
      markerLatLong = null;
    });
    double lat = double.parse(_latitudeController.text);
    double long = double.parse(_longitudeController.text);
    bool isLatLongValid = LocationService().isLatLngValid(lat, long);
    if (!isLatLongValid && isShowWarning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Invalid Latitude Longitude'),
            duration: Duration(seconds: 3)),
      );
    }
    if (!isLatLongValid) {
      return;
    }
    setState(() {
      markerLatLong = LatLng(lat, long);
      _mapController.move(markerLatLong!, 12.0);
    });
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _depthController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // @override
  // void didChangeDependencies() async {
  //   super.didChangeDependencies();
  //   final arguments = ModalRoute.of(context)!.settings.arguments as Map;
  //   diveId = (arguments)["diveId"];
  //   expeditionId = (arguments)["expeditionId"];
  //   areaId = (arguments)["areaId"];
  //   locationId = (arguments)["locationId"];
  //
  //   // api call's
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   await initLookupData();
  //   if (arguments.containsKey("sampleId")) {
  //     sampleId = (arguments)["sampleId"];
  //     await getData();
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  initLookupData() async {
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.sampleMetaData + diveId);
    setState(() {
      _typeList.clear();
      _typeList.addAll(response["sampleTypesList"]);
      toolsItemList.addAll(response["toolsList"]);
    });
  }

  getData() async {
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.sampleDocument + sampleId);

    List picturesList = response["pictures"] ?? [];

    List<String> urlList = <String>[];
    List<File> fileList = <File>[];
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
      _typeValue = response["typeId"];
      _date.text = response["date"] ?? _date.text;
      _timeController.text = response["time"] ?? _timeController.text;
      _depthController.text = response["depth"] ?? "";
      _latitudeController.text = response["latitude"] ?? "";
      _longitudeController.text = response["longitude"] ?? "";
      _commentController.text = response["comment"] ?? "";
      _isTypeDropdownEnabled = false;

      if (response["toolsList"] != null) {
        for (int i = 0; i < response["toolsList"].length; i++) {
          _toolsItems.add(response["toolsList"][i].toString());
        }
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
    showLatLongMarker(false);
  }

  generateName() async {
    setState(() {
      _isLoading = true;
    });
    String sampleName = await ApiProvider().get(
        "${AppConsts.baseURL}${AppConsts.generateNameSample}$diveId/$_typeValue");
    setState(() {
      _isLoading = false;
      name = sampleName;
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
                          saveDive();
                        }
                      },
                      icon: const Icon(Icons.save, size: 30,)
                  ),
                )
              ],

              title: const Text('Sample',style: TextStyle(color: Colors.white),),
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
            //         saveDive();
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

  Future<void> _selectDate(BuildContext context, DateTime datetime,
      TextEditingController date) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != datetime) {
      setState(() {
        datetime = picked;
      });
      date.text = "${picked.month}/${picked.day}/${picked.year}";
    }
  }

  void _increaseMapHeight() {
    if (_mapHeight < 700) {
      setState(() {
        _mapHeight += 50.0;
      });
    }
  }

  void _decreaseMapHeight() {
    if (_mapHeight > 200) {
      setState(() {
        _mapHeight -= 50.0;
      });
    }
  }

  Widget formUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DropdownButtonFormField(
        //   value: _typeValue,
        //   items: _typeList
        //       .map((value) => DropdownMenuItem(
        //             value: value["_key"],
        //             child: Text(value["name"]!),
        //           ))
        //       .toList(),
        //   onChanged: _isTypeDropdownEnabled
        //       ? (newValue) {
        //           setState(() {
        //             _typeValue = newValue.toString();
        //           });
        //           generateName();
        //         }
        //       : null,
        //   decoration: const InputDecoration(
        //     labelText: 'Type *',
        //   ),
        //   validator: (value) {
        //     if (_typeValue == null) {
        //       return 'Please select an option';
        //     }
        //     return null; // Return null if the value is valid
        //   },
        // ),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   children: [
        //     Expanded(
        //       child: TextFormField(
        //         controller: _date,
        //         decoration: const InputDecoration(
        //             labelText: "Date",
        //             suffixIcon: Padding(
        //               padding: EdgeInsets.only(
        //                   top: 15), // add padding to adjust icon
        //               child: Icon(Icons.calendar_month),
        //             )),
        //         keyboardType: TextInputType.datetime,
        //         readOnly: true,
        //         onTap: () => _selectDate(context, _datetime, _date),
        //       ),
        //     ),
        //     Expanded(
        //         child: Padding(
        //       padding: const EdgeInsets.only(left: 20),
        //       child: InkWell(
        //         onTap: () {
        //           _selectTime(context, _timeController);
        //         },
        //         child: TextFormField(
        //           decoration: const InputDecoration(
        //               labelText: 'Time',
        //               suffixIcon: Padding(
        //                 padding: EdgeInsets.only(top: 15),
        //                 // add padding to adjust icon
        //                 child: Icon(Icons.watch_later_sharp),
        //               )),
        //           enabled: false,
        //           keyboardType: TextInputType.text,
        //           controller: _timeController,
        //         ),
        //       ),
        //     )),
        //   ],
        // ),

        // TextFormField(
        //   decoration: const InputDecoration(
        //     prefix: Text('-'), // add hyphen prefix
        //     labelText: 'Depth (m)',
        //   ),
        //   keyboardType: TextInputType.number,
        //   controller: _depthController,
        // ),

        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Latitude',
        //   ),
        //   keyboardType: TextInputType.number,
        //   controller: _latitudeController,
        // ),
        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Longitude',
        //   ),
        //   keyboardType: TextInputType.number,
        //   controller: _longitudeController,
        // ),

    // TextFormField(
    //   decoration: const InputDecoration(
    //     labelText: 'Comment',
    //   ),
    //   controller: _commentController,
    // ),

        ReadOnlyField(title: 'Sample', value: name),
        const SizedBox(height: 15,),
        AppDropDownKeyNameField(
          value: _typeValue,
          items: _typeList,
          onChanged: _isTypeDropdownEnabled
              ? (newValue) {
            setState(() {
              _typeValue = newValue.toString();
            });
            generateName();
          }
          : null,
          labelText: 'Type',
          hintText: 'Type',
          validator: (value){
            if((value == null || value.isEmpty) && isSaved == true){
              return 'Please Select Option';
            } return null;
          },
        ),

        SizedBox(height: 10,),
        Row(
          children: [
            Expanded(
              child: AppFormTextField(
                labelText: 'Date',
                hintText: 'Date',
                controller: _date,
                suffixIcon: Icons.calendar_month,
                keyboardInputType: TextInputType.datetime,
                readOnly: true,
                onTep : () => _selectDate(context, _datetime, _date),
                validator: (value){
                  if((value == null || value.isEmpty) && isSaved == true){
                    return 'Please Select Date';
                  } return null;
                },
               ),
            ),
            SizedBox(width: 5,),
            Expanded(
              child: AppFormTextField(
                labelText: 'Time',
                hintText: 'Time',
                controller: _timeController,
                suffixIcon: Icons.watch_later_sharp,
                keyboardInputType: TextInputType.text,
                readOnly: true,
                onTep : () => _selectTime(context, _timeController),
                validator: (value){
                  if((value == null || value.isEmpty) && isSaved == true){
                    return 'Please Select Time';
                  } return null;
                },
              ),
            )
          ],
        ),

        AppTextFormFieldFunc('-', 'Depth (m)', _depthController, TextInputType.number),

        MultiSelectWidget(
            name: 'Tools', itemsList: toolsItemList, items: _toolsItems
        ),

       ResponsiveApp(
           mobile: Column(
             children: [
               AppTextFormFieldFunc('', 'Latitude', _latitudeController, TextInputType.number),
               AppTextFormFieldFunc('', 'Longitude', _longitudeController, TextInputType.number),
             ],
           ),
           tablet: Row(
               children: [
                 Expanded(child: AppTextFormFieldFunc('', 'Latitude', _latitudeController, TextInputType.number),),
                 SizedBox(width: 5,),
                 Expanded(child: AppTextFormFieldFunc('', 'Longitude', _longitudeController, TextInputType.number),),
               ]
           ),
           desktop: Row(
             children: [
               Expanded(child: AppTextFormFieldFunc('', 'Latitude', _latitudeController, TextInputType.number),),
               SizedBox(width: 5,),
               Expanded(child: AppTextFormFieldFunc('', 'Longitude', _longitudeController, TextInputType.number),),
             ]
           )
       ),


        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
                onPressed: () {
                  showLatLongMarker(true);
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.white,
                    ),
                    SizedBox(
                        width: 5), // add some space between the icon and text
                    Text('Show on Map'),
                  ],
                )),
            Row(
              children: [
                IconButton(
                    onPressed: _increaseMapHeight, icon: const Icon(Icons.add)),
                IconButton(
                    onPressed: _decreaseMapHeight,
                    icon: const Icon(Icons.remove))
              ],
            )
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Stack(
          children: [
            SizedBox(
              // width: 250,
              width: MediaQuery.of(context).size.width,
              height: _mapHeight,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: LatLng(40.0, -120.0),
                  zoom: 8.0,
                  interactiveFlags:
                      InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      if (_currentLocation != null)
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(_currentLocation!.latitude!,
                              _currentLocation!.longitude!),
                          builder: (ctx) =>
                              const Icon(Icons.location_on, color: Colors.red),
                        ),
                      if (markerLatLong != null)
                        Marker(
                          width: 100.0,
                          height: 100.0,
                          point: LatLng(markerLatLong!.latitude,
                              markerLatLong!.longitude),
                          builder: (ctx) => const Icon(Icons.location_on,
                              color: ColorUtils.primaryColor),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 10,
                right: 10,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: ColorUtils.secondaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.location_searching),
                    color: Colors.white,
                    onPressed: () {
                      _getLocation();
                    },
                  ),
                ))
          ],
        ),
        const SizedBox(
          height: 20,
        ),


        AppTextFormFieldFunc('', 'Comment', _commentController, TextInputType.text),


        //
        ImageUpload(
            folderName: PictureFolderName.sample.toString().split('.')[1],
            photos: _photos,
            photosUrls: _photosUrls,
            s3KeysList: _s3KeysList,
            photosSources: _photosSources,
            photosStatus: _photosStatus),
      ],
    );
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController time) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
        _hour = selectedTime.hour.toString();
        _minute = selectedTime.minute.toString();
        if (_hour.length == 1) {
          _hour = "0$_hour";
        }
        if (_minute.length == 1) {
          _minute = "0$_minute";
        }
        _time = '$_hour:$_minute';
        time.text = _time;
      });
    }
  }

  AppTextFormFieldFunc(prefix , labelText, controller, keyboardType){
    return   AppFormTextField(
      prefix: Text(prefix),
      labelText: labelText + ' *',
      controller: controller,
      keyboardInputType: keyboardType,
      validator: (value){
        if((value == null || value.isEmpty) && isSaved == true){
          return 'Please Enter $labelText *';
        } return null;
      },
    );
  }


  Future saveDive() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final obj = {
      "areaId": areaId,
      "expeditionId": expeditionId,
      "diveId": diveId,
      "locationId": locationId,
      "name": name,
      "date": _date.text,
      "time": _timeController.text,
      "depth": _depthController.text,
      'toolsList': _toolsItems,
      "latitude": _latitudeController.text,
      'longitude': _longitudeController.text,
      'typeId': _typeValue,
      'comment': _commentController.text,
      'pictures': _s3KeysList
    };

    if (_currentLocation != null) {
      obj["currentLocation"] = {
        "latitude": _currentLocation!.latitude!,
        "longitude": _currentLocation!.longitude!
      };
    }
    if (sampleId.isNotEmpty) {
      obj["_key"] = sampleId;
    }

    // save to db
    final response =
        await ApiProvider().post(AppConsts.baseURL + AppConsts.saveSample, obj);

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(
        context, MaterialPageRoute(builder: (context) => Platforms()));
  }
}
