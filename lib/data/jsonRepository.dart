import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
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

  List <LatLng> getCoords(List<String> type){
    List<List<LatLng>> coords = [];
    if (type.contains("Cafe")){
      coords.add(getRestaurantCoords());
    }
    if (type.contains("Restaurants")){
      coords.add(getRestaurantCoords());
    }
    if (type.contains("Bus Stop")){
      coords.add(getBusCoords());
    }
    if (type == "Higher Education"){
      return getHigherEducationCoords();
    }
    if (type == "Cinemas"){
      return getCinemaCoords();
    }
    if (type == "Dentists"){
      return getDentistCoords();
    }
    if (type == "Clinics"){
      return getClinicsCoords();
    }


    return coords.expand((e)=>e).toList();

  }

  //så kan vi også lave en getCafesByMuni...
  //get all cafes
  List<LatLng> getCafesCoords(){
    List<LatLng> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "cafe"){
        tupList.add(LatLng(node.lat as double, node.lon as double) );
      }
    });
    return tupList;
  }

  //get all restaurants
  List<LatLng> getRestaurantCoords(){
    List<LatLng> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "restaurant"){
        tupList.add(LatLng(node.lat as double, node.lon as double));
      }
    });
    return tupList;
  }

  //get all bus stations
  List<LatLng> getBusCoords(){
    List<LatLng> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "bus_station"){
        tupList.add(LatLng(node.lat as double, node.lon as double));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "college" or "university"
  List<LatLng> getHigherEducationCoords(){
    List<LatLng> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && (node.tags?["amenity"] == "college" || node.tags?["amenity"] == "university")){
        tupList.add(LatLng(node.lat as double , node.lon as double));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<LatLng> getCinemaCoords(){
    List<LatLng> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "cinema"){
        tupList.add(LatLng (node.lat as double, node.lon as double));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<LatLng> getDentistCoords(){
    List<LatLng> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "dentist"){
        tupList.add(LatLng(node.lat as double, node.lon as double));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<LatLng> getClinicsCoords(){
    List<LatLng> tupList = [];
    nodes.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "clinic"){
        tupList.add(LatLng(node.lat as double, node.lon as double ));
      }
    });
    return tupList;
  }


}