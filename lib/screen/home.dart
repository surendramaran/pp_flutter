import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:packnary/models/user.dart';

import 'package:packnary/screen/createScreen.dart';

import 'package:packnary/widgets/explore_pack.dart';
import 'package:packnary/widgets/search_bar.dart';
import 'package:packnary/widgets/user_app_bar_icon.dart';

class Home extends StatefulWidget {
  static const routeName = '/';
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _isInit = true;
  var _isLoggedIn = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<User>(context).setUser().then((user) {
        print(user);
        if (user == false) {
          print('not logged');
        } else {
          print('logeedIn changed to true');
          setState(() {
            _isLoggedIn = true;
          });
        }
        setState(() {
          _isInit = false;
        });
      }).catchError((onError) {
        print(onError);
        showDialogBox();
      });
    }
    super.didChangeDependencies();
  }

  showDialogBox() {
    return showDialog<Null>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error ocuured!'),
        content: Text('Something went wrong.'),
        actions: [
          FlatButton(
            child: Text('Okay', style: TextStyle(color: Colors.black)),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 32),
            SizedBox(width: 7),
            Text(
              'Packnary',
              style: TextStyle(
                fontFamily: 'Rancho',
                fontSize: 32,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          SearchBar(''),
          _isLoggedIn
              ? IconButton(
                  icon: Icon(Icons.queue),
                  onPressed: () {
                    Navigator.of(context).pushNamed(CreateScreen.routeName);
                  },
                )
              : Container(),
          UserAppBarIcon(isLoggedIn: _isLoggedIn),
        ],
      ),
      body: ExplorePack(),
    );
  }
}
