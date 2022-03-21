import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

import 'signup.dart';

class Login extends StatelessWidget {
  static const routeName = '/login';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('Login'),
        actions: [
          FlatButton(
            child: Text('Signup'),
            onPressed: () {
              Navigator.of(context).pushNamed(Signup.routeName);
            },
          ),
        ],
      ),
      body: LoginForm(),
    );
  }
}
