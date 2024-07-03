import 'package:expedition_poc/utilities/colorUtils.dart';
import 'package:expedition_poc/widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:expedition_poc/services/upload_file.dart';
import 'package:expedition_poc/services/generate_image_url.dart';
import 'package:expedition_poc/utilities/permission_dialog.dart';
import 'package:expedition_poc/widgets/gallery_item.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart'
    as permissionHandler;
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

// import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

enum PhotoStatus { LOADING, ERROR, LOADED }

enum PhotoSource { FILE, NETWORK, WEB }

enum PictureType { CAMERA, STORAGE, WEB }

class ImageUpload extends StatefulWidget {
  String folderName;

  List<File> photos = <File>[];
  List<String> photosUrls = <String>[];
  List<String> s3KeysList = <String>[];

  List<PhotoSource> photosSources = <PhotoSource>[];
  List<PhotoStatus> photosStatus = <PhotoStatus>[];

  ImageUpload(
      {Key? key,
      required this.folderName,
      required this.photos,
      required this.photosUrls,
      required this.s3KeysList,
      required this.photosSources,
      required this.photosStatus})
      : super(key: key);

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  late String folderName;

  late List<File> _photos = <File>[];
  late List<String> _photosUrls = <String>[];
  List<String> _s3KeysList = <String>[];

  late List<PhotoSource> _photosSources = <PhotoSource>[];
  late List<PhotoStatus> _photosStatus = <PhotoStatus>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    folderName = widget.folderName;
    _photos = widget.photos;
    _photosUrls = widget.photosUrls;
    _photosSources = widget.photosSources;
    _photosStatus = widget.photosStatus;
    _s3KeysList = widget.s3KeysList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _photosUrls.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddPhoto();
              }
              File image = _photos[index - 1];
              PhotoSource source = _photosSources[index - 1];
              return Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ImageViewer(imageUrl: _photosUrls[index - 1]),
                        ),
                      )
                    },
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      height: 100,
                      width: 100,
                      color: ColorUtils.kLightGray,
                      child: source == PhotoSource.FILE
                          ? Image.file(image)
                          : Image.network(_photosUrls[index - 1]),
                    ),
                  ),
                  Visibility(
                      visible: _photosStatus[index - 1] == PhotoStatus.LOADING,
                      child: const SizedBox(
                          width: 100,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ))),
                  Visibility(
                    visible: _photosStatus[index - 1] == PhotoStatus.ERROR,
                    child: const Positioned.fill(
                      child: Icon(
                        Icons.error,
                        color: ColorUtils.kErrorRed,
                        size: 35,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      alignment: Alignment.topRight,
                      child: InkWell(
                        onTap: () => {_onDeleteReviewPhotoClicked(index - 1)},
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  _buildAddPhoto() {
    return InkWell(
      onTap: () {
        if (kIsWeb) {
          _onAddPhotoClicked(context, PictureType.WEB);
        } else {
          _showImagePickerModal(context);
        }
      },
      child: Container(
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: ColorUtils.secondaryColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(
              Icons.camera_alt_outlined,
              color: ColorUtils.pearlWhite,
            ),
            Text(
              "Upload",
              style: TextStyle(color: ColorUtils.pearlWhite),
            ),
            Text(
              "Picture",
              style: TextStyle(color: ColorUtils.pearlWhite),
            )
          ],
        ),
      ),
    );
  }

  void _showImagePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150.0,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _onAddPhotoClicked(context, PictureType.STORAGE);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _onAddPhotoClicked(context, PictureType.CAMERA);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _onDeleteReviewPhotoClicked(int index) async {
    setState(() {
      if (_photosStatus[index] == PhotoStatus.LOADED) {
        _photosUrls.removeAt(index);
      }
      _photos.removeAt(index);
      _photosStatus.removeAt(index);
      _photosSources.removeAt(index);
      _s3KeysList.removeAt(index);
    });
    return true;
  }

  _onAddPhotoClicked(context, pictureType) async {
    if (pictureType == PictureType.WEB) {
      final ImagePicker _picker = ImagePicker();
      XFile? pickerImage = await _picker.pickImage(source: ImageSource.gallery);
      await handleImageUploadForWeb(pickerImage);
      return;
    }

    Permission permission;

    if (Platform.isIOS) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }

    permissionHandler.PermissionStatus permissionStatus =
        await permission.status;

    if (permissionStatus == permissionHandler.PermissionStatus.restricted) {
      _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != permissionHandler.PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus ==
        permissionHandler.PermissionStatus.permanentlyDenied) {
      _showOpenAppSettingsDialog(context);

      permissionStatus = await permission.status;

      if (permissionStatus != permissionHandler.PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == permissionHandler.PermissionStatus.denied) {
      if (Platform.isIOS) {
        _showOpenAppSettingsDialog(context);
      } else {
        permissionStatus = await permission.request();
      }

      if (permissionStatus != permissionHandler.PermissionStatus.granted) {
        //Only continue if permission granted
        return;
      }
    }

    if (permissionStatus == permissionHandler.PermissionStatus.granted) {
      XFile? selected;

      if (pictureType == PictureType.CAMERA) {
        selected = await ImagePicker().pickImage(source: ImageSource.camera);
      } else {
        selected = await ImagePicker().pickImage(source: ImageSource.gallery);
      }

      File image = File(selected!.path);

      if (image != null) {
        int length;
        length = _photos.length + 1;

        String fileExtension = path.extension(image.path);

        setState(() {
          _photos.add(image);
          _photosStatus.add(PhotoStatus.LOADING);
          _photosSources.add(PhotoSource.FILE);
        });

        try {
          //Changes started
          GenerateImageUrl generateImageUrl = GenerateImageUrl();
          await generateImageUrl.call(fileExtension, folderName);

          String uploadUrl;
          if (generateImageUrl.isGenerated) {
            uploadUrl = generateImageUrl.uploadUrl;
          } else {
            throw generateImageUrl.message;
          }

          bool isUploaded = await uploadFile(context, uploadUrl, image);
          if (isUploaded) {
            setState(() {
              _photosUrls.add(generateImageUrl.downloadUrl);
              _s3KeysList.add(generateImageUrl.s3Key);
              _photosStatus
                  .replaceRange(length - 1, length, [PhotoStatus.LOADED]);
            });
          }
        } catch (e) {
          // print(e);
          setState(() {
            _photosStatus[length - 1] = PhotoStatus.ERROR;
          });
        }
      }
    }
  }

  handleImageUploadForWeb(XFile? pickerImage) async {
    if (pickerImage != null) {
      var f = await pickerImage.readAsBytes();

      var mime = lookupMimeType('', headerBytes: f);
      var extension = extensionFromMime(mime!);
      // Override extension if necessary
      if (extension == 'jpe') {
        extension = 'jpeg';
      }
      extension = ".$extension";

      int length;
      length = _photos.length + 1;

      try {
        //Changes started
        GenerateImageUrl generateImageUrl = GenerateImageUrl();
        await generateImageUrl.call(extension, folderName);

        String uploadUrl;
        if (generateImageUrl.isGenerated) {
          uploadUrl = generateImageUrl.uploadUrl;
        } else {
          throw generateImageUrl.message;
        }

        bool isUploaded = await uploadFileWeb(context, uploadUrl, f);
        if (isUploaded) {
          String url =
              await generateImageUrl.getImageUrl(generateImageUrl.s3Key);
          setState(() {
            _photosUrls.add(url);
            _photos.add(File("zz"));
            _photosStatus.add(PhotoStatus.LOADED);
            _photosSources.add(PhotoSource.WEB);
            _s3KeysList.add(generateImageUrl.s3Key);
            _photosStatus
                .replaceRange(length - 1, length, [PhotoStatus.LOADED]);
          });
        }
      } catch (e) {
        // print(e);
        setState(() {
          _photosStatus[length - 1] = PhotoStatus.ERROR;
        });
      }
    }
  }

  Future<bool> uploadFile(context, String url, File image) async {
    try {
      UploadFile uploadFile = UploadFile();
      await uploadFile.call(url, image);

      if (uploadFile.isUploaded) {
        return true;
      } else {
        throw uploadFile.message;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> uploadFileWeb(context, String url, Uint8List image) async {
    try {
      UploadFile uploadFile = UploadFile();
      await uploadFile.callForWeb(url, image);

      if (uploadFile.isUploaded) {
        return true;
      } else {
        throw uploadFile.message;
      }
    } catch (e) {
      rethrow;
    }
  }

  _showOpenAppSettingsDialog(context) {
    return PermissionDialog.show(
      context,
      'Permission needed',
      'Photos permission is needed to select photos',
      'Open settings',
      openAppSettings,
    );
  }
}
