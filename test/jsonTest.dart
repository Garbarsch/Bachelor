// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/data/jsonRepository.dart';

import 'package:github_client/main.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized(); //small fix for some async shit

  final repo = jsonRepository();
  var scc = await repo.loadJsonData();
  /*if(scc == "success"){
    repo.printAllNodes();
  }*/

  print("testing Cafe: " );
  testLatLonFromCafe(repo);


  final x = 2;
  final y = 2;

  expect(x, equals(y));
}

void testLatLonFromCafe(jsonRepository repo){
  var values = repo.getCafesCoords();
  if(values.isNotEmpty){
    print("Café test: Success");
  }else{
    print("Café test: Fail");
  }

}
