import 'package:flutter/material.dart';

class ControllerCollectionItem{
  late List<TextEditingController> controllers;

  ControllerCollectionItem(int numOfControllers) {
    controllers = List.filled(numOfControllers, TextEditingController());
  }

  TextEditingController getController(int index) => controllers[index];
}