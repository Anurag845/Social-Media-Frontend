import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:navras/models/UserModel.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/utils/Classes.dart';
import 'package:navras/utils/Constants.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';

class CreateProfile extends StatefulWidget {
  final UserDetails googleUser;

  CreateProfile(this.googleUser);

  @override
  _CreateProfileState createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _birthplaceController = TextEditingController();
  TextEditingController _birthdateController = TextEditingController();
  TextEditingController _birthtimeController = TextEditingController();
  String _genderValue;
  DateTime _birthDate;
  String _timeZone = 'Early Morning';
  TimeOfDay _birthTime;

  Map<String,String> _timeMap = {
    'Early Morning': '05:00',
    'Morning': '09:00',
    'Afternoon': '13:00',
    'Evening': '17:00',
    'Night': '21:00',
    'Late Night': '01:00'
  };

  bool passwordVisible = true;
  final _formKey = GlobalKey<FormState>();

  bool _registering = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _displayNameController.dispose();
    _birthplaceController.dispose();
    _birthdateController.dispose();
    _birthtimeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 134,
                  width: double.infinity,
                  child: Image.asset("assets/images/blurred_bubbles.jpg"),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.only(top: 94),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(widget.googleUser.photoUrl),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.only(top: 182),
                    child: Text(
                      //"Username",
                      //_googleUserModel.userName,
                      widget.googleUser.displayName,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Create your Profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
              )
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width/3-8,
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            "Username",
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          width: 2*MediaQuery.of(context).size.width/3-30,
                          child: TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black, width: 0.0),
                              ),
                              hintText: "Username"
                            ),
                            validator: (value) {
                              if(value.isEmpty) {
                                return "Please enter username";
                              }
                              else {
                                return null;
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width/3-8,
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            "Password",
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          width: 2*MediaQuery.of(context).size.width/3-30,
                          child: TextFormField(
                            controller: _passwordController,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black, width: 0.0),
                              ),
                              hintText: "Password",
                              suffixIcon: IconButton(
                                icon: Icon(
                                  passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off
                                ),
                                onPressed: () {
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                                color: Colors.black,
                              )
                            ),
                            obscureText: passwordVisible,
                            validator: (value) {
                              if(value.isEmpty) {
                                return "Please enter password";
                              }
                              else if(value.length < 8) {
                                return "Password should be minimum 8 characters long";
                              }
                              else {
                                return null;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width/3-8,
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            "First Name",
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          width: 2*MediaQuery.of(context).size.width/3-30,
                          child: TextFormField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black, width: 0.0),
                              ),
                              hintText: "First Name"
                            ),
                            validator: (value) {
                              if(value.isEmpty) {
                                return "Please enter your first name";
                              }
                              else {
                                return null;
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width/3-8,
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            "Last Name",
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          width: 2*MediaQuery.of(context).size.width/3-30,
                          child: TextFormField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black, width: 0.0),
                              ),
                              hintText: "Last Name"
                            ),
                            validator: (value) {
                              if(value.isEmpty) {
                                return "Please enter your last name";
                              }
                              else {
                                return null;
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width/3-8,
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            "Last Name",
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          width: 2*MediaQuery.of(context).size.width/3-30,
                          child: TextFormField(
                            controller: _displayNameController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black, width: 0.0),
                              ),
                              hintText: "Display Name"
                            ),
                            validator: (value) {
                              if(value.isEmpty) {
                                return "Please enter your display name";
                              }
                              else {
                                return null;
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width/3-8,
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            "I am a",
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          width: 2*MediaQuery.of(context).size.width/3-30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Radio(
                                value: "Male",
                                groupValue: _genderValue,
                                onChanged: (value) {
                                  setState(() {
                                    _genderValue = value;
                                  });
                                },
                                activeColor: Colors.purple,
                              ),
                              Text("Male"),
                              Radio(
                                value: "Female",
                                groupValue: _genderValue,
                                onChanged: (value) {
                                  setState(() {
                                    _genderValue = value;
                                  });
                                },
                                activeColor: Colors.purple,
                              ),
                              Text("Female")
                            ],
                          )
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width/3-8,
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            "I was born in",
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          width: 2*MediaQuery.of(context).size.width/3-30,
                          child: TextFormField(
                            controller: _birthplaceController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black, width: 0.0),
                              ),
                              hintText: "Birth Place"
                            ),
                            validator: (value) {
                              if(value.isEmpty) {
                                return "Please enter birth place";
                              }
                              else{
                                return null;
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width/3-8,
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            "On",
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          width: 2*MediaQuery.of(context).size.width/3-30,
                          child: TextFormField(
                            controller: _birthdateController,
                            readOnly: true,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black, width: 0.0),
                              ),
                              hintText: "Birth Date",
                              suffixIcon: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.calendar_today,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime(1998),
                                    firstDate: DateTime(1947),
                                    lastDate: DateTime(2002)
                                  ).then((date) {
                                    setState(() {
                                      _birthDate = date;
                                      _birthdateController.text = DateFormat("yyyy-MM-dd").format(_birthDate);
                                    });
                                  });
                                }
                              )
                            ),
                            validator: (value) {
                              if(value.isEmpty) {
                                return "Please enter birth date";
                              }
                              else {
                                return null;
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width/3-8,
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: Text(
                            "At",
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          width: 2*MediaQuery.of(context).size.width/3-30,
                          child: DropdownButton<String>(
                            value: _timeZone,
                            items: <String>['Early Morning', 'Morning', 'Afternoon', 'Evening',
                              'Night', 'Late Night']
                              .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _timeZone = value;
                                _birthtimeController.text = _timeMap[value];
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width/3-8,
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          //child:
                        ),
                        Container(
                          width: 2*MediaQuery.of(context).size.width/3-30,
                          child: TextFormField(
                            controller: _birthtimeController,
                            readOnly: true,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.grey, width: 0.0),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black, width: 0.0),
                              ),
                              hintText: "Birth Time",
                              suffixIcon: IconButton(
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.watch_later,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now()
                                  ).then((time) {
                                    setState(() {
                                      _birthTime = time;
                                      _birthtimeController.text = _birthTime.format(context);
                                    });
                                  });
                                }
                              )
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  _registering
                  ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.purple,
                        ),
                      ),
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.all(40),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      color: Colors.purple,
                      onPressed: () async {
                        if(_formKey.currentState.validate()) {
                          if(_genderValue == null) {
                            Fluttertoast.showToast(msg: "Please select gender");
                          }
                          else {
                            setState(() {
                              _registering = true;
                            });
                            //perform user registration
                            await _register();
                            //perform user login
                            await _login(widget.googleUser.userEmail, _passwordController.text.trim());
                          }
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                        child: Text(
                          "Create",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        )
      )
    );
  }

  _register() async {
    try {
      var response = await http.post(
        '${Constants.SERVER_URL}user/create',
        body: {
          'email': widget.googleUser.userEmail,
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
          'firstname': _firstNameController.text.trim(),
          'lastname': _lastNameController.text.trim(),
          'displayname': _displayNameController.text.trim(),
          'gender': _genderValue,
          'birthplace': _birthplaceController.text.trim(),
          'birthdate': _birthdateController.text.trim(),
          'birthtime': _birthtimeController.text.trim(),
          'profile_pic': widget.googleUser.photoUrl
        }
      );
      var jsonResponse = convert.jsonDecode(response.body);
      bool error = jsonResponse['error'];
      if(!error) {
        var userData = jsonResponse['data'];
        UserModel myModel = UserModel.fromJson(userData);

        Provider.of<AuthProvider>(context, listen: false).setUserModel(myModel);

        saveData(
          myModel.userId, myModel.username, myModel.email, _passwordController.text.trim()
        );
      }
      else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('${jsonResponse['data']}'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('close')
                )
              ],
            );
          }
        );
      }
    }
    catch(err) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Check your internet connection'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('close')
              )
            ],
          );
        }
      );
    }
  }

  _login(String email, String password) async {

    var url = '${Constants.SERVER_URL}user/login';

    try {
      var response = await http.post(
        url,
        body: {'email': email, 'password': password},
      );
      var jsonResponse = await convert.jsonDecode(response.body);
      bool error = jsonResponse['error'];

      if (error) {
        Navigator.of(context).pushReplacementNamed(
          Constants.LoginPageRoute,
        );
      }
      else {
        var userData = jsonResponse['data'];
        UserModel myModel = UserModel.fromJson(userData);

        Provider.of<AuthProvider>(context, listen: false).setUserModel(myModel);

        Navigator.of(context).pushReplacementNamed(
          Constants.WelcomePageRoute,
        );
      }
    }
    catch (err) {
      Navigator.of(context).pushReplacementNamed(
        Constants.LoginPageRoute,
      );
    }
  }

  void saveData(String id, String name, String email, password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('user_id', id);
    sharedPreferences.setString('username', name);
    sharedPreferences.setString('email', email);
    sharedPreferences.setString('password', password);
  }
}
