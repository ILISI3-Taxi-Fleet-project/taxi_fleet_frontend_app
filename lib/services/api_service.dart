
import 'dart:convert';

import '../config/api_constants.dart';
import 'package:http/http.dart' as http;

class ApiService {

  static Future<bool> login(String email, String password) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.loginEndpoint);
      
      var data = {
        'username': email,
        'password': password,
      };
      
      var headers = {
        'Content-Type': 'application/json',
      };

      var response = await http.post(url,headers: headers, body: jsonEncode(data));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
  
  static Future<bool> signup(String firstName, String lastName, String phone, String type, email, String password) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.signupEndpoint);
      var data = {
        'username': email,
        'password': password,
        'prenom': firstName,
        'nom': lastName,
        'user_type': type,
        'email': email,
        'phone': phone,
      };

      var headers = {
        'Content-Type': 'application/json',
      };
      var response = await http.post(url,headers: headers, body: jsonEncode(data));
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
  
}