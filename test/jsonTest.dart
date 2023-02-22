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
import 'package:github_client/models/node.dart';
import 'package:tuple/tuple.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized(); //small fix for some async shit

  final repo = jsonRepository();
  List<Node> nodes = [];
  //seed data
  var node1 = Node(id: 1, lon: 1, lat: 1, isAmenity: true, tags: {'amenity':'cafe'});
  nodes.add(node1);
  var node2 = Node(id: 2, lon: 2, lat: 2, isAmenity: true, tags: {'amenity':'restaurant'});
  nodes.add(node2);
  var node3 = Node(id: 3, lon: 3, lat: 3, isAmenity: true, tags: {'amenity':'college'});
  nodes.add(node3);
  var node4 = Node(id: 4, lon: 4, lat: 4, isAmenity: true, tags: {'amenity':'university'});
  nodes.add(node4);

  repo.nodes = nodes;




  await testLoadJSON();


  testLatLonFromCafe(repo);


  testLatLonFromHigherEducation(repo);
}

Future<void> testLoadJSON() async{
  var repo = jsonRepository();
  var scc = await repo.loadJsonData();
  if(scc == "success"){
    print("load JSON test: Success \n");
  }else{
    print("load JSON test: Fail \n");
  }
}

void testLatLonFromCafe(jsonRepository repo){
  var values = repo.getCafesCoords();

  if(values.length == 1 && values.contains(Tuple2(1,1))){
    print("Café test: Success \n");
  }else{
    print("Café test: Fail \n");
    print(values);
  }
}


void testLatLonFromHigherEducation(jsonRepository repo){
  var values = repo.getHigherEducationCoords();

  if(values.length == 2 && values.contains(Tuple2(3, 3))){
    print("Higher education test: Success \n");
  }else{
    print("Higher education test: Fail \n");
    print(values);
  }
}
