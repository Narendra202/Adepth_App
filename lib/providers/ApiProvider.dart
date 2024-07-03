import 'package:expedition_poc/providers/CustomException.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:async';

class ApiProvider {
  // final storage = const FlutterSecureStorage();

  Future<dynamic> get(String url) async {
    var responseJson;
    try {
      var parsedURL = Uri.parse(url);

      // Read value
      // String? userId = await storage.read(key: "userId");
      String? userId = "41112113";
      Map<String, String> headers = {
        "userid": userId.toString(),
      };

      final response = await http.get(parsedURL, headers: headers);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(String url, body) async {
    var responseJson;
    try {
      var parsedURL = Uri.parse(url);

      // Read value
      String? userId = "41112113";
      Map<String, String> headers = {
        "userid": userId.toString(),
      };

      var response =
          await http.post(parsedURL, body: json.encode(body), headers: headers);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> s3Post(String url, body) async {
    var response;
    try {
      var parsedURL = Uri.parse(url);

      response = await http.post(parsedURL, body: body);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return response;
  }

  Future<dynamic> s3Put(String url, body) async {
    var response;
    try {
      var parsedURL = Uri.parse(url);
      response = await http.put(parsedURL, body: body);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return response;
  }

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = jsonDecode(response.body)["data"];
        return responseJson;
      case 201:
        var responseJson = jsonDecode(response.body)["data"];
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:

      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:

      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
