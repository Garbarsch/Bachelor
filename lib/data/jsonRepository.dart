import 'dart:async';
import 'dart:io';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:github_client/data/csvRepository.dart';
import 'package:github_client/data/hilbertCurve.dart';
import 'package:github_client/data/radixSpline.dart';
import 'package:github_client/models/municipality_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:tuple/tuple.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;
import '../models/node.dart';
import '../models/relation.dart';

import 'package:github_client/models/query/query_model.dart';

import '../models/school_model.dart';
import 'hilbert_geohash.dart';
import 'radixSpline_builder.dart' as rsb;

part 'package:github_client/data/queries.dart';

// ignore: camel_case_types
class jsonRepository{

  late List<dynamic> data;
  late List<dynamic> dataInterp;
  late Map<int,Node> amenityNodes;  //Amenity nodes (facilities)

  late List<dynamic> geoData;
  late List<MunicipalityRelation> relations;
  late List<Node> nodesall;
  late List<int> encodedNodes;
  late RadixSpline radixSpline;


  //add some exceptions pls
  Future<String> loadJsonData() async {

    var jsonText = await rootBundle.loadString('assets/rawDenmark.json');
    //var jsonTextInterp = await rootBundle.loadString('assets/interpreter.json');

    data = json.decode(jsonText);
    //dataInterp = json.decode(jsonTextInterp);

    //for all nodes (that contains "tags" - is an amenity node), serialize node object and put in list.

    var nodes = data.where((element) => element["type"] == "node").map((e) => Node.fromJson(e)).toList(); // && element.containsKey("tags")
    //print(nodes.length); //61309 - only amenity
    //print(nodes.length); //406815 - all nodes


    nodesall = data.where((element) => element["type"] == "node").map((e) => Node.fromJson(e)).toList();
    encodedNodes = addToHilbertCurveAndSort(nodesall);
    radixSpline = hilbertToRadixspline(encodedNodes);

    amenityNodes = { for (var n in nodes) n.id : n };

    //amenityNodes = { for (var n in nodes) n.id : n };
    //add orginal nodes last, as to override possible duplicate IDs

  //Original seed
    /*nodes.forEach((node) {
      amenityNodes[node.id] = node;
    });*/

    print(amenityNodes.values.length);


    //serialize each relation to an object containing the list of boundary coordinates
    var gejsonText = await rootBundle.loadString('assets/MuniGeojson.geojson');
    geoData = json.decode(gejsonText);
    relations = geoData.where((element) => element["properties"]["type"] == "boundary").map((e) => MunicipalityRelation.fromJson(e)).toList();
    Node node1 = new Node(id: 3, lon: 12.2, lat: 23.2, isAmenity: true);
    //print(hilbertCurve().encode(node1));
   // var a = hilbertCurve().encode(node1);
   // print(hilbertCurve().decode(32,a.toDouble()).x);
   // print(hilbertCurve().decode(32,a.toDouble()).y);

  // var ab = addToHilbertCurveAndSort(nodes);
//print("finished hilber");
  //  hilbertToRadixspline(ab);

    //addFile("rawDenmarkF256.json", amenityNodes, 255, 0.001);

    if(amenityNodes.isEmpty){
      return "fail";
    }
    return "success";
  }

  //New File of original JSON + seeded nodes
  //offset 0.001 seems to be aight for now, but lets test the range of added features.
  void addFile(String fileName, Map<int,Node> currentNodes, int seedFactor, double coordOffset) async{
    //i dont think we can write to assets in runtime.. in which case we must write to a file somewhere else
    File file = File('${fileName}');
    var random = Random();
    var sourceJSON = await rootBundle.loadString('assets/rawDenmark.json');

    List<dynamic> seededNodes = [];
    var idCount = 0;
    Tuple2<double,double> auxCoord = Tuple2(0.0, 0.0);
    for (int i = 0  ; i<seedFactor ; i++){
      for (var node in currentNodes.values) {
        idCount++;
        auxCoord = getLatLongExtra(node.lat, node.lon, random, coordOffset);
        //We dont want duplicates...
        if(!currentNodes.containsKey(idCount)) {
          seededNodes.add(
              {
                "type": "node",
                "id": idCount,
                "lon": auxCoord.item1,
                "lat": auxCoord.item2,
              }
          );
        }
      }
    };

    //String oldString = json.decode(sourceJSON);
    List<dynamic> source = json.decode(sourceJSON);
    source.addAll(seededNodes);
    print("yoSeeded ${seededNodes.length}");
    print("yoSource ${source.length}");


    //var newJSONString = json.encode(seededNodes);
    //newJSONString.replaceFirst("[", "");

    file.writeAsString(json.encode(source)); //+ newJSONString
    //file.writeAsString(json.encode(seededNodes));

  }

  //Gives seeded nodes new lat/long based on some offset.
  //doing random multiplied by offset gives a "maximum" on new value.
  //https://stackoverflow.com/questions/13318207/how-to-get-a-random-number-from-range-in-dart
  Tuple2<double,double> getLatLongExtra(double lat, double lon, Random random, double offset){
    int quadrant = random.nextInt(4)+1;
    Tuple2<double,double> coord;
    switch (quadrant){
      case 1:
        coord = Tuple2(lat+(-offset * random.nextDouble()), lon+(-offset * random.nextDouble()));
        break;
      case 2:
        coord = Tuple2(lat-(-offset * random.nextDouble()), lon+(-offset * random.nextDouble()));
        break;
      case 3:
        coord = Tuple2(lat-(-offset * random.nextDouble()), lon-(-offset * random.nextDouble()));
        break;
      case 4:
        coord = Tuple2(lat+(-offset * random.nextDouble()), lon-(-offset * random.nextDouble()));
        break;
      default:
        coord = Tuple2(lat+(-offset * random.nextDouble()), lon+(-offset * random.nextDouble()));
        break;
    }
    return coord;
  }


  void printAllNodes(){
    if(amenityNodes.isNotEmpty){
      print(amenityNodes.values);
    }else{
      print("nodes list empty");
    }
  }

  //Remember to call this when if csvRepo has been initialized.
  Future<void> addPopulationToMunicipality(csvRepository csvRepo) async{
    if(relations.isEmpty){
      throw new Exception("JSON file not loaded yet");
    }
    try{
      Map<String,int> muniPops = await csvRepo.getAllMuniPopulations();
      muniPops.forEach((key, value) {
        for(var muni in relations){
          if(muni.name.contains(key)){
            muni.population ??= value;
          }
        }
      });
    }catch(e){
      print(e);
    }

  }

  //fix types in node model!!
  List <LatLng> getCoords(List<String> type){
    List<List<LatLng>> coords = [];
    if (type.contains("Cafe")){
      coords.add(getRestaurantCoords());
    }
    if (type.contains("Restaurants")){
      coords.add(getCafesCoords()); //ret her!!!
    }
    if (type.contains("Bus Stop")){
      coords.add(getBusCoords());
    }
    if (type.contains("Higher Education")){
      coords.add(getHigherEducationCoords());
    }
    if (type.contains("Cinemas")){
      coords.add(getCinemaCoords());
    }
    if (type.contains("Dentists")){
      coords.add(getDentistCoords());
    }
    if (type.contains("Clinics")){
      coords.add(getClinicsCoords());
    }
    if (type.contains("Train Station")){
      coords.add(getTrainStationCoords());
    }
    if (type.contains("Library")){
      coords.add(getLibraryCoords());
    }
    if (type.contains("BarPubNightClub")){
      coords.add(getBarPubNightClubCoords());
    }
    if (type.contains("Training")){
      coords.add(getTrainingCoords());
    }
    if (type.contains("Hospital")){
      coords.add(getHospitalCoords());
    }
    if (type.contains("Arts Centre")){
      coords.add(getArtsCentreCoords());
    }
    if (type.contains("Community Centre")){
      coords.add(getCommunityCentreCoords());
    }
    if (type.contains("Events Venue")){
      coords.add(getEventsVenueCoords());
    }
    if (type.contains("Exhibiton Centre")){
      coords.add(getExhibitionCentreCoords());
    }
    if (type.contains("Conference Centre")){
      coords.add(getConferenceCentreCoords());
    }
    if (type.contains("Music Venue")){
      coords.add(getMusicVenueCoords());
    }
    if (type.contains("Social Centre")){
      coords.add(getSocialCentreCoords());
    }
    if (type.contains("Theatre")){
      coords.add(getTheatreCoords());
    }
    if (type.contains("Fire Station")){
      coords.add(getFireStationCoords());
    }
    if (type.contains("Police")){
      coords.add(getPoliceCoords());
    }

    return coords.expand((e)=>e).toList();

  }

  List<int> addToHilbertCurveAndSort(List<Node> nodes){
    List<int> encoded = [];
    List<Node> test = [];
    test.add(Node(id: 1241412, lon: 1, lat: 1, isAmenity: true));
    test.add(Node(id: 1241412, lon: 1, lat: 2, isAmenity: true));
    test.add(Node(id: 1241412, lon: 7, lat: 2, isAmenity: true));
    test.add(Node(id: 1241412, lon: 2, lat: 5, isAmenity: true));

    test.forEach((element) {
      encoded.add(hilbertCurve().encode(element));
      print(element.lat);
      print(element.lon);
      print(encoded.last);
    });
    print("encoded:"); print(encoded.length);
    encoded.sort();
    print("encoded sorted:"); print(encoded.length);
    return encoded;
  }
  RadixSpline hilbertToRadixspline(List<int> encoded){
    int min = encoded.first;
    int max = encoded.last;
    print("min:" );
    print(min);
    print("max:" );
    print(max);
    var rsBuilder = rsb.Builder(min, max);
    print("builder completed");
    for (var element in encoded) {rsBuilder.AddKey(element);}
    var radixSpline = rsBuilder.finalize();
    var bound = radixSpline.getSearchBound(encoded[encoded.length~/2]-5);
    print(encoded[encoded.length~/2]-5);
    print("in range:"); print(bound.begin); print(bound.end);
    var start = bound.begin;
    var last = bound.end;
    print("the value looked for:"); print(encoded[encoded.length~/2]); print(encoded.length~/2);

    print("position:");
    print(radixSpline.lowerBound2(encoded,start,last,encoded[encoded.length~/2]-5));

    return radixSpline;
  }

  //We could have probably made an ENUM of the amenities available, and just a single getAmenityCoords(Enum...){}

  //get all cafes
  List<LatLng> getCafesCoords(){
    Stopwatch watch = new Stopwatch()..start();
    List<LatLng> tupList = [];
    var count = 0;
    for (var node in amenityNodes.values) {
      count++;
      if(node.isAmenity && node.tags?["amenity"] == "cafe"){
        tupList.add(LatLng(node.lat, node.lon) );
      }
    }
    print("Cafe time: ");
    print("${watch.elapsed.inMilliseconds}");
    print("Count: ${count}\n");
    return tupList;
  }
  static bool rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    final double aY = vertA.latitude;
    final double bY = vertB.latitude;
    final double aX = vertA.longitude;
    final double bX = vertB.longitude;
    final double pY = point.latitude;
    final double pX = point.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      // The case where the ray does not possibly pass through the polygon edge,
      // because both points A and B are above/below the line,
      // or both are to the left/west of the starting point
      // (as the line travels eastward into the polygon).
      // Therefore we should not perform the check and simply return false.
      // If we did not have this check we would get false positives.
      return false;
    }

    // y = mx + b : Standard linear equation
    // (y-b)/m = x : Formula to solve for x

    // M is rise over run -> the slope or angle between vertices A and B.
    double m;
    if(aX-bX == 0){
       m = (aY - bY) / 0.1;
    } else {
       m = (aY - bY) / (aX - bX);
    }
    // B is the Y-intercept of the line between vertices A and B
    final double b = ((aX * -1) * m) + aY;
    // We want to find the X location at which a flat horizontal ray at Y height
    // of pY would intersect with the line between A and B.
    // So we use our rearranged Y = MX+B, but we use pY as our Y value
    final double x = (pY - b) / m;

    // If the value of X
    // (the x point at which the ray intersects the line created by points A and B)
    // is "ahead" of the point's X value, then the ray can be said to intersect with the polygon.
    return x > pX;
  }
  static bool isPointInPolygon(LatLng point, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int i = 0; i < vertices.length; i += 1) {
      final LatLng vertB =
      i == vertices.length - 1 ? vertices[0] : vertices[i + 1];
      if (rayCastIntersect(point, vertices[i], vertB)) {
        intersectCount += 1;
      }
    }
    return (intersectCount % 2) == 1;
  }

  List<Munidata> getCafeForMuni(String muni){

    List<Munidata> data = [];
    int temp = 0;
    List<String> a = [muni];
    var bounds = getMunilist(a);
    List<LatLng> coords = getCafesCoords();
        for (int coord = 0; coord < coords.length; coord++){
          for(int j =0; bounds.length> j; j++) {
            if (isPointInPolygon(coords[coord], bounds[j])){
              temp++;
          }
    } }data.add(Munidata(muni.substring(0, muni.indexOf(' ')), temp));
    return data;
  }
  Munidata getCafeForMunii(String muni){

    List<Munidata> data = [];
    int temp = 0;
    List<String> a = [muni];
    var bounds = getMunilist(a);
    List<LatLng> coords = getCafesCoords();
    for (int coord = 0; coord < coords.length; coord++){
      for(int j =0; bounds.length> j; j++) {
        if (isPointInPolygon(coords[coord], bounds[j])){
          temp++;
        }
      } }
    return (Munidata(muni, temp));
  }

  Munidata getNighlifeForMuni(String muni){

    List<Munidata> data = [];
    int temp = 0;
    List<String> a = [muni];
    var bounds = getMunilist(a);
    List<LatLng> coords = getBarPubNightClubCoords();
    for (int coord = 0; coord < coords.length; coord++){
      for(int j =0; bounds.length> j; j++) {
        if (isPointInPolygon(coords[coord], bounds[j])){
          temp++;
        }
      } }
    return (Munidata(muni, temp));

  }

  Munidata getRestuarantsForMuni(String muni){

    List<Munidata> data = [];
    int temp = 0;
    List<String> a = [muni];
    var bounds = getMunilist(a);
    List<LatLng> coords = getRestaurantCoords();
    for (int coord = 0; coord < coords.length; coord++){
      for(int j =0; bounds.length> j; j++) {
        if (isPointInPolygon(coords[coord], bounds[j])){
          temp++;
        }
      } }
    return (Munidata(muni, temp));

  }
  Munidata getBusStationsForMuni(String muni){

    List<Munidata> data = [];
    int temp = 0;
    List<String> a = [muni];
    var bounds = getMunilist(a);
    List<LatLng> coords = getBusCoords();
    for (int coord = 0; coord < coords.length; coord++){
      for(int j =0; bounds.length> j; j++) {
        if (isPointInPolygon(coords[coord], bounds[j])){
          temp++;
        }
      } }
    return (Munidata(muni, temp));

  }
  Munidata getTrainStationsForMuni(String muni){

    List<Munidata> data = [];
    int temp = 0;
    List<String> a = [muni];
    var bounds = getMunilist(a);
    List<LatLng> coords = getTrainStationCoords();
    for (int coord = 0; coord < coords.length; coord++){
      for(int j =0; bounds.length> j; j++) {
        if (isPointInPolygon(coords[coord], bounds[j])){
          temp++;
        }
      } }
    return (Munidata(muni, temp));

  }
  Munidata getCinemaForMuni(String muni){

    List<Munidata> data = [];
    int temp = 0;
    List<String> a = [muni];
    var bounds = getMunilist(a);
    List<LatLng> coords = getCinemaCoords();
    for (int coord = 0; coord < coords.length; coord++){
      for(int j =0; bounds.length> j; j++) {
        if (isPointInPolygon(coords[coord], bounds[j])){
          temp++;
        }
      } }
    return (Munidata(muni, temp));

  }
  Munidata getArtCentreForMuni(String muni){

    List<Munidata> data = [];
    int temp = 0;
    List<String> a = [muni];
    var bounds = getMunilist(a);
    List<LatLng> coords = getArtsCentreCoords();
    for (int coord = 0; coord < coords.length; coord++){
      for(int j =0; bounds.length> j; j++) {
        if (isPointInPolygon(coords[coord], bounds[j])){
          temp++;
        }
      } }
    return (Munidata(muni, temp));

  }
  Munidata getCommunityCentreForMuni(String muni){

    List<Munidata> data = [];
    int temp = 0;
    List<String> a = [muni];
    var bounds = getMunilist(a);
    List<LatLng> coords = getCommunityCentreCoords();
    for (int coord = 0; coord < coords.length; coord++){
      for(int j =0; bounds.length> j; j++) {
        if (isPointInPolygon(coords[coord], bounds[j])){
          temp++;
        }
      } }
    return (Munidata(muni, temp));

  }
  Munidata getMusicVenueForMuni(String muni){

    List<Munidata> data = [];
    int temp = 0;
    List<String> a = [muni];
    var bounds = getMunilist(a);
    List<LatLng> coords = getMusicVenueCoords();
    for (int coord = 0; coord < coords.length; coord++){
      for(int j =0; bounds.length> j; j++) {
        if (isPointInPolygon(coords[coord], bounds[j])){
          temp++;
        }
      } }
    return (Munidata(muni, temp));

  }



  //get all restaurants
  List<LatLng> getRestaurantCoords(){
    List<LatLng> tupList = [];
      nodesall.forEach((node) {
        tupList.add(LatLng(node.lat, node.lon));
      });
      print(tupList.length);
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

    //return relations.where((element) => element.name == muni).first.boundaryCoords;
  }

  //returns a list of polygons corresponding to the boundaries of the chosen municipalities
  List<Polygon> getMuniPolygons(List<String> municipalities){

    List<Polygon> polyList = [];
    var muni = relations.where((element) => municipalities.contains(element.name));
    for (var boundary in muni) {
      if(boundary.isMulti){

        for (var coordList in boundary.multiBoundaryCoords!) {
          polyList.add(Polygon(points: coordList, color: Colors.blue, isFilled: true));
        }

      }
      else{

        polyList.add(Polygon(points: boundary.boundaryCoords, isFilled: true));

      }
    }

    return polyList;

  }
  List<List<LatLng>> getMunilist(List<String> municipalities){

    List<List<LatLng>> list = [];
    var muni = relations.where((element) => municipalities.contains(element.name));
    for (var boundary in muni) {
      if(boundary.isMulti){

        for (var coordList in boundary.multiBoundaryCoords!) {
          list.add(coordList);
        }

      }
      else{

        list.add(boundary.boundaryCoords);

      }
    }

    return list;

  }

  List<List<LatLng>> getSingleMuniBoundary(String muni){
    var munic = relations.where((element) => element.name == muni).first;
    List<List<LatLng>> list = [];

    if(munic.isMulti){
      for (var coordList in munic.multiBoundaryCoords!) {
        list.add(coordList);
      }
    }
    else{
      list.add(munic.boundaryCoords);
    }


    return list;

  }




}class Munidata{
  Munidata(this.name, this.value);
  final name;
  int value;

}