import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/expeditions.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../lib/utils/AppTextFormField.dart';
import '../lib/utils/colors.dart';

class ExpeditionForm extends StatefulWidget {
  const ExpeditionForm({Key? key}) : super(key: key);

  @override
  State<ExpeditionForm> createState() => _ExpeditionFormState();
}

class _ExpeditionFormState extends State<ExpeditionForm> {
  String expeditionId = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _autoValidate = false;
  bool isSaved = false;


  static const List<String> list = <String>[
    'Scientific survey',
    'Seabed minerals'
  ];

  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  final _year = DateTime.now().year.toString();
  DateTime _startDate_date = DateTime.now();
  DateTime _endDate_date = DateTime.now();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _vesselController = TextEditingController();
  final _imoController = TextEditingController();
  String _purpose = list.first;
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();

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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _nameController.dispose();
    _areaController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _vesselController.dispose();
    _imoController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments;
    if (arguments != null) {
      expeditionId = (arguments as Map)["expeditionId"];
      getData();
    }
  }



  getData() async {
    setState(() {
      _isLoading = true;
    });
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.expeditionDocument + expeditionId);
    setState(() {
      _isLoading = false;
    });
    setState(() {
      _nameController.text = response["name"] ?? "";
      _areaController.text = response["area"] ?? "";
      _startDateController.text = response["startDate"] ?? "";
      _endDateController.text = response["endDate"] ?? "";
      _vesselController.text = response["vessel"] ?? "";
      _imoController.text = response["imo"] ?? "";
      _purpose = response["purposeId"];
      _companyController.text = response["company"] ?? "";
      _descriptionController.text = response["description"] ?? "";
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
              title: const Text('Expedition',style: TextStyle(color: Colors.white),),
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
                          saveExpedition();
                        }
                      },
                      icon: Icon(Icons.add, size: 30,)
                  ),
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(15.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: FormUI(),
                ),
              ),
            ),
            // bottomNavigationBar: Container(
            //   height: 50,
            //   color: ColorUtils.secondaryColor,
            //   child: InkWell(
            //     onTap: () {
            //       if (_formKey.currentState!.validate()) {
            //         saveExpedition();
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

  // Here is our Form UI
  Widget FormUI() {
    return Column(
      children: <Widget>[



        AppFormTextField(controller: _nameController, labelText: 'Name', hintText: 'Name',validator: (value){
             if((value == null || value.isEmpty) && isSaved == true){
               return "Please Enter Name";
             } return null;
        },),

        AppFormTextField(controller: _areaController, labelText: 'Area', hintText: 'Area',validator: (value){
          if((value == null || value.isEmpty) && isSaved == true){
            return "Please Enter Area";
          } return null;
        },),

        AppFormTextField(labelText: 'Year', hintText: 'Year',readOnly: true, initValue: _year,keyboardInputType: TextInputType.number,),
        AppFormTextField(controller: _startDateController, labelText: 'Start Date', hintText: 'Start Date',suffixIcon: Icons.calendar_month,
          keyboardInputType: TextInputType.datetime,readOnly: true,onTep: (){ _selectDate(context, _startDate_date, _startDateController); },
          validator: (value){
            if((value == null || value.isEmpty) && isSaved == true){
              return "Please Enter Start Date";
            } return null;
          },),

        AppFormTextField(controller: _endDateController, labelText: 'End Date', hintText: 'End Date',suffixIcon: Icons.calendar_month,
          keyboardInputType: TextInputType.datetime,readOnly: true,onTep: (){ _selectDate(context, _endDate_date, _endDateController); },
          validator: (value){
            if((value == null || value.isEmpty) && isSaved == true){
              return "Please Enter End Date";
            } return null;
          },),

        AppFormTextField(controller: _vesselController, labelText: 'Vessel', hintText: 'Vessel',validator: (value){
          if((value == null || value.isEmpty) && isSaved == true){
            return "Please Enter Vessel";
          } return null;
        },),

        AppFormTextField(controller: _imoController, labelText: 'IMO', hintText: 'IMO',keyboardInputType: TextInputType.number,validator: (value){
          if((value == null || value.isEmpty) && isSaved == true){
            return "Please Enter IMO";
          } return null;
        },),

        SizedBox(height: 5,),
        AppDropDownButtonField(labelText: 'Purpose',hintText: 'Purpose',value: _purpose,onChanged: (String? value){setState(() {_purpose = value!;});},items: list,),
        SizedBox(height: 5,),

        AppFormTextField(controller: _companyController, labelText: 'Company', hintText: 'Company',validator: (value){
          if((value == null || value.isEmpty) && isSaved == true){
            return "Please Enter Company";
          } return null;
        },),
        AppFormTextField(controller: _descriptionController, labelText: 'Description', hintText: 'Description',validator: (value){
          if((value == null || value.isEmpty) && isSaved == true){
            return "Please Enter Description";
          } return null;
        },),





        const SizedBox(
          height: 10.0,
        ),
      ],
    );
  }

  Future saveExpedition() async {
    setState(() {
      _isLoading = true;
    });

    final obj = {
      "name": _nameController.text,
      "area": _areaController.text,
      "year": _year,
      "startDate": _startDateController.text,
      "endDate": _endDateController.text,
      "vessel": _vesselController.text,
      "imo": _imoController.text,
      "purposeId": _purpose,
      "company": _companyController.text,
      "description": _descriptionController.text,
    };

    if (expeditionId.isNotEmpty) {
      obj["_key"] = expeditionId;
    }

    // save to db
    final response = await ApiProvider()
        .post(AppConsts.baseURL + AppConsts.saveExpedition, obj);
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(
        context, MaterialPageRoute(builder: (context) => Expeditions()));
  }
}
