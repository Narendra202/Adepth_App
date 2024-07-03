import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/platforms/platforms.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/utils/AppTextFormField.dart';
import 'package:expedition_poc/widgets/multiSelectWidget.dart';
import 'package:expedition_poc/widgets/multiselect.dart';
import 'package:expedition_poc/widgets/readonlyField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../../../utils/colors.dart';

enum FORM_TYPE { DIVE, SAMPLE, ANALYSIS }

class DiveForm extends StatefulWidget {
  const DiveForm({super.key});

  @override
  _DiveFormState createState() => _DiveFormState();
}

class _DiveFormState extends State<DiveForm> {
  String diveId = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isSaved = false;

  late String areaId, expeditionId, locationId;

  String name = "";
  final _diveNumberController = TextEditingController();
  final DateTime _startDate_date = DateTime.now();
  final DateTime _endDate_date = DateTime.now();
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _commentController = TextEditingController();
  final _purposeController = TextEditingController();

  List<String> _toolsItems = [];
  List<String> _platformItems = [];
  final List platformItemList = [];
  final List toolsItemList = [];

  late Widget protocolList = Column(children: [],);

  late String _hour, _minute, _time;
  TimeOfDay selectedTime = const TimeOfDay(hour: 00, minute: 00);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Code to execute after the build is complete
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final arguments = ModalRoute.of(context)!.settings.arguments;
    expeditionId = (arguments as Map)["expeditionId"];
    areaId = (arguments)["areaId"];
    locationId = (arguments)["locationId"];
    // api call's
    setState(() {
      _isLoading = true;
    });
    await initLookupData();
    if (arguments.containsKey("diveId")) {
      diveId = (arguments)["diveId"];
      await getData();
    } else {
      name = await ApiProvider().get(
          "${AppConsts.baseURL}${AppConsts.generateNameDive}$expeditionId");
    }
    setState(() {
      _isLoading = false;
    });
  }

  initLookupData() async {
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.platformAndAreaList + expeditionId);
    setState(() {
      platformItemList.addAll(response["platformList"]);
      toolsItemList.addAll(response["toolList"]);
    });
  }


  @override
  void dispose() {
    super.dispose();
    _diveNumberController.dispose();
    _startDate.dispose();
    _endDate.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _commentController.dispose();
    _commentController.dispose();
    _purposeController.dispose();
  }

  // @override
  // void didChangeDependencies() async {
  //   super.didChangeDependencies();
  //   final arguments = ModalRoute.of(context)!.settings.arguments;
  //   expeditionId = (arguments as Map)["expeditionId"];
  //   areaId = (arguments)["areaId"];
  //   locationId = (arguments)["locationId"];
  //   // api call's
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   await initLookupData();
  //   if (arguments.containsKey("diveId")) {
  //     diveId = (arguments)["diveId"];
  //     await getData();
  //   } else {
  //     name = await ApiProvider().get(
  //         "${AppConsts.baseURL}${AppConsts.generateNameDive}$expeditionId");
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }
  //
  // initLookupData() async {
  //   final response = await ApiProvider()
  //       .get(AppConsts.baseURL + AppConsts.platformAndAreaList + expeditionId);
  //   setState(() {
  //     platformItemList.addAll(response["platformList"]);
  //     toolsItemList.addAll(response["toolList"]);
  //   });
  // }

  getData() async {
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.diveDocument + diveId);
    setState(() {
      name = response["name"] ?? "";
      _diveNumberController.text = response["diveNumber"] ?? "";
      _startDate.text = response["startDate"] ?? "";
      _endDate.text = response["endDate"] ?? "";
      for (int i = 0; i < response["toolsList"].length; i++) {
        _toolsItems.add(response["toolsList"][i].toString());
      }
      for (int i = 0; i < response["platformsList"].length; i++) {
        _platformItems.add(response["platformsList"][i].toString());
      }
      _commentController.text = response["comment"] ?? "";
      _purposeController.text = response["purpose"] ?? "";
      _startTimeController.text = response["startTime"] ?? "";
      _endTimeController.text = response["endTime"] ?? "";
    });
    showProtocols();
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
                      icon: Icon(Icons.save, size: 30,)
                  ),
                )
              ],
              title: const Text('Dive', style: TextStyle(color: Colors.white),),
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

  Widget formUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Dive Number *',
        //   ),
        //   keyboardType: TextInputType.number,
        //   controller: _diveNumberController,
        //   validator: (value) {
        //     if (_diveNumberController.text.isEmpty) {
        //       return 'Please enter a value';
        //     }
        //     return null; // Return null if the value is valid
        //   },
        // ),

    // Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
    //   children: [
    //     Expanded(
    //         child: TextFormField(
    //       controller: _startDate,
    //       decoration: const InputDecoration(
    //           labelText: "Start Date",
    //           suffixIcon: Padding(
    //             padding: EdgeInsets.only(top: 15),
    //             // add padding to adjust icon
    //             child: Icon(Icons.calendar_month),
    //           )),
    //       keyboardType: TextInputType.datetime,
    //       readOnly: true,
    //       onTap: () => _selectDate(context, _startDate_date, _startDate),
    //     )),
    //     Expanded(
    //         child: Padding(
    //       padding: const EdgeInsets.only(left: 20),
    //       child: InkWell(
    //         onTap: () {
    //           _selectTime(context, _startTimeController);
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
    //           controller: _startTimeController,
    //         ),
    //       ),
    //     )),
    //   ],
    // ),

        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   children: [
        //     Expanded(
        //         child: TextFormField(
        //       controller: _endDate,
        //       decoration: const InputDecoration(
        //           labelText: "End Date",
        //           suffixIcon: Padding(
        //             padding: EdgeInsets.only(top: 15),
        //             // add padding to adjust icon
        //             child: Icon(Icons.calendar_month),
        //           )),
        //       keyboardType: TextInputType.datetime,
        //       readOnly: true,
        //       onTap: () => _selectDate(context, _endDate_date, _endDate),
        //     )),
        //     Expanded(
        //         child: Padding(
        //       padding: const EdgeInsets.only(left: 20),
        //       child: InkWell(
        //         onTap: () {
        //           _selectTime(context, _endTimeController);
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
        //           controller: _endTimeController,
        //         ),
        //       ),
        //     )),
        //   ],
        // ),

        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Purpose',
        //   ),
        //   controller: _purposeController,
        // ),
        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Comment',
        //   ),
        //   controller: _commentController,
        // ),

        AppFormTextField(
          labelText: 'Dive Number *',
          hintText: 'Dive Number *',
          controller: _diveNumberController,
          keyboardInputType: TextInputType.number,
          validator: (value){
            if((value == null || value.isEmpty) && isSaved == true){
              return "Please Enter Dive Number *";
            } return null;
          },
        ),

      Row(
         children: [
           Expanded(
             child: AppFormTextField(
               labelText: 'Start Date',
               hintText: 'Start Date',
               controller: _startDate,
               suffixIcon: Icons.calendar_month,
               keyboardInputType: TextInputType.datetime,
               readOnly: true,
               onTep: () => _selectDate(context, _startDate_date, _startDate),
               validator: (value){
                 if((value == null || value.isEmpty) && isSaved == true){
                   return "Please Enter Start Date";
                 } return null;
               },
             ),
           ),
           Expanded(
             child: AppFormTextField(
               labelText: 'Start Time',
               hintText: 'Start Time',
               controller: _startTimeController,
               suffixIcon: Icons.watch_later_sharp,
               keyboardInputType: TextInputType.text,
               readOnly: true,
               onTep: () => _selectTime(context, _startTimeController),
               validator: (value){
                 if((value == null || value.isEmpty) && isSaved == true){
                   return "Please Enter Start Time";
                 } return null;
               },
             ),
           )
         ],
       ),

        Row(
          children: [
            Expanded(
              child: AppFormTextField(
                labelText: 'End Date',
                hintText: 'End Date',
                controller: _endDate,
                suffixIcon: Icons.calendar_month,
                keyboardInputType: TextInputType.datetime,
                readOnly: true,
                onTep: () =>  _selectDate(context, _endDate_date, _endDate),
                validator: (value){
                  if((value == null || value.isEmpty) && isSaved == true){
                    return "Please Enter End Date";
                  } return null;
                },
              ),
            ),
            Expanded(
              child: AppFormTextField(
                labelText: 'End Time',
                hintText: 'End Time',
                controller: _endTimeController,
                suffixIcon: Icons.watch_later_sharp,
                keyboardInputType: TextInputType.text,
                readOnly: true,
                onTep: () => _selectTime(context, _endTimeController),
                validator: (value){
                  if((value == null || value.isEmpty) && isSaved == true){
                    return "Please Enter End Time";
                  } return null;
                },
              ),
            )
          ],
        ),


        MultiSelectWidget(
            name: 'Platform Type',
            itemsList: platformItemList,
            items: _platformItems,
            onItemsChanged: onItemsChanged),
        MultiSelectWidget(
            name: 'Tools',
            itemsList: toolsItemList,
            items: _toolsItems,
            onItemsChanged: onItemsChanged
        ),

        AppFormTextField(
          labelText: 'Purpose',
          hintText: 'Purpose',
          controller: _purposeController,
          validator: (value){
            if((value == null || value.isEmpty) && isSaved == true){
              return "Please Enter Dive Number *";
            } return null;
          },
        ),

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


        const SizedBox(
          height: 20,
        ),
        Container(
          height: 200,
          child: protocolList,
        ),
        const SizedBox(
          height: 50,
        ),
      ],
    );
  }

  onItemsChanged() {
    showProtocols();
  }

  showProtocols() {
    setState(() {
      protocolList = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_platformItems.isNotEmpty) ...[
            const SizedBox(
              height: 5,
            ),
            const Text("Platform Protocols"),
            const SizedBox(
              height: 5,
            ),
            Flexible(
                child: SizedBox(
                  height: _platformItems.length * 25,
                  child: ListView.builder(
                    itemCount: _platformItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map item = platformItemList.firstWhere((element) => element["_key"] == _platformItems[index]) as Map;
                      return ReadOnlyField(title: item["name"], value: item['protocol']);
                    },
                  ),
                )),
          ],
          if (_toolsItems.isNotEmpty) ...[
            const SizedBox(
              height: 5,
            ),
            const Text("Tool Protocols"),
            const SizedBox(
              height: 5,
            ),
            Flexible(
                child: SizedBox(
                  height: _platformItems.length * 25  ,
                  child: ListView.builder(
                    itemCount: _toolsItems.length,
                    itemBuilder: (BuildContext context, int index) {
                      Map item = toolsItemList.firstWhere((element) => element["_key"] == _toolsItems[index]) as Map;
                      return ReadOnlyField(title: item["name"], value: item['protocol']);
                    },
                  ),
                )),
          ]
        ],
      );
    });
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
      "locationId": locationId,
      "diveNumber": _diveNumberController.text,
      "name": "Dive ${_diveNumberController.text}",
      "platformsList": _platformItems,
      "startDate": _startDate.text,
      "startTime": _startTimeController.text,
      "endDate": _endDate.text,
      "endTime": _endTimeController.text,
      'toolsList': _toolsItems,
      "purpose": _purposeController.text,
      "comment": _commentController.text
    };
    if (diveId.isNotEmpty) {
      obj["_key"] = diveId;
    }

    // save to db
    final response =
        await ApiProvider().post(AppConsts.baseURL + AppConsts.saveDive, obj);

    setState(() {
      _isLoading = false;
    });

    // print('Response body: ${response.body}');
    Navigator.pop(
        context, MaterialPageRoute(builder: (context) => Platforms()));
  }
}
