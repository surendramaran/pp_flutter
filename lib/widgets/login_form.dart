import 'package:flutter/material.dart';
import 'package:packnary/screen/home.dart';
import 'package:packnary/services/auth.dart';
import 'package:packnary/services/pack_service.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _username;
  String _password;

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      decoration: InputDecoration(labelText: 'Username'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Username is Required';
        } else {
          return null;
        }
      },
      onSaved: (String value) {
        _username = value;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(labelText: 'Password'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Password is Required';
        } else {
          return null;
        }
      },
      onSaved: (String value) {
        _password = value;
      },
    );
  }

  Future<void> _saveForm() async {
    if (!_loginFormKey.currentState.validate()) {
      return;
    }
    _loginFormKey.currentState.save();
    Provider.of<AuthService>(context, listen: false)
        .login(_username, _password)
        .then((_) {
          print('loging done');
      Provider.of<PackService>(context, listen: false).clearPacksData();
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Home.routeName, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _loginFormKey,
      child: _isLoading
          ? LinearProgressIndicator()
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildUsernameField(),
                _buildPasswordField(),
                RaisedButton(
                  child: Text(
                    'Submit',
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                  onPressed: _saveForm,
                ),
              ],
            ),
    );
  }
}
