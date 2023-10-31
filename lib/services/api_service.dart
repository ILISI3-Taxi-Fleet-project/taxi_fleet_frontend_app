
import '../config/api_constants.dart';
import 'package:http/http.dart' as http;

class ApiService {

  static Future<bool> login(String email, String password) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.loginEndpoint);
      var response = await http.post(url, body: {
        'email': email,
        'password': password,
      });
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
      var response = await http.post(url, body: {
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'type': type,
        'email': email,
        'password': password,
      });
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