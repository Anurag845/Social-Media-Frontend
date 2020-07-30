/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:navras/models/UserModel.dart';
import 'package:navras/pages/CompletSignupPage.dart';
import 'package:navras/pages/LoginPage.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/utils/Constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:navras/widgets/bezierContainer.dart';


class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int currentLoading = 0;
  var url = '${Constants.SERVER_URL}user/create';
  var emailController = TextEditingController();
  var nameController = TextEditingController();
  var passwordController = TextEditingController();

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
  }

  Widget _entryField(String title, controller, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: controller,
              obscureText: isPassword,
              decoration:
                  InputDecoration(border: InputBorder.none, filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        setState(() {
          currentLoading = 1;
        });
        startRegister();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xfffbb448), Color(0xfff7892b)])),
        child: Text(
          'Register Now',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Already have an account ?',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            width: 10,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text(
              'Login',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'V',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xffe46b10),
          ),
          children: [
            TextSpan(
              text: ' Chat',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: ' App',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            ),
          ]),
    );
  }

  Widget progress = Container(
    padding: EdgeInsets.symmetric(vertical: 15),
    alignment: Alignment.center,
    child: CircularProgressIndicator(
      backgroundColor: Colors.green,
      strokeWidth: 7,
    ),
  );

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Username", nameController),
        _entryField("Email id", emailController),
        _entryField("Password", passwordController, isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: SizedBox(),
                ),
                _title(),
                SizedBox(
                  height: 50,
                ),
                _emailPasswordWidget(),
                SizedBox(
                  height: 20,
                ),
                currentLoading == 0 ? _submitButton() : progress,
                Expanded(
                  flex: 2,
                  child: SizedBox(),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _loginAccountLabel(),
          ),
          Positioned(top: 40, left: 0, child: _backButton()),
          Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer())
        ],
      ),
    )));
  }

  void startRegister() async {
    try {
      var response = await http.post(url, body: {
        'user_name': nameController.text.trim(),
        'email': emailController.text.toLowerCase().trim(),
        'password': passwordController.text
      });
      var jsonResponse = await convert.jsonDecode(response.body);
      bool error = jsonResponse['error'];
      if (error) {
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
            });
      } else {
        var userData = jsonResponse['data'];
        UserModel myModel = UserModel.fromJson(userData);
        //make my model usable to all widgets
        Provider.of<AuthProvider>(context, listen: false).userModel = myModel;

        saveData(
            myModel.userId, myModel.username, myModel.email, passwordController.text);
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CompleteSignUpPage(myModel.userId)));
      }
    } catch (err) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('check your internet connection'),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('close'))
              ],
            );
          });
    } finally {
      setState(() {
        currentLoading = 0;
      });
    }
  }

  void saveData(String id, String name, String email, password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('user_id', id);
    sharedPreferences.setString('username', name);
    sharedPreferences.setString('email', email);
    sharedPreferences.setString('password', password);
  }
}*/

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:navras/models/GoogleUserModel.dart';
import 'package:navras/pages/ExpressList.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/utils/Constants.dart';
import 'package:provider/provider.dart';

class CreateProfile extends StatefulWidget {
  @override
  _CreateProfileState createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {

  GoogleUserModel _googleUserModel;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _birthplaceController = TextEditingController();
  TextEditingController _birthdateController = TextEditingController();
  TextEditingController _birthtimeController = TextEditingController();
  String _genderValue;
  DateTime _birthDate;
  TimeOfDay _birthTime;

  bool passwordVisible = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _googleUserModel = Provider.of<AuthProvider>(context, listen: false).googleUserModel;
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
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
                      backgroundImage: NetworkImage(_googleUserModel.photoUrl),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: EdgeInsets.only(top: 182),
                    child: Text(
                      _googleUserModel.userName,
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
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      color: Colors.purple,
                      onPressed: () {
                        if(_formKey.currentState.validate()) {
                          if(_genderValue == null) {
                            Fluttertoast.showToast(msg: "Please select gender");
                          }
                          else {
                            Navigator.of(context).pushReplacementNamed(
                              Constants.WelcomePageRoute
                            );
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
}
