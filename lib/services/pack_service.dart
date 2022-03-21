import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:packnary/models/http_exection.dart';
import 'package:packnary/models/pack_file.dart';
import 'package:packnary/models/pack.dart';
import 'package:packnary/models/pack_member.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PackService with ChangeNotifier {
  Map<int, Pack> _packsData = {};

  Pack findPackById(int id) {
    return _packsData[id];
  }

  Future<dynamic> explorePack() async {
    const url = 'http://192.168.43.58:3000/api/explore';
    try {
      http.Response response = await http.get(
        url,
      );
      final data = json.decode(response.body);
      List<Pack> _loadedExplorePackData = [];
      if (response.statusCode == 200) {
        data.forEach((element) {
          _loadedExplorePackData.add(Pack(
            packId: element['packId'],
            packName: element['packName'],
            admin: PackMember(name: element['admin']),
          ));
        });
        return _loadedExplorePackData;
      } else if (response.statusCode >= 400) {
        throw HttpException('Error Occurred');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> uploadFile(int packId, String filename) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    String refreshToken = prefs.getString('refreshToken');
    var headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Cookie': 'accessToken=$accessToken; refreshToken=$refreshToken',
    };
    final url = 'http://192.168.43.58:3000/api/pack/$packId/new';
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath('photo', filename));
      http.StreamedResponse response = await request.send();
      var cookiesData = response.headers['set-cookie'];

      if (cookiesData != null) {
        Map _cookies = _formatCookies(cookiesData);
        if (_cookies.containsKey('accessToken')) {
          prefs.setString('accessToken', _cookies['accessToken']);
        }
      }
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode >= 400) {
        throw HttpException('Error Occurred');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<dynamic> streamFiles(int packId) async {
    final client = http.Client();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    String refreshToken = prefs.getString('refreshToken');
    final url = 'http://192.168.43.58:3000/api/pack/$packId/files/events';
    var headers = {
      'Cookie': 'accessToken=$accessToken; refreshToken=$refreshToken',
    };
    try {
      final req = http.Request('GET', Uri.parse(url));
      req.headers.addAll(headers);

      final res = await client.send(req);
      var cookiesData = res.headers['set-cookie'];
      if (cookiesData != null) {
        print(14);
        Map _cookies = _formatCookies(cookiesData);
        print(15);
        if (_cookies.containsKey('accessToken')) {
          prefs.setString('accessToken', _cookies['accessToken']);
        }
      }
      print(16);
      return {'res': res, 'client': client};
    } catch (error) {
      throw error;
    }
  }

  Future<dynamic> fetchPack(int packId) async {
    print(5676);
    if (_packsData.containsKey(packId)) {
      print('exist');
      _updateFetchPackFile(packId);
      return;
    } else {
      final url = 'http://192.168.43.58:3000/api/pack/$packId';
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
        var cookiesData = response.headers['set-cookie'];
        if (cookiesData != null) {
          Map _cookies = _formatCookies(cookiesData);
          if (_cookies.containsKey('accessToken')) {
            prefs.setString('accessToken', _cookies['accessToken']);
          }
        }
        final data = json.decode(response.body);
        if (response.statusCode == 200) {
          _addFetchedPack(data);
        } else if (response.statusCode >= 400) {
          throw HttpException('Error Occurred');
        }
      } catch (error) {
        throw error;
      }
    }
  }

  Future<void> _updateFetchPackFile(int packId) async {
    final url = 'http://192.168.43.58:3000/api/pack/$packId/files';
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
      var cookiesData = response.headers['set-cookie'];
      if (cookiesData != null) {
        Map _cookies = _formatCookies(cookiesData);
        if (_cookies.containsKey('accessToken')) {
          prefs.setString('accessToken', _cookies['accessToken']);
        }
      }
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        updateFetchedPackFile(data);
      } else if (response.statusCode >= 400) {
        throw HttpException('Error Occurred');
      }
    } catch (error) {
      throw error;
    }
  }

  void clearPacksData() {
    _packsData.clear();
    notifyListeners();
  }

  void updateFetchedPackFile(data) {
    var filesData = data['files'];
    var packId = data['packID'];

    List<PackFile> files = _packsData[packId].files;

    filesData.forEach((element) {
      var contains = files.where((e) => e.imageURL == element['imageURL']);

      if (contains.isEmpty) {
        PackFile nf = PackFile(
          imageURL: element['imageURL'],
          uploader: PackMember(
            id: element['uploader']['id'],
            name: element['uploader']['name'],
            image: element['uploader']['image'],
          ),
          uploadedAt: element['uploadedAt'],
        );
        files.add(nf);
        notifyListeners();
      }
    });
  }

  void _addFetchedPack(data) {
    var packData = data['pack'];
    var filesData = data['files'];

    if (!_packsData.containsKey(packData['packID'])) {
      List<PackMember> members = [];
      packData['members'].forEach(
        (element) => members.add(
          PackMember(
            id: element['id'],
            name: element['name'],
            image: element['image'],
          ),
        ),
      );

      List<PackFile> files = [];
      filesData.forEach(
        (element) => files.add(
          PackFile(
            imageURL: element['imageURL'],
            uploader: PackMember(
              id: element['uploader']['id'],
              name: element['uploader']['name'],
              image: element['uploader']['image'],
            ),
            uploadedAt: element['uploadedAt'],
          ),
        ),
      );

      _packsData[packData['packID']] = Pack(
        packId: packData['packID'],
        packName: packData['packName'],
        packType: packData['packType'],
        admin: PackMember(
          id: packData['admin']['id'],
          name: packData['admin']['name'],
          image: packData['admin']['image'],
        ),
        members: members,
        files: files,
        createdAt: packData['createdAt'],
        isMember: data['isMember'],
      );
      notifyListeners();
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
