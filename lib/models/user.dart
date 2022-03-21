import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'http_exection.dart';

class User with ChangeNotifier {
  int id;
  String username;
  String name;
  String pps;
  String ppm;
  String ppf;
  String phone;
  String gender;
  String dob;
  String createdAt;

  User({
    this.id,
    this.username,
    this.name,
    this.pps,
    this.ppm,
    this.ppf,
    this.phone,
    this.gender,
    this.dob,
    this.createdAt,
  });

  Future<dynamic> setUser() async {
    const url = 'http://192.168.43.58:3000/api';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    String refreshToken = prefs.getString('refreshToken');
    print('accessToken: $accessToken');
    print('refreshToken: $refreshToken');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': 'accessToken=$accessToken; refreshToken=$refreshToken',
        },
      );
      print(1);
      final data = json.decode(response.body);
      print(2);
      var cookiesData = response.headers['set-cookie'];
      print(3);
      if (cookiesData != null) {
      print(4);
        Map _cookies = _formatCookies(cookiesData);
      print(5);
        if (_cookies.containsKey('accessToken')) {
      print(6);
          prefs.setString('accessToken', _cookies['accessToken']);
        }
      }
      print(7);
      if (data['user'] == false) {
        print('false user');
        return false;
      }
      print(8);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print('setting user');
        _setValue(data);
        notifyListeners();
        return true;
      } else if (response.statusCode >= 400) {
        throw HttpException('Error Occurred');
      }
    } catch (error) {
      throw error;
    }
  }

  void _setValue(data) {
    id = data['user']['id'];
    username = data['user']['username'];
    name = data['user']['name'];
    pps = data['user']['pps'];
    ppm = data['user']['ppm'];
    ppf = data['user']['ppf'];
    phone = data['user']['phone'];
    gender = data['user']['gender'];
    dob = data['user']['dob'];
    createdAt = data['user']['createdAt'];
  }

  void removeUser() {
    id = null;
    username = null;
    name = null;
    pps = null;
    ppm = null;
    ppf = null;
    phone = null;
    gender = null;
    dob = null;
    createdAt = null;
    notifyListeners();
  }
}

void _deletePreferences(String key) async {
  print('Deleting $key key');
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
