import 'package:flutter/material.dart';
import 'package:navras/models/CategoryModel.dart';
import 'package:navras/models/UserModel.dart';
import 'package:navras/providers/AuthProvider.dart';
import 'package:navras/providers/CategoryProvider.dart';
import 'package:provider/provider.dart';

class ChoiceChipDisplay extends StatefulWidget {
  @override
  _ChoiceChipDisplayState createState() => _ChoiceChipDisplayState();
}

class _ChoiceChipDisplayState extends State<ChoiceChipDisplay> {
  List<CategoryModel> chipList = [];
  CategoryModel choice;
  UserModel _userModel;

  @override
  void initState() {
    super.initState();
    _userModel = Provider.of<AuthProvider>(context, listen: false).userModel;
    Provider.of<CategoryProvider>(context, listen: false)
        .getAllCategories(_userModel.accessToken);
  }

  @override
  Widget build(BuildContext context) {
    chipList = Provider.of<CategoryProvider>(context, listen: true).allCategories;
    return new Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.cancel,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          }
        ),
        title: Text(
          "Categories",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop(choice);
            }
          ),
        ],
      ),
      body: Center(
        child: Material(
          color: Colors.white,
          elevation: 14.0,
          borderRadius: BorderRadius.circular(24.0),
          shadowColor: Color(0x802196F3),
          child: Container(
            width: 380,
            height: 400,
            child: Column(
              children: <Widget>[
                /*Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  //color: new Color(0xffffc107),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Color(0xffffc107),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Question 3',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Text(
                      'Find the synonym of',
                      style: TextStyle(color: Colors.black, fontSize: 18.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Text(
                      'Adroit',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 42.0,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),*/
                Container(
                  child: Wrap(
                    spacing: 5.0,
                    runSpacing: 5.0,
                    children: <Widget>[
                      ChoiceChipWidget(chipList, (choiceReceived) {
                        choice = choiceReceived;
                        print("Choice is " + choice.categoryName);
                      }),
                    ],
                  )
                ),
                /*Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Container(
                    child: RaisedButton(
                      color: Color(0xffffbf00),
                      child: new Text(
                        'Next',
                        style: TextStyle(
                          color: Color(0xffffffff),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      onPressed: () {},
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)
                      )
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChoiceChipWidget extends StatefulWidget {
  final List<CategoryModel> reportList;
  final ValueChanged<CategoryModel> selectedChoice;
  ChoiceChipWidget(this.reportList,this.selectedChoice);

  @override
  ChoiceChipWidgetState createState() => new ChoiceChipWidgetState();
}

class ChoiceChipWidgetState extends State<ChoiceChipWidget> {
  CategoryModel selectedChoice;

  _buildChoiceList() {
    List<Widget> choices = List();
    widget.reportList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(item.categoryName),
          labelStyle: TextStyle(
            color: Colors.black, fontSize: 14.0, fontWeight: FontWeight.bold
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: Color(0xffededed),
          selectedColor: Color(0xffffc107),
          selected: selectedChoice == item,
          onSelected: (selected) {
            setState(() {
              selectedChoice = item;
              widget.selectedChoice(selectedChoice);
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}