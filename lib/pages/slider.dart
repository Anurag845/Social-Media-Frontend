import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_xlider/flutter_xlider.dart';

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<FlutterSliderHatchMarkLabel> effects = [];
  List<Map<dynamic, dynamic>> mEffects = [];
  double ellv = 30;
  double euuv = 60;

  void initState() {
    super.initState();

    var rng = new Random();
    for (double i = 0; i < 100; i++) {
      mEffects.add({"percent": i, "size": 5 + rng.nextInt(60 - 5).toDouble()});
    }
    effects = updateEffects(
        ellv * 100 / mEffects.length, euuv * 100 / mEffects.length);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Slider"),
      ),
      body: Container(
              padding: EdgeInsets.all(20),
              height: 140,
              child: FlutterSlider(
                rangeSlider: true,
                min: 0,
                max: effects.length.toDouble(),
                values: [ellv, euuv],
                handler: FlutterSliderHandler(
                    decoration: BoxDecoration(),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.black.withOpacity(0.65), width: 1)),
                    )),
                rightHandler: FlutterSliderHandler(
                    decoration: BoxDecoration(),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.black.withOpacity(0.65), width: 1)),
                    )),
                handlerWidth: 6,
                handlerHeight: 40,
                touchSize: 20,
                tooltip: FlutterSliderTooltip(
                    format: (value) {
                      return value + ' MHz';
                    },
                    textStyle: TextStyle(fontSize: 40),
                    boxStyle: FlutterSliderTooltipBox(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border:
                                Border.all(color: Colors.black54, width: 1)))),
                hatchMark: FlutterSliderHatchMark(
                  labels: effects,
                  linesAlignment: FlutterSliderHatchMarkAlignment.right,
                  density: 0.5,
                ),
                trackBar: FlutterSliderTrackBar(
                    inactiveTrackBar: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    activeTrackBarHeight: 2,
                    inactiveTrackBarHeight: 1,
                    activeTrackBar: BoxDecoration(
                      color: Colors.transparent,
                    )),
                onDragging: (a, b, c) {
                  ellv = b;
                  euuv = c;
                  effects = updateEffects(
                      b * 100 / mEffects.length, c * 100 / mEffects.length);
                  setState(() {});
                }
              ),
            ),
    );
  }

  List<FlutterSliderHatchMarkLabel> updateEffects(
      double leftPercent, double rightPercent) {
    List<FlutterSliderHatchMarkLabel> newLabels = [];
    for (Map<dynamic, dynamic> label in mEffects) {
      if (label['percent'] >= leftPercent && label['percent'] <= rightPercent) {
        newLabels.add(FlutterSliderHatchMarkLabel(
            percent: label['percent'],
            label: Container(
              height: label['size'],
              width: 2.5,
              color: Colors.red,
            )));
      } else {
        newLabels.add(FlutterSliderHatchMarkLabel(
            percent: label['percent'],
            label: Container(
              height: label['size'],
              width: 1,
              color: Colors.black26,
            )));
      }
    }
    return newLabels;
  }
}