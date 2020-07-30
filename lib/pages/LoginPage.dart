import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:navras/models/UserModel.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/utils/Constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  int currentLoading = 0;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var url = '${Constants.SERVER_URL}user/login';

  final _formKey = GlobalKey<FormState>();
  bool passwordVisible = true;

  void startLogin(String email, String password) async {
    try {
      var response = await http.post(
        url,
        body: {'email': email.toLowerCase(), 'password': password},
      );
      var jsonResponse = await convert.jsonDecode(response.body);
      bool error = jsonResponse['error'];
      if(error) {
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
      else {
        var userData = jsonResponse['data'];
        UserModel myModel = UserModel.fromJson(userData);
        //make my model usable to all widgets
        Provider.of<AuthProvider>(context, listen: false).setUserModel(myModel);

        saveData(myModel.userId, myModel.username, myModel.email, passwordController.text);

        Navigator.of(context).pushNamed(Constants.WelcomePageRoute);
      }
    }
    catch (err) {
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
                child: Text('close')
              )
            ],
          );
        }
      );
    }
    finally {
      setState(() {
        currentLoading = 0;
      });
    }
  }

  void saveData(String userId, String username, String email, password) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('user_id', userId);
    sharedPreferences.setString('username', username);
    sharedPreferences.setString('email', email);
    sharedPreferences.setString('password', password);
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        if(_formKey.currentState.validate()) {
          setState(() {
            currentLoading = 1;
          });
          startLogin(emailController.text.trim(), passwordController.text);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.purple
        ),
        child: Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _title() {
    return Text(
      "Navras",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22
      ),
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

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
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
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Email",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    filled: true,
                                  ),
                                  validator: (value) {
                                    if(value.isEmpty) {
                                      return "Please enter username";
                                    }
                                    else {
                                      return null;
                                    }
                                  }
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  "Password",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    filled: true,
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
                                  }
                                )
                              ],
                            ),
                          )
                        ],
                      )
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    currentLoading == 0 ? _submitButton() : progress,

                    SizedBox(
                      height: 45,
                    ),
                    //_facebookButton(),
                    Expanded(
                      flex: 2,
                      child: SizedBox(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      )
    );
  }
}
