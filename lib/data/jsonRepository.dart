import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
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
    if (type == "Library"){
      return getLibraryCoords();
    }

    return coords.expand((e)=>e).toList();

  }

  //We could have probably made an ENUM of the amenities available, and just a single getAmenityCoords(Enum...){}

  //så kan vi også lave en getCafesByMuni...
  //get all cafes
  List<LatLng> getCafesCoords(){
    List<LatLng> tupList = [];
    for (var node in amenityNodes.values) {
      if(node.isAmenity && node.tags?["amenity"] == "cafe"){
        tupList.add(LatLng(node.lat, node.lon) );
      }
    }
    return tupList;
  }

  //get all restaurants
  List<LatLng> getRestaurantCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "restaurant"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }

  //get all bus stations
  List<LatLng> getBusCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity){
        if((node.tags!["amenity"] == "bus_station")){
          tupList.add(LatLng(node.lat, node.lon));
        }else if(node.tags!.containsKey("public_transport") && node.tags!["public_transport"] == "station"){
          tupList.add(LatLng(node.lat, node.lon));
        }
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "college" or "university"
  List<LatLng> getHigherEducationCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && (node.tags?["amenity"] == "college" || node.tags?["amenity"] == "university")){
        tupList.add(LatLng(node.lat , node.lon));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<LatLng> getCinemaCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "cinema"){
        tupList.add(LatLng (node.lat, node.lon));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "dentist"
  List<LatLng> getDentistCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "dentist"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<LatLng> getClinicsCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "clinic"){
        tupList.add(LatLng(node.lat, node.lon ));
      }
    });
    return tupList;
  }

  //coordinates train stations
  List<LatLng> getTrainStationCoords(){
    List<LatLng> tupList = [];
    for (var node in amenityNodes.values) {
      if(node.isAmenity && node.tags?["railway"] == "station"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //coordinates of nodes tagged "library"
  List<LatLng> getLibraryCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "library"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }
  List<LatLng> getBarPubNightClubCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && (node.tags?["amenity"] == "bar" ||node.tags?["amenity"] == "pub" || node.tags?["amenity"] == "nightclub")){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }
  List<LatLng> getTrainingCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "training"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }
  List<LatLng> getHospitalCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "hospital"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }
  List<LatLng> getArtsCentreCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "arts_centre"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }
  List<LatLng> getCommunityCentreCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "community_centre"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }
  List<LatLng> getEventsVenueCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "events_venue"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }
  List<LatLng> getExhibitionCentreCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "exhibition_centre"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }
  List<LatLng> getConferenceCentreCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "conference_centre"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }
  List<LatLng> getMusicVenueCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "music_venue"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }
  List<LatLng> getSocialCentreCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "social_centre"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }
  List<LatLng> getTheatreCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "theatre"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }
  List<LatLng> getFireStationCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "fire_station"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }
  List<LatLng> getPoliceCoords(){
    List<LatLng> tupList = [];
    amenityNodes.values.forEach((node) {
      if(node.isAmenity && node.tags?["amenity"] == "police"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    });
    return tupList;
  }


  //collects the municipality boundary of a single given municipality
  List<LatLng> getMuniBoundary(String muni){
    return relations.where((element) => element.name == muni).first.boundaryCoords;
  }

  //returns a list of polygons corresponding to the boundaries of the chosen municipalities
  List<Polygon> getMuniPolygons(List<String> municipalities){

    List<Polygon> polyList = [];
    var muni = relations.where((element) => municipalities.contains(element.name));
    for (var boundary in muni) {
      if(boundary.isMulti){

        for (var coordList in boundary.multiBoundaryCoords!) {
          polyList.add(Polygon(points: coordList));
        }

      }
      else{

        polyList.add(Polygon(points: boundary.boundaryCoords));

      }
    }

    return polyList;

  }


}