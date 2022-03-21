import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:packnary/services/pack_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class PackScreen extends StatefulWidget {
  static const routeName = '/pack';
  @override
  _PackScreenState createState() => _PackScreenState();
}

class _PackScreenState extends State<PackScreen> {
  bool _isInit = true;
  bool _isPackLoaded = false;
  // File _storedImage;
  final picker = ImagePicker();
  var _streamResponse;
  var _client;

  Future<void> _takePicture(int packId) async {
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );
    setState(() {
      if (pickedFile != null) {
        Provider.of<PackService>(context, listen: false)
            .uploadFile(packId, pickedFile.path)
            .then((value) {
          print('file uploaded');
        }).catchError((onError) {
          print(onError);
        });
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  void didChangeDependencies() {
    final packId = ModalRoute.of(context).settings.arguments as int;
    if (_isInit) {
      setState(() {
        _isInit = false;
      });
      Provider.of<PackService>(context, listen: false)
          .fetchPack(packId)
          .then((_) {
        setState(() {
          _isPackLoaded = true;
        });
      }).catchError((onError) {
        print(onError);
      });
      Provider.of<PackService>(context)
          .streamFiles(packId)
          .then((resAndClient) {
        var response = resAndClient['res'];
        _client = resAndClient['client'];
        _streamResponse = response.stream.toStringStream().listen((value) {
          // print(value);
          // print();
          Provider.of<PackService>(context, listen: false)
              .updateFetchedPackFile(json.decode(value));
        });
      });
      //.asStream()
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_streamResponse != null) _streamResponse.cancel();
    if (_client != null) _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final packId = ModalRoute.of(context).settings.arguments as int;
    final pack = Provider.of<PackService>(context).findPackById(packId);
    return Scaffold(
      appBar: AppBar(
        title: _isPackLoaded ? Text(pack.packName) : Text('wait'),
        actions: [],
      ),
      body: _isPackLoaded
          ? Column(
              children: [
                ListTile(
                  title: Text(pack.packName),
                  subtitle: Text('Admin: ${pack.admin.name}'),
                  trailing: pack.packType == 'Public'
                      ? Icon(Icons.public)
                      : Icon(Icons.people),
                ),
                Divider(),
                pack.isMember
                    ? GestureDetector(
                        onTap: () => _takePicture(packId),
                        child: Row(
                          children: [
                            Icon(Icons.add_a_photo),
                            Text('Add a photo')
                          ],
                        ),
                      )
                    : Text('You are not a part of this pack'),
                Divider(),
                Container(
                  child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: pack.files.length,
                    itemBuilder: (ctx, i) => GridTile(
                      child: SingleChildScrollView(
                        child: GestureDetector(
                          onTap: () {},
                          child: Image.network(
                            pack.files[i].imageURL,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                    ),
                  ),
                ),
              ],
            )
          : LinearProgressIndicator(),
    );
  }
}
