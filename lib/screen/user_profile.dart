import 'package:flutter/material.dart';
import 'package:packnary/models/user.dart';
import 'package:packnary/services/auth.dart';
import 'package:packnary/services/pack_service.dart';
import 'package:provider/provider.dart';

import 'home.dart';

class UserProfile extends StatefulWidget {
  static const routeName = '/user-profile';

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Future<void> _logout() async {
    await Provider.of<AuthService>(context, listen: false)
        .logout()
        .then((value) {
      Provider.of<User>(context, listen: false).removeUser();
      Provider.of<PackService>(context, listen: false).clearPacksData();
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Home.routeName, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Scaffold(
        appBar: AppBar(
      title: user.name == null ? Text('Logging Out...') : Text(user.name),
      actions: [
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => _logout(),
        )
      ],
    ));
  }
}
