import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/areas/areas.dart';
import 'package:expedition_poc/services/location_service.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/utils/AppTextFormField.dart';
import 'package:expedition_poc/utils/colors.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

class AreaForm extends StatefulWidget {
  const AreaForm({super.key, this.arguments});

  final arguments;
  @override
  _AreaFormState createState() => _AreaFormState();
}

class _AreaFormState extends State<AreaForm> {
  String areaId = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isSaved = false;

  String name = "";
  final _operationalDaysController = TextEditingController();
  final _targetNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _purposeController = TextEditingController();
  String _geologicalCertainityValue = "1", _operationalCertainityValue = "1";

  late String expeditionId;

  final _certainityList = [
    {"_key": "1", "name": "Low"},
    {"_key": "2", "name": "Medium"},
    {"_key": "3", "name": "High"},
  ];

  final MapController _mapController = MapController();
  LocationData? _currentLocation;
  LatLng? markerLatLong;
  final double _mapHeight = 300.0;
  double _mapWidth = 0;

  bool isDrawingEnabled = false;
  List<LatLng> areaPoints = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Code to execute after the build is complete
      _getLocation();
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    _mapWidth = 250;
    final arguments = widget.arguments;
    // final arguments = ModalRoute.of(context)!.settings.arguments;
    expeditionId = (arguments as Map)["expeditionId"];
    setState(() {
      _isLoading = true;
    });
    if (arguments.containsKey("areaId")) {
      areaId = (arguments)["areaId"];
      await getData();
    } else {
      name = await ApiProvider().get(
          "${AppConsts.baseURL}${AppConsts.generateNameArea}$expeditionId");
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
    _targetNameController.dispose();
    _descriptionController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // _mapWidth = 250;
    // final arguments = ModalRoute.of(context)!.settings.arguments;
    // expeditionId = (arguments as Map)["expeditionId"];
    // setState(() {
    //   _isLoading = true;
    // });
    // if (arguments.containsKey("areaId")) {
    //   areaId = (arguments)["areaId"];
    //   await getData();
    // } else {
    //   name = await ApiProvider().get(
    //       "${AppConsts.baseURL}${AppConsts.generateNameArea}$expeditionId");
    // }
    // setState(() {
    //   _isLoading = false;
    // });
  }

  getData() async {
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.areaDocument + areaId);
    setState(() {
      name = response["name"];
      _geologicalCertainityValue = response["geologicalCertainityId"];
      _operationalCertainityValue = response["operationalCertainityId"];
      _operationalDaysController.text = response["operationalDays"] ?? "";
      _targetNameController.text = response["targetName"] ?? "";
      _purposeController.text = response["purpose"] ?? "";
      _descriptionController.text = response["description"] ?? "";
      if(response["areaGeometry"] != null){
        List<LatLng> points = [];
        for (var location in response["areaGeometry"]) {
          points.add(LatLng(location[0], location[1]));
        }
        areaPoints.addAll(points);
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
              iconTheme: const IconThemeData(color: Colors.white),

              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                  child: IconButton(
                      onPressed: (){
                        setState(() {
                          isSaved = true;
                        });

                        if (_formKey.currentState!.validate()) {
                          // final formData = _formKey.currentState!.;
                          saveArea();
                        }
                      },
                      icon: const Icon(Icons.save, size: 30,)
                  ),
                )
              ],
              title: const Text('Area',style: TextStyle(color: Colors.white),),

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

  Widget formUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReadOnlyField(title: 'Area', value: name),

        // DropdownButtonFormField<String>(
        //   value: _geologicalCertainityValue,
        //   items: _certainityList
        //       .map((value) => DropdownMenuItem(
        //             value: value["_key"],
        //             child: Text(value["name"]!),
        //           ))
        //       .toList(),
        //   onChanged: (newValue) {
        //     setState(() {
        //       _geologicalCertainityValue = newValue!;
        //     });
        //   },
        //   decoration: const InputDecoration(
        //     labelText: 'Geological Certainty',
        //   ),
        // ),
        // DropdownButtonFormField<String>(
        //   value: _operationalCertainityValue,
        //   items: _certainityList
        //       .map((value) => DropdownMenuItem(
        //             value: value["_key"],
        //             child: Text(value["name"]!),
        //           ))
        //       .toList(),
        //   onChanged: (newValue) {
        //     setState(() {
        //       _operationalCertainityValue = newValue!;
        //     });
        //   },
        //   decoration: const InputDecoration(
        //     labelText: 'Operational Certainty',
        //   ),
        // ),
        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Operational Days',
        //   ),
        //   keyboardType: TextInputType.number,
        //   controller: _operationalDaysController,
        // ),
        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Target',
        //   ),
        //   controller: _targetNameController,
        // ),
        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Purpose',
        //   ),
        //   controller: _purposeController,
        // ),
        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Description',
        //   ),
        //   controller: _descriptionController,
        // ),
        const SizedBox(height: 20,),

        AppDropDownKeyNameField(
            labelText: 'Geological Certainty',
            hintText: 'Geological Certainty',
            value: _geologicalCertainityValue,
            items: _certainityList,
            onChanged: (newValue) {
              setState(() {
                _geologicalCertainityValue = newValue!;
              });
            }
        ),
        const SizedBox(height: 10,),

        AppDropDownKeyNameField(
            labelText: 'Operational Certainty',
            hintText: 'Operational Certainty',
            value: _operationalCertainityValue,
            items: _certainityList,
            onChanged: (newValue) {
              setState(() {
                _operationalCertainityValue = newValue!;
              });
            }
        ),
        const SizedBox(height: 10,),
        ResponsiveApp(
            mobile: Column(
              children: [
                AppFormTextField(
                  labelText: 'Operational Days *',
                  hintText: 'Operational Days *',
                  keyboardInputType: TextInputType.number,
                  controller: _operationalDaysController,
                  validator: (value){
                    if((value == null || value.isEmpty) && isSaved == true){
                      return "Please Enter Operational Days *";
                    } return null;
                  },
                ),
                AppFormTextField(
                  labelText: 'Target *',
                  hintText: 'Target *',
                  controller: _targetNameController,
                  validator: (value){
                    if((value == null || value.isEmpty) && isSaved == true){
                      return "Please Enter Target *";
                    } return null;
                  },
                ),
              ],
            ),
            tablet: Row(
              children: [
                Expanded(
                  child: AppFormTextField(
                    labelText: 'Operational Days *',
                    hintText: 'Operational Days *',
                    keyboardInputType: TextInputType.number,
                    controller: _operationalDaysController,
                    validator: (value){
                      if((value == null || value.isEmpty) && isSaved == true){
                        return "Please Enter Operational Days *";
                      } return null;
                    },
                  ),
                ),
                SizedBox(width: 5,),
                Expanded(
                  child: AppFormTextField(
                    labelText: 'Target *',
                    hintText: 'Target *',
                    controller: _targetNameController,
                    validator: (value){
                      if((value == null || value.isEmpty) && isSaved == true){
                        return "Please Enter Target *";
                      } return null;
                    },
                  ),
                ),
              ],
            ),
            desktop: Row(
              children: [
                Expanded(
                  child: AppFormTextField(
                    labelText: 'Operational Days *',
                    hintText: 'Operational Days *',
                    keyboardInputType: TextInputType.number,
                    controller: _operationalDaysController,
                    validator: (value){
                      if((value == null || value.isEmpty) && isSaved == true){
                        return "Please Enter Operational Days *";
                      } return null;
                    },
                  ),
                ),
                SizedBox(width: 5,),
                Expanded(
                  child: AppFormTextField(
                    labelText: 'Target *',
                    hintText: 'Target *',
                    controller: _targetNameController,
                    validator: (value){
                      if((value == null || value.isEmpty) && isSaved == true){
                        return "Please Enter Target *";
                      } return null;
                    },
                  ),
                ),
              ],
            )
        ),


        ResponsiveApp(
            mobile: Column(
              children: [
                AppFormTextField(
                  labelText: 'Purpose *',
                  hintText: 'Purpose *',
                  controller: _purposeController,
                  validator: (value){
                    if((value == null || value.isEmpty) && isSaved == true){
                      return "Please Enter Purpose *";
                    } return null;
                  },

                ),
                AppFormTextField(
                  labelText: 'Description *',
                  hintText: 'Description *',
                  controller: _descriptionController,
                  validator: (value){
                    if((value == null || value.isEmpty) && isSaved == true){
                      return "Please Enter Description *";
                    } return null;
                  },
                ),
              ],
            ),
            tablet: Row(
              children: [
                Expanded(
                  child: AppFormTextField(
                    labelText: 'Purpose *',
                    hintText: 'Purpose *',
                    controller: _purposeController,
                    validator: (value){
                      if((value == null || value.isEmpty) && isSaved == true){
                        return "Please Enter Purpose *";
                      } return null;
                    },

                  ),
                ),
                SizedBox(width: 5,),
                Expanded(
                  child: AppFormTextField(
                    labelText: 'Description *',
                    hintText: 'Description *',
                    controller: _descriptionController,
                    validator: (value){
                      if((value == null || value.isEmpty) && isSaved == true){
                        return "Please Enter Description *";
                      } return null;
                    },
                  ),
                ),
              ],
            ),
            desktop: Row(
              children: [
                Expanded(
                  child: AppFormTextField(
                    labelText: 'Purpose *',
                    hintText: 'Purpose *',
                    controller: _purposeController,
                    validator: (value){
                      if((value == null || value.isEmpty) && isSaved == true){
                        return "Please Enter Purpose *";
                      } return null;
                    },

                  ),
                ),
                SizedBox(width: 5,),
                Expanded(
                  child: AppFormTextField(
                    labelText: 'Description *',
                    hintText: 'Description *',
                    controller: _descriptionController,
                    validator: (value){
                      if((value == null || value.isEmpty) && isSaved == true){
                        return "Please Enter Description *";
                      } return null;
                    },
                  ),
                ),
              ],
            )
        ),
        const SizedBox(
          height: 20,
        ),


        Stack(
          children: [
            SizedBox(
              width: _mapWidth,
              height: _mapHeight,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                    center: LatLng(40.0, -120.0),
                    zoom: 8.0,
                    interactiveFlags:
                        InteractiveFlag.all & ~InteractiveFlag.rotate,
                    onTap: _handleTap),
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
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: areaPoints,
                        borderStrokeWidth: 2,
                        borderColor: ColorUtils.secondaryColor,
                        color: ColorUtils.secondaryColor.withOpacity(1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Positioned(
            //     bottom: 10,
            //     right: 10,
            //     child: CircleAvatar(
            //       radius: 20,
            //       backgroundColor: ColorUtils.secondaryColor,
            //       child: IconButton(
            //         icon: const Icon(Icons.location_searching),
            //         color: Colors.white,
            //         onPressed: () {
            //           _getLocation();
            //         },
            //       ),
            //     )),
            if (!isDrawingEnabled && areaPoints.isEmpty)
              Positioned(
                  bottom: 10,
                  right: 10,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: ColorUtils.secondaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          isDrawingEnabled = true;
                        });
                      },
                    ),
                  )),
            if (!isDrawingEnabled && areaPoints.isNotEmpty)
              Positioned(
                  bottom: 10,
                  right: 10,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: ColorUtils.secondaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          areaPoints.clear();
                        });
                      },
                    ),
                  )),
            if (isDrawingEnabled)
              Positioned(
                  bottom: 55,
                  right: 10,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: ColorUtils.secondaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.check),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          isDrawingEnabled = false;
                        });
                      },
                    ),
                  )),
            if (isDrawingEnabled)
              Positioned(
                  bottom: 10,
                  right: 10,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: ColorUtils.secondaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.cancel),
                      color: Colors.white,
                      onPressed: () {
                        setState(() {
                          areaPoints.clear();
                          isDrawingEnabled = false;
                        });
                      },
                    ),
                  )),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    if (!isDrawingEnabled) return;
    setState(() {
      areaPoints.add(point);
    });
  }

  Future saveArea() async {
    setState(() {
      _isLoading = true;
    });
    final obj = {
      "expeditionId": expeditionId,
      "name": name,
      "geologicalCertainityId": _geologicalCertainityValue,
      "operationalCertainityId": _operationalCertainityValue,
      "operationalDays": _operationalDaysController.text,
      "targetName": _targetNameController.text,
      "purpose": _purposeController.text,
      "description": _descriptionController.text,
      "areaGeometry": areaPoints.map((e) => [e.latitude, e.longitude]).toList()
    };
    if (areaId.isNotEmpty) {
      obj["_key"] = areaId;
    }
    // save to db
    final response =
        await ApiProvider().post(AppConsts.baseURL + AppConsts.saveArea, obj);
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context, MaterialPageRoute(builder: (context) => Areas()));
  }
}
