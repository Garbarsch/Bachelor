import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

import '../models/node.dart';



class jsonRepository{


  late List<dynamic> data;
  late List<Node> nodes;

  //ku godt lave noget exception på success eller fail
  Future<String> loadJsonData() async {
    var jsonText = await rootBundle.loadString('assets/rawDenmark.json');
    data = json.decode(jsonText);

    //for all nodes, serialize node object and put in list.
    nodes = data.where((element) => element["type"] == "node").map((e) => Node.fromJson(e)).toList();

    if(nodes.isEmpty){
      return "fail";
    }
    return "success";
  }


  void printAllNodes(){
    if(!nodes.isEmpty){
      print(nodes);
    }else{
      print("nodes list empty");
    }
  }

  //så kan vi også lave en getCafesByMuni...
  //get all cafes
  List<Tuple2<num,num>> getCafesCoords(){
    List<Tuple2<num,num>> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "cafe"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    });
    return tupList;
  }

  //get all restaurants
  List<Tuple2<num,num>> getRestaurantCoords(){
    List<Tuple2<num,num>> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "restaurant"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    });
    return tupList;
  }

  //get all bus stations
  List<Tuple2<num,num>> getBusCoords(){
    List<Tuple2<num,num>> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "bus_station"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "college" or "university"
  List<Tuple2<num,num>> getHigherEducationCoords(){
    List<Tuple2<num,num>> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && (node.tags?["amenity"] == "college" || node.tags?["amenity"] == "university")){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<Tuple2<num,num>> getCinemaCoords(){
    List<Tuple2<num,num>> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "cinema"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<Tuple2<num,num>> getDentistCoords(){
    List<Tuple2<num,num>> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "dentist"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<Tuple2<num,num>> getClinicsCoords(){
    List<Tuple2<num,num>> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "clinic"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    });
    return tupList;
  }


}