import 'package:flutter/material.dart';

class ControllerCollectionItem{
  late List<TextEditingController> controllers;

  ControllerCollectionItem(int numOfControllers) {
    controllers = List.generate(numOfControllers, (index) => TextEditingController());
  }

  ControllerCollectionItem.fromValueList(List<String> values){
    controllers = List.generate(values.length, (index) => TextEditingController(text: values[index]));
  }

  TextEditingController getController(int index) => controllers[index];
}