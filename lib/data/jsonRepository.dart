import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:tuple/tuple.dart';

import '../models/node.dart';
import '../models/relation.dart';

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

  //fix types in node model!!
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
    if (type == "Train Station"){
      return getTrainStationCoords();
    }


    return coords.expand((e)=>e).toList();

  }

  //så kan vi også lave en getCafesByMuni...
  //get all cafes
  List<LatLng> getCafesCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "cafe"){
        tupList.add(LatLng(node.lat as double, node.lon as double) );
      }
    });
    return tupList;
  }

  //get all restaurants
  List<LatLng> getRestaurantCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "restaurant"){
        tupList.add(LatLng(node.lat as double, node.lon as double));
      }
    });
    return tupList;
  }

  //get all bus stations
  List<LatLng> getBusCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "bus_station"){
        tupList.add(LatLng(node.lat as double, node.lon as double));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "college" or "university"
  List<LatLng> getHigherEducationCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && (node.tags?["amenity"] == "college" || node.tags?["amenity"] == "university")){
        tupList.add(LatLng(node.lat as double , node.lon as double));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<LatLng> getCinemaCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "cinema"){
        tupList.add(LatLng (node.lat as double, node.lon as double));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<LatLng> getDentistCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "dentist"){
        tupList.add(LatLng(node.lat as double, node.lon as double));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<LatLng> getClinicsCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "clinic"){
        tupList.add(LatLng(node.lat as double, node.lon as double ));
      }
    });
    return tupList;
  }

  //coordinates train stations
  List<LatLng> getTrainStationCoords(){
    List<LatLng> tupList = [];
    for (var node in amenityNodes.values) {
      if(node.isAmenity && node.tags?["railway"] == "station"){
        tupList.add(LatLng(node.lat as double, node.lon as double));
      }
    }
    return tupList;
  }

  //getMunicipalityBoundaries


}