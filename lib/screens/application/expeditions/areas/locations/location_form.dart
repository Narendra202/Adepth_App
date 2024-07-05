import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/areas.dart';
import 'package:expedition_poc/services/location_service.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/utils/AppTextFormField.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../../../../../utils/colors.dart';

class LocationForm extends StatefulWidget {
  LocationForm({super.key,  this.arguments , this.formData});

  final arguments;
  Function(dynamic)? formData;

  @override
  _LocationFormState createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  String locationId = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isSaved = false;
  String name = "";
  final _operationalDaysController = TextEditingController();
  final _purposeController = TextEditingController();
  final DateTime _startDate_date = DateTime.now();
  final DateTime _endDate_date = DateTime.now();
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _targetTypeController = TextEditingController();
  final _depthController = TextEditingController();

  late String expeditionId, areaId;

  late String _hour, _minute, _time;
  TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);

  final MapController _mapController = MapController();
  LocationData? _currentLocation;
  LatLng? markerLatLong;
  double _mapHeight = 300.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Code to execute after the build is complete
      _getLocation();
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final arguments = widget.arguments;
    // final arguments = ModalRoute.of(context)!.settings.arguments;
    expeditionId = (arguments as Map)["expeditionId"];
    areaId = arguments["areaId"];
    setState(() {
      _isLoading = true;
    });
    if (arguments.containsKey("locationId")) {
      locationId = arguments["locationId"];
      await getData();
    } else {
      name = await ApiProvider()
          .get("${AppConsts.baseURL}${AppConsts.generateNameLocation}$areaId");
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

  @override
  void dispose() {
    _operationalDaysController.dispose();
    _purposeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  // @override
  // void didChangeDependencies() async {
  //   super.didChangeDependencies();
  //   final arguments = ModalRoute.of(context)!.settings.arguments;
  //   expeditionId = (arguments as Map)["expeditionId"];
  //   areaId = arguments["areaId"];
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   if (arguments.containsKey("locationId")) {
  //     locationId = arguments["locationId"];
  //     await getData();
  //   } else {
  //     name = await ApiProvider()
  //         .get("${AppConsts.baseURL}${AppConsts.generateNameLocation}$areaId");
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  getData() async {
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.locationDocument + locationId);
    setState(() {
      name = response["name"];
      _operationalDaysController.text = response["operationalDays"] ?? "";
      _purposeController.text = response["purpose"] ?? "";
      _targetTypeController.text = response["targetType"] ?? "";
      _depthController.text = response["depth"] ?? "";
      _startDate.text = response["startDate"] ?? "";
      _endDate.text = response["endDate"] ?? "";
      _latitudeController.text = response["latitude"] ?? "";
      _longitudeController.text = response["longitude"] ?? "";
    });

    showLatLongMarker(false);
  }

  showLatLongMarker(bool isShowWarning) {
    if (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty) {
      if(isShowWarning){
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
              title: const Text('Location' , style: TextStyle(color: Colors.white),),
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

  Widget formUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReadOnlyField(title: 'Location', value: name),
        const SizedBox(
          height: 5,
        ),
        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Operational Days',
        //   ),
        //   keyboardType: TextInputType.number,
        //   controller: _operationalDaysController,
        // ),

        // TextFormField(
        //   controller: _startDate,
        //   decoration: const InputDecoration(
        //       labelText: "Start Date",
        //       suffixIcon: Padding(
        //         padding: EdgeInsets.only(top: 15),
        //         // add padding to adjust icon
        //         child: Icon(Icons.calendar_month),
        //       )),
        //   keyboardType: TextInputType.datetime,
        //   readOnly: true,
        //   onTap: () => _selectDate(context, _startDate_date, _startDate),
        // ),

        // TextFormField(
        //   controller: _endDate,
        //   decoration: const InputDecoration(
        //       labelText: "End Date",
        //       suffixIcon: Padding(
        //         padding: EdgeInsets.only(top: 15),
        //         // add padding to adjust icon
        //         child: Icon(Icons.calendar_month),
        //       )),
        //   keyboardType: TextInputType.datetime,
        //   readOnly: true,
        //   onTap: () => _selectDate(context, _endDate_date, _endDate),
        // ),

        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Purpose',
        //   ),
        //   controller: _purposeController,
        // ),
        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Target',
        //   ),
        //   controller: _targetTypeController,
        // ),

        // TextFormField(
        //   decoration: const InputDecoration(
        //     prefix: Text('-'), // add hyphen prefix
        //     labelText: 'Depth (m)',
        //   ),
        //   keyboardType: TextInputType.number,
        //   controller: _depthController,
        // ),

        // const SizedBox(
        //   height: 5,
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


        AppTextFormFieldFunc('Operational Days', _operationalDaysController, TextInputType.number),

        ResponsiveApp(
            mobile: Column(
              children: [
                AppFormTextField(
                  labelText: 'Start Date *',
                  hintText: 'Start Date *',
                  controller: _startDate,
                  keyboardInputType: TextInputType.datetime,
                  readOnly: true,
                  suffixIcon:Icons.calendar_month,
                  validator: (value){
                    if((value == null || value.isEmpty) && isSaved == true){
                      return "Please Select Start Date *";
                    } return null;
                  },
                  onTep: () => _selectDate(context, _startDate_date, _startDate),
                ),

                AppFormTextField(
                  labelText: 'End Date *',
                  hintText: 'End Date *',
                  controller: _endDate,
                  keyboardInputType: TextInputType.datetime,
                  readOnly: true,
                  suffixIcon:Icons.calendar_month,
                  validator: (value){
                    if((value == null || value.isEmpty) && isSaved == true){
                      return "Please Select End Date *";
                    } return null;
                  },
                  onTep: () => _selectDate(context, _endDate_date, _endDate),
                ),
              ],
            ), 
            tablet: Row(
              children: [
                Expanded(
                  child: AppFormTextField(
                    labelText: 'Start Date *',
                    hintText: 'Start Date *',
                    controller: _startDate,
                    keyboardInputType: TextInputType.datetime,
                    readOnly: true,
                    suffixIcon:Icons.calendar_month,
                    validator: (value){
                      if((value == null || value.isEmpty) && isSaved == true){
                        return "Please Enter Start Date *";
                      } return null;
                    },
                    onTep: () => _selectDate(context, _startDate_date, _startDate),
                  ),
                ),
                SizedBox(width: 5,),
                Expanded(
                  child: AppFormTextField(
                    labelText: 'End Date *',
                    hintText: 'End Date *',
                    controller: _endDate,
                    keyboardInputType: TextInputType.datetime,
                    readOnly: true,
                    suffixIcon:Icons.calendar_month,
                    validator: (value){
                      if((value == null || value.isEmpty) && isSaved == true){
                        return "Please Enter End Date *";
                      } return null;
                    },
                    onTep: () => _selectDate(context, _endDate_date, _endDate),
                  ),
                ),

              ],
            ),
            desktop: Row(
              children: [
                Expanded(
                  child: AppFormTextField(
                    labelText: 'Start Date *',
                    hintText: 'Start Date *',
                    controller: _startDate,
                    keyboardInputType: TextInputType.datetime,
                    readOnly: true,
                    suffixIcon:Icons.calendar_month,
                    validator: (value){
                      if((value == null || value.isEmpty) && isSaved == true){
                        return "Please Enter Start Date *";
                      } return null;
                    },
                    onTep: () => _selectDate(context, _startDate_date, _startDate),
                  ),
                ),
                SizedBox(width: 5,),
                Expanded(
                  child: AppFormTextField(
                    labelText: 'End Date *',
                    hintText: 'End Date *',
                    controller: _endDate,
                    keyboardInputType: TextInputType.datetime,
                    readOnly: true,
                    suffixIcon:Icons.calendar_month,
                    validator: (value){
                      if((value == null || value.isEmpty) && isSaved == true){
                        return "Please Enter End Date *";
                      } return null;
                    },
                    onTep: () => _selectDate(context, _endDate_date, _endDate),
                  ),
                ),

              ],
            )
        ),

        ResponsiveApp(
            mobile: Column(
              children: [
                AppTextFormFieldFunc('Purpose', _purposeController, TextInputType.text),
                AppTextFormFieldFunc('Target', _targetTypeController, TextInputType.text),
              ],
            ),
            tablet: Row(
              children: [
                Expanded(child: AppTextFormFieldFunc('Purpose', _purposeController, TextInputType.text),),
                SizedBox(width: 5,),
                Expanded(child: AppTextFormFieldFunc('Target', _targetTypeController, TextInputType.text),)
              ],
            ),
            desktop: Row(
              children: [
                Expanded(child: AppTextFormFieldFunc('Purpose', _purposeController, TextInputType.text),),
                SizedBox(width: 5,),
                Expanded(child: AppTextFormFieldFunc('Target', _targetTypeController, TextInputType.text),)
              ],
            )
        ),

        AppTextFormFieldFunc('Depth (m)', _depthController, TextInputType.number),


        ResponsiveApp(
            mobile: Column(
              children: [
                AppTextFormFieldFunc('Latitude', _latitudeController, TextInputType.number),
                AppTextFormFieldFunc('Longitude', _longitudeController, TextInputType.number),
              ],
            ),
            tablet: Row(
              children: [
                Expanded(child: AppTextFormFieldFunc('Latitude', _latitudeController, TextInputType.number),),
                SizedBox(width: 5,),
                Expanded(child: AppTextFormFieldFunc('Longitude', _longitudeController, TextInputType.number),)
              ],
            ),
            desktop: Row(
              children: [
                Expanded(child: AppTextFormFieldFunc('Latitude', _latitudeController, TextInputType.number),),
                SizedBox(width: 5,),
                Expanded(child: AppTextFormFieldFunc('Longitude', _longitudeController, TextInputType.number),)
              ],
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
              width: 250,
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
      ],
    );
  }

  AppTextFormFieldFunc(labelText, controller , keyboardType){
    return  AppFormTextField(
      labelText: labelText + ' *',
      controller: controller,
      keyboardInputType: keyboardType,
      validator: (value){
        if((value == null || value.isEmpty) && isSaved == true){
          return "Please Enter $labelText *";
        } return null;
      },
    );
  }
  Future saveArea() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> obj = {
      "expeditionId": expeditionId,
      "areaId": areaId,
      "name": name,
      "operationalDays": _operationalDaysController.text,
      "startDate": _startDate.text,
      "endDate": _endDate.text,
      "purpose": _purposeController.text,
      "targetType": _targetTypeController.text,
      "depth": _depthController.text,
      "latitude": _latitudeController.text,
      'longitude': _longitudeController.text,
    };
    if (locationId.isNotEmpty) {
      obj["_key"] = locationId;
    }
    // save to db
    final response = await ApiProvider()
        .post(AppConsts.baseURL + AppConsts.saveLocation, obj);

    if(widget.arguments['diveCount'] != null && widget.arguments['sampleCount'] != null && widget.arguments['status'] != null) {
      obj['diveCount'] = widget.arguments['diveCount'];
      obj['sampleCount'] = widget.arguments['sampleCount'];
      obj['status'] = widget.arguments['status'];
    }
    else{
      obj['diveCount'] = 0;
      obj['sampleCount'] = 0;
      obj['status'] = 'onLocation';

    }

    if(response != null) {
      obj['_key'] = response['_key'];
    }

    setState(() {
      _isLoading = false;
    });

    widget.formData!(obj);
    // Navigator.pop(context, MaterialPageRoute(builder: (context) => Areas()));
  }
}
