import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:packnary/models/http_exection.dart';
import 'package:packnary/models/pack_member.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CreateService with ChangeNotifier {
  Future<dynamic> searchTextMember(String text) async {
    final url = 'http://192.168.43.58:3000/api/create/getuser/$text';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    String refreshToken = prefs.getString('refreshToken');
    try {
      http.Response response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': 'accessToken=$accessToken; refreshToken=$refreshToken',
        },
      );
      final data = json.decode(response.body);
      var cookiesData = response.headers['set-cookie'];
      if (cookiesData != null) {
        Map _cookies = _formatCookies(cookiesData);
        if (_cookies.containsKey('accessToken')) {
          prefs.setString('accessToken', _cookies['accessToken']);
        }
      }
      if (response.statusCode == 200) {
        if (data['result'].isEmpty) {
          return null;
        } else {
          List<PackMember> result = [];
          data['result'].forEach((element) {
            result.add(
              PackMember(
                id: element['id'],
                name: element['name'],
                image: element['image'],
              ),
            );
          });
          return result;
        }
      } else if (response.statusCode >= 400) {
        throw HttpException('Error Occurred');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<dynamic> createPack(
      String packname, String packType, int admin, List members) async {
    final url = 'http://192.168.43.58:3000/api/create';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    String refreshToken = prefs.getString('refreshToken');
    try {
      http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': 'accessToken=$accessToken; refreshToken=$refreshToken',
        },
        body: json.encode({
          'packname': packname,
          'packType': packType,
          'admin': admin,
          'members': members,
        }),
      );
      var cookiesData = response.headers['set-cookie'];
      if (cookiesData != null) {
        Map _cookies = _formatCookies(cookiesData);
        if (_cookies.containsKey('accessToken')) {
          prefs.setString('accessToken', _cookies['accessToken']);
        }
      }
      if (response.statusCode == 200) {
        return true;
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