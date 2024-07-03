import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/data/data.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:flutter/material.dart';

import '../../../../utils/AppTextFormField.dart';
import '../../../../utils/colors.dart';
import '../../../../widgets/multiselect.dart';

class DataForm extends StatefulWidget {
  DataForm({Key? key, this.arguments, this.formData}) : super(key: key);

  final arguments;
  Function(dynamic)? formData;

  @override
  State<DataForm> createState() => _DataFormState();
}

class _DataFormState extends State<DataForm> {
  String dataId = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isSaved = false;

  late String expeditionId;

  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _protocolController = TextEditingController();
  var _typeValue, _classificationValue;
  List<String> _fieldItems = [];

  final List typeList = [];
  final List fieldItemList = [];
  final List classificationList = [];

  void _showMultiSelect() async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: fieldItemList, selectedItems: _fieldItems);
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _fieldItems = results;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortNameController.dispose();
    _protocolController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Code here runs after the first frame is rendered, ensuring context is available.
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final arguments = widget.arguments;
    // final arguments = ModalRoute.of(context)!.settings.arguments;
    expeditionId = (arguments as Map)["expeditionId"];
    await initLookupData();
    if (arguments.containsKey("dataId")) {
      dataId = (arguments)["dataId"];
      getData();
    }
    // _isDataInitialized = true;

  }

  // @override
  // void didChangeDependencies() async {
  //   super.didChangeDependencies();
  //
  //   final arguments = ModalRoute.of(context)!.settings.arguments;
  //   expeditionId = (arguments as Map)["expeditionId"];
  //   await initLookupData();
  //   if (arguments.containsKey("dataId")) {
  //     dataId = (arguments)["dataId"];
  //     getData();
  //   }
  // }

  initLookupData() async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await ApiProvider().get(AppConsts.baseURL + AppConsts.dataMetaData);
    setState(() {
      _isLoading = false;
    });
    setState(() {
      typeList.addAll(response["dataTypesList"]);
      fieldItemList.addAll(response["dataFieldsList"]);
      classificationList.addAll(response["dataClassificationTypes"]);
    });
  }

  getData() async {
    setState(() {
      _isLoading = true;
    });
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.dataDocument + dataId);
    setState(() {
      _isLoading = false;
    });
    setState(() {
      _nameController.text = response["name"] ?? "";
      _shortNameController.text = response["shortName"] ?? "";
      _protocolController.text = response["protocol"] ?? "";
      _typeValue = response["typeId"];
      _classificationValue = response["classificationId"];
      for (int i = 0; i < response["fieldsList"].length; i++) {
        _fieldItems.add(response["fieldsList"][i].toString());
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
                          saveData();
                        }
                      },
                      icon: Icon(Icons.save, size: 30,)
                  ),
                )
              ],

              title: const Text('Data',style: TextStyle(color: Colors.white),),
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
            //         saveData();
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

        // DropdownButtonFormField(
        //   value: _typeValue,
        //   items: typeList
        //       .map((value) => DropdownMenuItem(
        //             value: value["_key"],
        //             child: Text(value["name"]!),
        //           ))
        //       .toList(),
        //   onChanged: (newValue) {
        //     setState(() {
        //       _typeValue = newValue.toString();
        //     });
        //   },
        //   decoration: const InputDecoration(
        //     labelText: 'Type',
        //   ),
        // ),
        // DropdownButtonFormField(
        //   value: _classificationValue,
        //   items: classificationList
        //       .map((value) => DropdownMenuItem(
        //             value: value["_key"],
        //             child: Text(value["name"]!),
        //           ))
        //       .toList(),
        //   onChanged: (newValue) {
        //     setState(() {
        //       _classificationValue = newValue.toString();
        //     });
        //   },
        //   decoration: const InputDecoration(
        //     labelText: 'Classification',
        //   ),
        // ),
        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Name',
        //   ),
        //   controller: _nameController,
        // ),
        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Short Name',
        //   ),
        //   controller: _shortNameController,
        // ),
        // TextFormField(
        //   decoration: const InputDecoration(
        //     labelText: 'Protocol',
        //   ),
        //   controller: _protocolController,
        // ),

        // GestureDetector(
        //   onTap: _showMultiSelect,
        //   child: Container(
        //     padding: const EdgeInsets.only(bottom: 15),
        //     decoration: const BoxDecoration(
        //         border:
        //         Border(bottom: BorderSide(color: Colors.grey, width: 1))),
        //     child: const Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Text(
        //           'Fields',
        //           style: TextStyle(fontSize: 16),
        //         ),
        //         Icon(Icons.arrow_drop_down)
        //       ],
        //     ),
        //   ),
        // ),

    AppDropDownKeyNameField(
         labelText: 'Type',
         value: _typeValue,
        items: typeList,
        validator: (value){
          if((value == null || value.isEmpty) && isSaved == true){
            return 'Please Select Type *';
          }return null;
        },
        onChanged: (newValue) {
          setState(() {
            _typeValue = newValue.toString();
          });
        }
    ),
    SizedBox(height: 10,),
    AppDropDownKeyNameField(
    labelText: 'Classification',
    value: _classificationValue,
    items: classificationList,
    validator: (value){
    if((value == null || value.isEmpty) && isSaved == true){
    return 'Please Select Classification *';
    }return null;
    },
    onChanged: (newValue) {
    setState(() {
    _classificationValue = newValue.toString();
    });
    }
    ),


       // ResponsiveApp(
       //     mobile: Column(
       //       children: [
       //         AppDropDownFunc('Type', _typeValue, typeList, _typeValue),
       //         const SizedBox(height: 10,),
       //         AppDropDownFunc('Classification', _classificationValue, classificationList, _classificationValue),
       //       ],
       //     ),
       //     tablet: Row(
       //       children: [
       //         Expanded(child: AppDropDownFunc('Type', _typeValue, typeList, _typeValue),),
       //         const SizedBox(height: 10,width: 10,),
       //         Expanded(child: AppDropDownFunc('Classification', _classificationValue, classificationList, _classificationValue),)
       //       ],
       //     ),
       //     desktop: Row(
       //       children: [
       //         Expanded(child: AppDropDownFunc('Type', _typeValue, typeList, _typeValue),),
       //         const SizedBox(height: 10,width: 10,),
       //         Expanded(child: AppDropDownFunc('Classification', _classificationValue, classificationList, _classificationValue),)
       //     ],
       //     )
       // ),
       //

        // AppDropDownKeyNameField(
        //     labelText: 'Type',
        //     hintText: 'Type',
        //     value: _typeValue,
        //     items: typeList,
        //     validator: (value){
        //       if((value == null || value.isEmpty) && isSaved == true){
        //         return 'Please Enter Type';
        //       }return null;
        //     },
        //     onChanged: (newValue) {
        //       setState(() {
        //         _typeValue = newValue.toString();
        //       });
        //     }
        // ),
        // const SizedBox(height: 10,),
        // AppDropDownKeyNameField(
        //     validator: (value){
        //       if((value == null || value.isEmpty) && isSaved == true){
        //         return 'Please Enter Classification';
        //       }return null;
        //     },
        //     labelText: 'Classification',
        //     hintText: 'Classification',
        //     value: _classificationValue,
        //     items: classificationList,
        //     onChanged: (newValue) {
        //       setState(() {
        //         _classificationValue = newValue.toString();
        //       });
        //     }
        // ),
        const SizedBox(height: 5,),

        ResponsiveApp(
            mobile: Column(
              children: [
                AppTextFormFieldFunc('Name', _nameController),
                AppTextFormFieldFunc('Short Name', _shortNameController)
              ],
            ),
            tablet: Row(
              children: [
                Expanded(child: AppTextFormFieldFunc('Name', _nameController),),
                SizedBox(width: 5,),
                Expanded(child: AppTextFormFieldFunc('Short Name', _shortNameController))
              ],
            ),
            desktop: Row(
              children: [
                Expanded(child: AppTextFormFieldFunc('Name', _nameController),),
                SizedBox(width: 5,),
                Expanded(child: AppTextFormFieldFunc('Short Name', _shortNameController))
              ],
            )
        ),

        AppTextFormFieldFunc('Protocol', _protocolController),

        const SizedBox(height: 5,),

       AppFormTextField(
         // validator: (value){
         //   if((value == null || value.isEmpty) && isSaved == true){
         //     return 'Please Enter Fields';
         //   }return null;
         // },
         onTep: _showMultiSelect,
         labelText: 'Fields',
         suffixIcon: Icons.arrow_drop_down,
       ),
        const SizedBox(height: 5,),
        // display selected items
        Wrap(
          spacing: 5.0, // spacing between adjacent chips
          runSpacing: 0.0, // spacing between lines
          children: _fieldItems
              .map((e) => Chip(
                    label: Text(fieldItemList.firstWhere(
                        (element) => element["_key"] == e.toString())["name"]),
                    deleteIcon: const Icon(Icons.cancel),
                    onDeleted: () => {
                      setState(() {
                        _fieldItems.removeWhere((item) => item == e);
                      })
                    },
                  ))
              .toList(),
        )
      ],
    );
  }


  AppTextFormFieldFunc(labelText , controller) {
    return    AppFormTextField(labelText: labelText + ' *', controller: controller,validator: (value){
      if((value == null || value.isEmpty) && isSaved == true){
        return 'Please Enter $labelText *';
      }return null;
    },);
  }
  Future saveData() async {
    setState(() {
      _isLoading = true;
    });
    final obj = {
      "expeditionId": expeditionId,
      "name": _nameController.text,
      "shortName": _shortNameController.text,
      "typeId": _typeValue,
      "classificationId": _classificationValue,
      "protocol": _protocolController.text,
      'fieldsList': _fieldItems
    };
    if (dataId.isNotEmpty) {
      obj["_key"] = dataId;
    }

    // save to db
    final response =
    await ApiProvider().post(AppConsts.baseURL + AppConsts.saveData, obj);

    if(response  != null){
      obj['_key'] = response['_key'];
        obj['type'] = response['type'];
    }

    setState(() {
      _isLoading = false;
    });
    widget.formData!(obj);


    // // print('Response body: ${response.body}');
    // Navigator.pop(
    //     context, MaterialPageRoute(builder: (context) => const Data()));
  }
}
