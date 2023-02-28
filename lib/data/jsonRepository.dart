import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:github_client/models/relation.dart';
import 'package:tuple/tuple.dart';
import '../models/node.dart';

// ignore: camel_case_types
class jsonRepository{

  late List<dynamic> data;
  late Map<int,Node> amenityNodes;  //Amenity nodes (facilities)

  late List<dynamic> geoData;
  late List<MunicipalityRelation> relations;

  //add some exceptions pls
  Future<String> loadJsonData() async {

    var jsonText = await rootBundle.loadString('assets/rawDenmark.json');
    data = json.decode(jsonText);

    //for all nodes (that contains "tags" - is an amenity node), serialize node object and put in list.
    var nodes = data.where((element) => element["type"] == "node" && element.containsKey("tags")).map((e) => Node.fromJson(e)).toList();

    amenityNodes = { for (var n in nodes) n.id : n };

    //serialize each relation to an object containing the list of boundary coordinates
    var gejsonText = await rootBundle.loadString('assets/MuniGeojson.geojson');
    geoData = json.decode(gejsonText);
    relations = geoData.where((element) => element["properties"]["type"] == "boundary").map((e) => MunicipalityRelation.fromJson(e)).toList();


    if(amenityNodes.isEmpty){
      return "fail";
    }
    return "success";
  }


  void printAllNodes(){
    if(amenityNodes.isNotEmpty){
      print(amenityNodes.values);
    }else{
      print("nodes list empty");
    }
  }

  //get all cafes
  List<Tuple2<num,num>> getCafesCoords(){
    List<Tuple2<num,num>> tupList = [];
    for (var node in amenityNodes.values) {
      if(node.isAmenity && node.tags?["amenity"] == "cafe"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //get all restaurants
  List<Tuple2<num,num>> getRestaurantCoords(){
    List<Tuple2<num,num>> tupList = [];
    for (var node in amenityNodes.values) {
      if(node.isAmenity && node.tags?["amenity"] == "restaurant"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //get all fast food nodes
  List<Tuple2<num,num>> getFastFoodCoords(){
    List<Tuple2<num,num>> tupList = [];
    for (var node in amenityNodes.values) {
      if(node.isAmenity && node.tags?["amenity"] == "fast_food"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //get all bus stations
  List<Tuple2<num,num>> getBusCoords(){
    List<Tuple2<num,num>> tupList = [];
    for (var node in amenityNodes.values) {
      if(node.isAmenity && node.tags?["amenity"] == "bus_station"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //coordinates of nodes tagged "college" or "university"
  List<Tuple2<num,num>> getHigherEducationCoords(){
    List<Tuple2<num,num>> tupList = [];
    for (var node in amenityNodes.values) {
      if(node.isAmenity && (node.tags?["amenity"] == "college" || node.tags?["amenity"] == "university")){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //coordinates of library nodes
  List<Tuple2<num,num>> getLibraryCoords(){
    List<Tuple2<num,num>> tupList = [];
    for (var node in amenityNodes.values) {
      if(node.isAmenity && node.tags?["amenity"] == "library" ){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<Tuple2<num,num>> getCinemaCoords(){
    List<Tuple2<num,num>> tupList = [];
    for (var node in amenityNodes.values) {
      if(node.isAmenity && node.tags?["amenity"] == "cinema"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //coordinates of nodes tagged "dentist"
  List<Tuple2<num,num>> getDentistCoords(){
    List<Tuple2<num,num>> tupList = [];
    for (var node in amenityNodes.values) {
      if(node.isAmenity && node.tags?["amenity"] == "dentist"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //coordinates of nodes tagged "clinics"
  List<Tuple2<num,num>> getClinicsCoords(){
    List<Tuple2<num,num>> tupList = [];
    for (var node in amenityNodes.values) {
      if(node.isAmenity && node.tags?["amenity"] == "clinic"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //coordinates train stations
  List<Tuple2<num,num>> getTrainStationCoords(){
    List<Tuple2<num,num>> tupList = [];
    for (var node in amenityNodes.values) {
      if(node.isAmenity && node.tags?["railway"] == "station"){
        tupList.add(Tuple2(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //getMunicipalityBoundaries


}