import 'dart:io';

import 'package:expedition_poc/providers/ApiProvider.dart';
import 'package:expedition_poc/screens/application/expeditions/platforms/platforms.dart';
import 'package:expedition_poc/services/generate_image_url.dart';
import 'package:expedition_poc/utilities/appConsts.dart';
import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/utilities/enum.dart';
import 'package:expedition_poc/utils/AppSigninTextFormField.dart';
import 'package:expedition_poc/utils/AppTextFormField.dart';
import 'package:expedition_poc/utils/colors.dart';
import 'package:expedition_poc/utils/responsive.dart';
import 'package:expedition_poc/widgets/gallery_item.dart';
import 'package:expedition_poc/widgets/imageUpload.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:simple_speed_dial/simple_speed_dial.dart';

import '../../../../utils/AppTextFormFieldFunc.dart';

class PlatformForm extends StatefulWidget {
   PlatformForm({super.key, this.arguments, this.formData});

  final arguments;
  Function(dynamic)? formData;

  @override
  _PlatformFormState createState() => _PlatformFormState();
}

class _PlatformFormState extends State<PlatformForm> {
  String platformId = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false, readOnly = false;
  bool isSaved = false;

  final _nameController = TextEditingController();
  final _providerController = TextEditingController();
  final _markController = TextEditingController();
  final _protocolController = TextEditingController();
  final _serialNumberController = TextEditingController();

  late String expeditionId;

  final List<File> _photos = <File>[];
  final List<String> _photosUrls = <String>[];
  final List<String> _s3KeysList = <String>[];

  final List<PhotoSource> _photosSources = <PhotoSource>[];
  final List<PhotoStatus> _photosStatus = <PhotoStatus>[];
  final List<GalleryItem> _galleryItems = <GalleryItem>[];


  @override
  void dispose() {
    _nameController.dispose();
    _markController.dispose();
    _providerController.dispose();
    _serialNumberController.dispose();
    _protocolController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = widget.arguments;
    // final arguments = ModalRoute.of(context)!.settings.arguments;
    expeditionId = (arguments as Map)["expeditionId"];
    if (arguments.containsKey("readOnly")) {
      setState(() {
        readOnly = (arguments)["readOnly"];
      });
    }
    if (arguments.containsKey("platformId")) {
      platformId = (arguments)["platformId"];
      getData();
    }
  }

  getData() async {
    setState(() {
      _isLoading = true;
    });
    final response = await ApiProvider()
        .get(AppConsts.baseURL + AppConsts.platformDocument + platformId);
    setState(() {
      _isLoading = false;
    });

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
      _nameController.text = response["name"] ?? "";
      _providerController.text = response["provider"] ?? "";
      _markController.text = response["mark"] ?? "";
      _serialNumberController.text = response["serialNumber"] ?? "";
      _protocolController.text = response["protocol"] ?? "";

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
                        savePlatform();
                      }
                    },
                    icon: Icon(Icons.save, size: 30,)
                ),
              )
            ],
            title: const Text('Platform',style: TextStyle(color: Colors.white),),
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
          // bottomNavigationBar: Visibility(
          //   visible: !readOnly,
          //   child: Container(
          //     height: 50,
          //     color: ColorUtils.secondaryColor,
          //     child: InkWell(
          //       onTap: () {
          //         if (_formKey.currentState!.validate()) {
          //           savePlatform();
          //         }
          //       },
          //       child: const Center(
          //         child: Text(
          //           "Save",
          //           textAlign: TextAlign.center,
          //           style: TextStyle(color: Colors.white, fontSize: 18),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Visibility(
            visible: readOnly,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  readOnly = false;
                });
              },
              backgroundColor: ColorUtils.secondaryColor,
              child: const Icon(Icons.edit),
            ),
          ),
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

        // TextFormField(
        //   enabled: !readOnly,
        //   decoration: const InputDecoration(
        //     labelText: 'Name',
        //   ),
        //   controller: _nameController,
        // ),
        // TextFormField(
        //   enabled: !readOnly,
        //   decoration: const InputDecoration(
        //     labelText: 'Mark',
        //   ),
        //   controller: _markController,
        // ),
        // TextFormField(
        //   enabled: !readOnly,
        //   decoration: const InputDecoration(
        //     labelText: 'Serial Number',
        //   ),
        //   keyboardType: TextInputType.number,
        //   controller: _serialNumberController,
        // ),
        // TextFormField(
        //   enabled: !readOnly,
        //   decoration: const InputDecoration(
        //     labelText: 'Provider',
        //   ),
        //   controller: _providerController,
        // ),
        // TextFormField(
        //   enabled: !readOnly,
        //   decoration: const InputDecoration(
        //     labelText: 'Protocol',
        //   ),
        //   controller: _protocolController,
        // ),

       ResponsiveApp(
           mobile: Column(
             children: [
               AppTextFormFieldFunc('Name', _nameController),
               AppTextFormFieldFunc('Mark', _markController),
               // AppFormTextField(enabled: !readOnly, labelText: 'Name *',hintText: 'Name *',controller: _nameController, validator: (value){
               //   if((value == null || value.isEmpty) && isSaved == true){
               //     return 'Please Enter Name *';
               //   }return null;
               // },),
               // AppFormTextField(enabled: !readOnly, labelText: 'Mark *',hintText: 'Mark *',controller: _markController,validator: (value){
               //   if((value == null || value.isEmpty) && isSaved == true){
               //     return 'Please Enter Mark *';
               //   }return null;
               // },),
             ],
           ),
           tablet:  Row(
             children: [
               Expanded(child:  AppTextFormFieldFunc('Name', _nameController),),
               SizedBox(width: 5,),
               Expanded(child:  AppTextFormFieldFunc('Mark', _markController),),
             ],
           ),
           desktop:  Row(
             children: [
               Expanded(child:  AppTextFormFieldFunc('Name', _nameController),),
               SizedBox(width: 5,),
               Expanded(child:  AppTextFormFieldFunc('Mark', _markController),),
             ],
           ),
       ),

        AppTextFormFieldFunc('Serial Number', _serialNumberController),

       ResponsiveApp(
           mobile: Column(
             children: [
               AppTextFormFieldFunc('Provider', _providerController),
               AppTextFormFieldFunc('Protocol', _protocolController),

             ],
           ),
           tablet: Row(
             children: [
               Expanded(child:  AppTextFormFieldFunc('Provider', _providerController),),
               SizedBox(width: 5,),
               Expanded(child:  AppTextFormFieldFunc('Protocol', _protocolController),),
             ],
           ),
           desktop:Row(
             children: [
               Expanded(child:  AppTextFormFieldFunc('Provider', _providerController),),
               SizedBox(width: 5,),
               Expanded(child:  AppTextFormFieldFunc('Protocol', _protocolController),),
             ],
           ),
       ),

        ImageUpload(
            folderName: PictureFolderName.platform.toString().split('.')[1],
            photos: _photos,
            photosUrls: _photosUrls,
            s3KeysList: _s3KeysList,
            photosSources: _photosSources,
            photosStatus: _photosStatus),
      ],
    );
  }

  AppTextFormFieldFunc(labelText, controller){
    return AppFormTextField(enabled: !readOnly, labelText: labelText + '*',controller: controller, validator: (value){
      if((value == null || value.isEmpty) && isSaved == true){
        return 'Please Enter $labelText *';
      }return null;
    },);
  }

  Future savePlatform() async {
    setState(() {
      _isLoading = true;
    });
    final obj = {
      "expeditionId": expeditionId,
      "name": _nameController.text,
      "mark": _markController.text,
      "provider": _providerController.text,
      "serialNumber": _serialNumberController.text,
      "protocol": _protocolController.text,
      "pictures": _s3KeysList
    };
    if (platformId.isNotEmpty) {
      obj["_key"] = platformId;
    }
    // save to db
    final response = await ApiProvider()
        .post(AppConsts.baseURL + AppConsts.savePlatform, obj);

    if(response != null){
      obj["_key"] = response["_key"];
    }

    setState(() {
      _isLoading = false;
    });

    widget.formData!(obj);
    // Navigator.pop(
    //     context, MaterialPageRoute(builder: (context) => Platforms(formData: obj,)));
  }
}
