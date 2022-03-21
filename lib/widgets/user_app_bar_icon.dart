import 'package:flutter/material.dart';
import 'package:packnary/models/user.dart';
import 'package:packnary/screen/login.dart';
import 'package:packnary/screen/user_profile.dart';
import 'package:provider/provider.dart';

class UserAppBarIcon extends StatelessWidget {
  final bool isLoggedIn;

  UserAppBarIcon({@required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return isLoggedIn
        ? GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(UserProfile.routeName);
            },
            child: Image.network(user.pps),
          )
        : IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed(Login.routeName);
            },
          );
  }
}

// isLoggedIn
//         ? GestureDetector(
//             onTap: () {
//               Navigator.of(context).pushNamed(UserProfile.routeName);
//             },
//             // child: Image.network(user.pps),
//           )
//         : IconButton(
//             icon: Icon(Icons.person),
//             onPressed: () {
//               Navigator.of(context).pushNamed(Login.routeName);
//             },
//           )
