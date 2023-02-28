// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/data/jsonRepository.dart';

import 'package:github_client/models/node.dart';
import 'package:tuple/tuple.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized(); //small fix for some async shit

  final repo = jsonRepository();
  Map<int, Node> nodes = {};
  //seed data
  var node1 = Node(id: 1, lon: 1, lat: 1, isAmenity: true, tags: {'amenity':'cafe'});
  nodes[node1.id] = node1;
  var node2 = Node(id: 2, lon: 2, lat: 2, isAmenity: true, tags: {'amenity':'restaurant'});
  nodes[node2.id] = node2;
  var node3 = Node(id: 3, lon: 3, lat: 3, isAmenity: true, tags: {'amenity':'college'});
  nodes[node3.id] = node3;
  var node4 = Node(id: 4, lon: 4, lat: 4, isAmenity: true, tags: {'amenity':'university'});
  nodes[node4.id] = node4;
  var node5 = Node(id: 5, lon: 5, lat: 5, isAmenity: true, tags: {'railway':'station'});
  nodes[node5.id] = node5;

  repo.amenityNodes = nodes;




  await testLoadJSON();


  testLatLonFromCafe(repo);


  testLatLonFromHigherEducation(repo);


  testTrainStationCoords(repo);
}

Future<void> testLoadJSON() async{
  var repo = jsonRepository();
  var scc = await repo.loadJsonData();
  if(scc == "success"){
    print("load JSON test: Success \n");
    //repo.relations.forEach((rel) { print(rel.name);});
    print("Testing muni coords for Billund Kommune: ");
    var coordList = repo.getMuniBoundary("Billund Kommune");
    print(coordList);
  }else{
    print("load JSON test: Fail \n");
    //print(repo.ways);
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

void testTrainStationCoords(jsonRepository repo){
  var values = repo.getTrainStationCoords();

  if(values.length == 1 && values.contains(Tuple2(5, 5))){
    print("Train Station test: Success \n");
  }else{
    print("Train Station test: Fail \n");
    print(values);
  }
}

