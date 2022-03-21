import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:packnary/models/http_exection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService with ChangeNotifier {
  Future<void> signup(String name, String username, String password,
      String phone, String otp) async {
    const url = 'http://192.168.43.58:3000/api/signup';

    try {
      http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'name': name,
          'username': username,
          'password': password,
          'phone': phone,
          'otp': otp,
        }),
      );
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var cookiesData = response.headers['set-cookie'];
        Map _cookies = _formatCookies(cookiesData);
        prefs.setString('accessToken', _cookies['accessToken']);
        prefs.setString('refreshToken', _cookies['refreshToken']);
      } else if (response.statusCode >= 400) {
        throw HttpException('Error Occurred');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<dynamic> phoneVerify(
      String phone, String name, String username) async {
    const url = 'http://192.168.43.58:3000/api/signup/verifyphone';
    try {
      http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'phone': phone,
          'name': name,
          'username': username,
        }),
      );
      final statusCode = response.statusCode;
      if (statusCode >= 200 && statusCode < 299) {
        return jsonDecode(response.body);
      } else if (response.statusCode >= 400) {
        throw HttpException('Error Occurred');
      }
      // else if (statusCode >= 400 && statusCode < 500) {
      //   throw ClientErrorException();
      // } else if (statusCode >= 500 && statusCode < 600) {
      //   throw ServerErrorException();
      // } else {
      //   throw UnknownException();
      // }
    } catch (error) {
      throw error;
    }
    // on SocketException {
    //   throw ConnectionException();
    // }
  }

  Future<void> login(String username, String password) async {
    const url = 'http://192.168.43.58:3000/api/login';
    try {
      http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var cookiesData = response.headers['set-cookie'];
        Map _cookies = _formatCookies(cookiesData);
        // _cookies.forEach((key, value) => print('$key, $value'));
        prefs.setString('accessToken', _cookies['accessToken']);
        prefs.setString('refreshToken', _cookies['refreshToken']);
        print(prefs.getString('accessToken'));
        print(prefs.getString('refreshToken'));
        return;
      } else if (response.statusCode >= 400) {
        throw HttpException('Error Occurred');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String refreshToken = prefs.getString('refreshToken');
    const url = 'http://192.168.43.58:3000/api/logout';
    try {
      http.Response response = await http.get(
        url,
        headers: {
          'Cookie': 'refreshToken=$refreshToken;',
        },
      );
      if (response.statusCode == 200) {
        prefs.remove('accessToken');
        prefs.remove('refreshToken');
      } else if (response.statusCode >= 400) {
        throw HttpException('Error Occurred');
      }
    } catch (error) {
      throw error;
    }
  }
}

void _deletePreferences(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}

Map _formatCookies(String cookiesData) {
  Map cookies = {};
  if (cookiesData.contains('accessToken')) {
    List at =
        RegExp(r'(accessToken)(.*?)[^;]+').stringMatch(cookiesData).split('=');
    if (at[1] == '') {
      _deletePreferences('accessToken');
    } else {
      cookies['accessToken'] = at[1];
    }
  }
  if (cookiesData.contains('refreshToken')) {
    List rt =
        RegExp(r'(refreshToken)(.*?)[^;]+').stringMatch(cookiesData).split('=');
    if (rt[1] == '') {
            _deletePreferences('refreshToken');
    } else {
      cookies['refreshToken'] = rt[1];
    }
  }
  return cookies;
}
