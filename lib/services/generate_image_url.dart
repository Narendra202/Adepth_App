import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../providers/ApiProvider.dart';

class GenerateImageUrl {
  late bool success;
  late String message;

  late bool isGenerated;
  late String uploadUrl;
  late String downloadUrl;
  late String s3Key;
  // final storage = const FlutterSecureStorage();

  String IPAddress = "13.232.38.11";

  Future<void> call(String fileType, String folderName) async {
    try {
      String? userId = "41112113";

      Map body = {
        "fileType": fileType,
        "folderName": folderName,
        "userId": userId.toString()
      };

      var response = await ApiProvider()
          .s3Post("http://$IPAddress:8080/generatePresignedUrl", body);

      var result = jsonDecode(response.body);

      if (result['success'] != null) {
        success = result['success'];
        message = result['message'];

        if (response.statusCode == 201) {
          isGenerated = true;
          uploadUrl = result["uploadUrl"];
          downloadUrl = result["downloadUrl"];
          s3Key = result["s3Key"];
        }
      }
    } catch (e) {
      throw ('Error getting url');
    }
  }

  getImageUrl(String key) async {
    String url = "";
    try {
      Map body = {"key": key};
      var response =
          await ApiProvider().s3Post("http://$IPAddress:8080/getObject", body);

      if (response.statusCode == 200) {
        url = jsonDecode(response.body);
      }
    } catch (e) {
      throw (e);
    }

    return url;
  }
}
