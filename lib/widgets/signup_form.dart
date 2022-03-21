import 'package:flutter/material.dart';

import 'package:packnary/screen/home.dart';
import 'package:packnary/services/auth.dart';
import 'package:provider/provider.dart';

class SignupForm extends StatefulWidget {
  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String _name;
  String _username;
  String _password;
  String _phone;
  String _otp;

  final GlobalKey<FormState> _signupFormKey = GlobalKey<FormState>();

  bool _isFields1Visible = true;
  bool _isFields2Visible = false;
  bool _isOtpLoading = false;

  Widget _buildNameField() {
    return Visibility(
      maintainState: true,
      visible: _isFields1Visible,
      child: TextFormField(
        controller: _nameController,
        decoration: InputDecoration(labelText: 'Name'),
        validator: (value) {
          if (value.isEmpty) {
            return 'Name is Required';
          } else {
            return null;
          }
        },
        onSaved: (String value) {
          _name = value;
        },
      ),
    );
  }

  Widget _buildUsernameField() {
    return Visibility(
      maintainState: true,
      visible: _isFields1Visible,
      child: TextFormField(
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
      ),
    );
  }

  Widget _buildPasswordField() {
    return Visibility(
      maintainState: true,
      visible: _isFields1Visible,
      child: TextFormField(
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
      ),
    );
  }

  Widget _buildPhoneField() {
    return Visibility(
      maintainState: true,
      visible: _isFields1Visible,
      child: TextFormField(
        controller: _phoneController,
        decoration: InputDecoration(
          labelText: 'Phone',
          suffixIcon: RaisedButton(
            child: Text('OTP'),
            onPressed: () => sendPhone(),
          ),
        ),
        validator: (value) {
          if (value.isEmpty) {
            return 'Phone is Required';
          } else {
            return null;
          }
        },
        onSaved: (value) {
          _phone = value;
        },
      ),
    );
  }

  Widget _buildOTPField() {
    return Visibility(
      maintainState: true,
      visible: _isFields2Visible,
      child: TextFormField(
        controller: _otpController,
        decoration: InputDecoration(labelText: 'One Time Password'),
        onSaved: (String value) {
          _otp = value;
        },
      ),
    );
  }

  Future<void> sendPhone() async {
    if (!_signupFormKey.currentState.validate()) {
      return;
    }

    setState(() {
      _isOtpLoading = true;
    });

    _signupFormKey.currentState.save();

    await Provider.of<AuthService>(context, listen: false)
        .phoneVerify(_phone, _name, _username)
        .then((value) {
      if (value['Status'] == "Succeed") {
        setState(() {
          _isFields1Visible = false;
          _isFields2Visible = true;
          _isOtpLoading = false;
        });
      } else {
        setState(() {
          _isOtpLoading = false;
        });
      }
    }).catchError((onError) {});
  }

  Future<void> _saveForm() async {
    if (!_signupFormKey.currentState.validate()) {
      return;
    }
    _signupFormKey.currentState.save();
    Provider.of<AuthService>(context, listen: false)
        .signup(_name, _username, _password, _phone, _otp)
        .then((value) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(Home.routeName, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isOtpLoading
        ? LinearProgressIndicator()
        : Form(
            key: _signupFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNameField(),
                  _buildUsernameField(),
                  _buildPasswordField(),
                  _buildPhoneField(),
                  _buildOTPField(),
                  Visibility(
                    visible: _isFields2Visible,
                    child: RaisedButton(
                      child: Text(
                        'Submit',
                        style: TextStyle(color: Colors.green, fontSize: 16),
                      ),
                      onPressed: _saveForm,
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
