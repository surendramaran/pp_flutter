import 'package:flutter/material.dart';
import 'package:packnary/widgets/signup_form.dart';

class Signup extends StatelessWidget {
  static const routeName = '/signup';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
        elevation: 1,
      ),
      body: SignupForm(),
    );
  }
}
