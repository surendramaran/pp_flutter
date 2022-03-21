import 'package:flutter/material.dart';
import 'package:packnary/models/pack_member.dart';
import 'package:packnary/models/user.dart';
import 'package:packnary/services/create.dart';
import 'package:provider/provider.dart';

import 'home.dart';

class CreateScreen extends StatefulWidget {
  static const routeName = '/create';

  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final TextEditingController _packnameController = TextEditingController();
  final TextEditingController _searchMemberController = TextEditingController();

  String _packname;
  String _packType;
  List<int> _packMember = [];
  List<PackMember> _packMemberCard = [];
  List<PackMember> _searchMemberResult = [];

  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();

  Widget _buildNameField() {
    return TextFormField(
      controller: _packnameController,
      decoration: InputDecoration(labelText: 'Pack Name'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Pack Name is Required';
        } else {
          return null;
        }
      },
      onSaved: (String value) {
        _packname = value;
      },
    );
  }

  Widget _buildTypeDropDown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Pack Type'),
      value: _packType,
      icon: Icon(Icons.keyboard_arrow_down),
      onChanged: (String newValue) {
        setState(() {
          _packType = newValue;
        });
      },
      validator: (String value) {
        if (value.isEmpty) {
          return 'Pack Type is Required';
        } else {
          return null;
        }
      },
      items: <String>['Public', 'Private']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildAdeddMemberList() {
    return _packMemberCard.isEmpty
        ? Container()
        : Container(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: _packMemberCard.length,
              itemBuilder: (ctx, i) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ImageIcon(
                    NetworkImage(_packMemberCard[i].image),
                  ),
                  _packMemberCard[i].name.length > 14
                      ? Text('${_packMemberCard[i].name.substring(0, 12)}...')
                      : Text(_packMemberCard[i].name),
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _packMemberCard.removeWhere(
                          (element) => element.id == _packMemberCard[i].id,
                        );
                      });
                      _packMember.remove(_packMemberCard[i].id);
                    },
                  ),
                ],
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4 / 1,
              ),
              // scrollDirection: Axis.vertical,
            ),
          );
  }

  Widget _buildSearchMemberField() {
    return TextFormField(
      controller: _searchMemberController,
      decoration: InputDecoration(
        labelText: 'Seach for a person',
        suffixIcon: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            setState(() {
              _searchMemberController.text = '';
              _searchMemberResult.clear();
            });
          },
        ),
      ),
      onChanged: (value) {
        if (value.trimLeft() == '') {
          setState(() {
            _searchMemberResult.clear();
          });
        } else {
          _searchMember(value);
        }
      },
    );
  }

  Widget _buildSearchMemberResultList() {
    return _searchMemberResult.isEmpty
        ? Container()
        : ListView.builder(
            shrinkWrap: true,
            itemCount: _searchMemberResult.length,
            itemBuilder: (ctx, i) => GestureDetector(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  child: Image.network(_searchMemberResult[i].image),
                ),
                title: Text(_searchMemberResult[i].name),
              ),
              onTap: () {
                var member = PackMember(
                  id: _searchMemberResult[i].id,
                  image: _searchMemberResult[i].image,
                  name: _searchMemberResult[i].name,
                );
                if (!_packMember.contains(_searchMemberResult[i].id) ||
                    (_packMember.length > 9)) {
                  setState(() {
                    _packMemberCard.add(member);
                  });
                  _packMember.add(_searchMemberResult[i].id);
                }
              },
            ),
          );
  }

  Future<void> _searchMember(String text) async {
    await Provider.of<CreateService>(context, listen: false)
        .searchTextMember(text)
        .then((value) {
      setState(() {
        _searchMemberResult.clear();
      });
      if (value == null) {
        return;
      }
      setState(() {
        _searchMemberResult = value;
      });
    }).catchError((onError) {});
  }

  Future<void> _saveCreateForm() async {
    if (!_createFormKey.currentState.validate()) {
      return;
    }
    _createFormKey.currentState.save();
    int _admin = Provider.of<User>(context, listen: false).id;
    await Provider.of<CreateService>(context, listen: false)
        .createPack(_packname, _packType, _admin, _packMember)
        .then((value) {
      if (value != null) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Home.routeName, (route) => false);
      } else {
        Navigator.of(context).pushReplacementNamed(CreateScreen.routeName);
      }
    }).catchError((onError) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('Create'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _createFormKey,
          child: Column(
            children: [
              _buildNameField(),
              _buildTypeDropDown(),
              _buildAdeddMemberList(),
              _buildSearchMemberField(),
              _buildSearchMemberResultList(),
              RaisedButton(
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                onPressed: _saveCreateForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
