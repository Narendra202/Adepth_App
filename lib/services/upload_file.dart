import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:expedition_poc/providers/ApiProvider.dart';

class UploadFile {
  late bool success;
  late String message;

  late bool isUploaded;

  Future<void> call(String url, File image) async {
    try {
      var response = await ApiProvider().s3Put(url, image.readAsBytesSync());
      if (response.statusCode == 200) {
        isUploaded = true;
      }
    } catch (e) {
      throw ('Error uploading photo');
    }
  }

  Future<void> callForWeb(String url, Uint8List image) async {
    try {
      var response = await ApiProvider().s3Put(url, image);
      if (response.statusCode == 200) {
        isUploaded = true;
      }
    } catch (e) {
      throw ('Error uploading photo');
    }
  }
}
