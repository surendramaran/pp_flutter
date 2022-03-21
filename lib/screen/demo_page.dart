import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Demo extends StatelessWidget {
  
  // @override
  // void initState() {
  //   // Future.delayed(Duration.zero).then((_) {
  //   //   Provider.of<User>(context).setUser();
  //   // });
  //   super.initState();
  // }
  static const routeName = '/demo';
  Future<void> getData() async {
    http.Response response = await http.get(
      'http://192.168.43.58:3000/api',
      headers: {
        'Cookie': 'accessToken=abc; refreshToken=xyz',
      },
    );
    var data = json.decode(response.body);
    var data2 = response.headers;
    data2.forEach((k, v) => print('$k , $v'));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cookiesData = response.headers['set-cookie'];
    Map cookies = _formatCookies(cookiesData);
    prefs.setString('accessToken', cookies['accessToken']);
    prefs.setString('refreshToken', cookies['refreshToken']);
    print(prefs.getString('accessToken'));
  }

  Map _formatCookies(String cookiesData) {
    Map cookies = {};
    cookiesData.split('; ').forEach(
      (element) {
        List x = element.split('=');
        cookies['${x[0]}'] = '${x[1]}';
      },
    );
    return cookies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('title'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getData,
      ),
    );
  }
}

// var cookiesData = response.headers['set-cookie'];
// Map cookies = _formatCookies(cookiesData);
// if (cookies['accessToken']) {
//   prefs.setString('accessToken', cookies['accessToken']);
// }

// 'Cookie': 'accessToken=$accessToken; refreshToken=$refreshToken',

// SharedPreferences prefs = await SharedPreferences.getInstance();
// var accessToken = prefs.getString('accessToken');
// var refreshToken = prefs.getString('refreshToken');
// if (accessToken == null || refreshToken == null) {
//   _user = null;
//   return;
// }
