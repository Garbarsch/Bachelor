/*
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/data/xmlRepository.dart';
import 'package:xml/xml.dart';


import 'package:github_client/main.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized(); //small fix for some async shit

  final repo = xmlRepository();
  XmlDocument doc = await repo.loadDoc();
  var cafes = repo.getAllCafes(doc);

  print(cafes.first);

  final x = 2;
  final y = 2;

  expect(x, equals(y));
}
*/
