import 'dart:async';
import 'dart:io';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:github_client/data/GridFileFlex.dart';
import 'package:github_client/data/csvRepository.dart';
import 'package:latlong2/latlong.dart';
import 'package:tuple/tuple.dart';
import '../models/node.dart';
import '../models/relation.dart';
import 'package:github_client/models/query/query_model.dart';
import '../models/school_model.dart';
import 'GridFile.dart';
import 'PGridFile.dart';
part 'package:github_client/data/queriesGrid.dart';
part 'package:github_client/data/queries.dart';


// ignore: camel_case_types
class jsonRepository{
  //late Map<int,Node> amenityNodes;  //all nodes now
  late List<Node> nodes;
  late List<MunicipalityRelation> relations;
  late final  grid;
  late List<List<Rectangle<num>>> gridRects;
  //add some exceptions pls
  Future<String> loadJsonData() async {

    var jsonText = await rootBundle.loadString('assets/rawDenmark.json');

    List<dynamic> data = json.decode(jsonText);

    //for all nodes (that contains "tags" - is an amenity node), serialize node object and put in list.

    nodes = data.where((element) => element["type"] == "node").map((e) => Node.fromJson(e)).toList(); // && element.containsKey("tags")
   // amenityNodes = { for (var n in nodes) n.id : n };


    //serialize each relation to an object containing the list of boundary coordinates
    var gejsonText = await rootBundle.loadString('assets/MuniGeojson.geojson');
    List<dynamic> geoData = json.decode(gejsonText);
    relations = geoData.where((element) => element["properties"]["type"] == "boundary").map((e) => MunicipalityRelation.fromJson(e)).toList();
    //add rectangles around municipalities


    addBoundingBoxToMunicipality();

    IniGrid();

    if(nodes.isEmpty){
      return "fail";
    }
    return "success";
  }

   void IniGrid(){
    grid = PGridFile(addBoundingBoxToDenmark(), relations,nodes); //1000
    grid.initializeGrid();
    gridRects = grid.linearScalesRectangles;
  }

  //New File of original JSON + seeded nodes
  //offset 0.001 seems to be aight for now, but lets test the range of added features.
  void addFile(String fileName, Map<int,Node> currentNodes, int seedFactor, double coordOffset) async{
    //i dont think we can write to assets in runtime.. in which case we must write to a file somewhere else
    File file = File(fileName);
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
    }
    List<dynamic> source = json.decode(sourceJSON);
    source.addAll(seededNodes);

    file.writeAsString(json.encode(source)); //+ newJSONString
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
    if(nodes.isNotEmpty){
      print(nodes);
    }else{
      print("nodes list empty");
    }
  }

  //Remember to call this when if csvRepo has been initialized.
  Future<void> addPopulationToMunicipality(csvRepository csvRepo) async{

    if(relations.isEmpty){
      throw Exception("JSON file not loaded yet");
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
    //this.queryModel = queriesGrid(this, csvRepo);
  }

  void addBoundingBoxToMunicipality(){
    for (var element in relations) {
      var minLat = double.infinity;
      var maxLat = double.negativeInfinity;
      var minLong = double.infinity;
      var maxLong = double.negativeInfinity;
      if(!element.isMulti){
        for (var latlong in element.boundaryCoords) {
          //min y
          minLat = latlong.latitude < minLat ? latlong.latitude : minLat;
          //max y
          maxLat = latlong.latitude > maxLat ? latlong.latitude : maxLat;
          //min x
          minLong = latlong.longitude < minLong ? latlong.longitude : minLong;
          //max x
          maxLong = latlong.longitude > maxLong ? latlong.longitude : maxLong;
        }

      }else{
        element.multiBoundaryCoords?.forEach((boundary) {
          for (var latlong in boundary) {
            //min y
            minLat = latlong.latitude < minLat ? latlong.latitude : minLat;
            //max y
            maxLat = latlong.latitude > maxLat ? latlong.latitude : maxLat;
            //min x
            minLong = latlong.longitude < minLong ? latlong.longitude : minLong;
            //max x
            maxLong = latlong.longitude > maxLong ? latlong.longitude : maxLong;
          }

        });

      }
      element.boundingBox = Rectangle(minLong, minLat, maxLong-minLong, maxLat-minLat);
    }
  }
  //TODO:test
  //Adds a rectangle around all of Denmark to be used for grid partitioning.
  Rectangle<num> addBoundingBoxToDenmark(){
    var minLat = double.infinity;
    var maxLat = double.negativeInfinity;
    var minLong = double.infinity;
    var maxLong = double.negativeInfinity;
    for (var element in relations) {
      if(!element.isMulti){
        for (var latlong in element.boundaryCoords) {
          //min y
          minLat = latlong.latitude < minLat ? latlong.latitude : minLat;
          //max y
          maxLat = latlong.latitude > maxLat ? latlong.latitude : maxLat;
          //min x
          minLong = latlong.longitude < minLong ? latlong.longitude : minLong;
          //max x
          maxLong = latlong.longitude > maxLong ? latlong.longitude : maxLong;
        }

      }else{
        element.multiBoundaryCoords?.forEach((boundary) {
          for (var latlong in boundary) {
            //min y
            minLat = latlong.latitude < minLat ? latlong.latitude : minLat;
            //max y
            maxLat = latlong.latitude > maxLat ? latlong.latitude : maxLat;
            //min x
            minLong = latlong.longitude < minLong ? latlong.longitude : minLong;
            //max x
            maxLong = latlong.longitude > maxLong ? latlong.longitude : maxLong;
          }

        });

      }
    }
    return Rectangle(minLong, minLat, maxLong-minLong, maxLat-minLat);
  }



  List <LatLng> getCoords(List<String> type){
    List<List<LatLng>> coords = [];
    if (type.contains("Cafe")){
      coords.add(getCafesCoords());
    }
    if (type.contains("Restaurants")){
      coords.add(getRestaurantCoords()); //ret her!!!
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

  //get all cafes
  List<LatLng> getCafesCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "cafe"){
        tupList.add(LatLng(node.lat, node.lon) );
      }
    }
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
      final LatLng vertB = i == vertices.length - 1 ? vertices[0] : vertices[i + 1];
      if (rayCastIntersect(point, vertices[i], vertB)) {
        intersectCount += 1;
      }
    }
    return (intersectCount % 2) == 1;
  }

  //checks whether point is between sides of the bounding rectangle
  static bool isPointInMuniBoundingBox(LatLng point, String muni, List<MunicipalityRelation> relations) {
    Rectangle<num>? rect = relations.where((element) => element.name == muni).first.boundingBox;
    if(rect != null){
        return point.longitude >= rect.left &&
               point.longitude <= rect.left + rect.width &&
               point.latitude >= rect.top &&
               point.latitude <= rect.top + rect.height;
    }
    return false;
  }

  List<Node> getNodesInRectangle(List<Node> nodes, Rectangle rect) {
    List<Node> returnNodes = [];
    if(rect != null){
      nodes.forEach((node) {
        if(node.lon >= rect.left &&
            node.lon <= rect.left + rect.width &&
            node.lat >= rect.top &&
            node.lat <= rect.top + rect.height){
          returnNodes.add(node);
        }

      });

    }
    return returnNodes;
  }

  //TODO: give better name plox
  Munidata getBoxCoordsForMuni(String muni, List<String> amenity){
    List<LatLng> coords = getCoords(amenity);
    List<LatLng> boxCoords = [];
    //Get the data points within the boundingbox (rectangle) of the muni
    for (int coordCount = 0; coordCount < coords.length; coordCount++){
      if(isPointInMuniBoundingBox(coords[coordCount], muni, relations)){
        boxCoords.add(coords[coordCount]);
      }
    }

    //Now search the points as not to count false positives.
    int temp = 0;
    if(boxCoords.isNotEmpty){
      var bounds = getMunilist([muni]);
      for (int coord = 0; coord < boxCoords.length; coord++){
        for(int j =0; bounds.length> j; j++) {
          if (isPointInPolygon(boxCoords[coord], bounds[j])){
            temp++;
          }
        } }

    }
    return Munidata(muni.substring(0, muni.indexOf(' ')), temp);
  }

  //For testing - THIS IS ONLY APPROX, WILL FIND FALSE POSITIVES.
  Munidata  getCafeForMuniRect(String muni){
    List<LatLng> coords = getCafesCoords();
    int temp = 0;
    for (int coordCount = 0; coordCount < coords.length; coordCount++){
        if(jsonRepository.isPointInMuniBoundingBox(coords[coordCount], muni, relations)){
          temp++;
        }
      }
    return Munidata(muni.substring(0, muni.indexOf(' ')), temp);
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

  //TODO: test
  Munidata getAmenityNodesInMuni (List<Node> nodes, String muni, String amenity){
    int count = 0;
    var bounds = getMunilist([muni]);
    nodes.forEach((node) {
        if(node.isAmenity){
           if(node.tags?["amenity"] == amenity){
             for(int j =0; bounds.length> j; j++) {
               if (isPointInPolygon(LatLng(node.lat, node.lon), bounds[j])){
                 count++;
               }
             }
           }else if(amenity == "station"){
             if(node.tags?["railway"] == "station"){
               for(int j =0; bounds.length> j; j++) {
                 if (isPointInPolygon(LatLng(node.lat, node.lon), bounds[j])){
                   count++;
                 }
               }
             }
           }else if(amenity == "nightlife"){
             if(node.tags?["amenity"] == "bar" ||node.tags?["amenity"] == "pub" || node.tags?["amenity"] == "nightclub"){
               for(int j =0; bounds.length> j; j++) {
                 if (isPointInPolygon(LatLng(node.lat, node.lon), bounds[j])){
                   count++;
                 }
               }
             }
           }else if(amenity == "bus"){
             if((node.tags!["amenity"] == "bus_station")){
               for(int j =0; bounds.length> j; j++) {
                 if (isPointInPolygon(LatLng(node.lat, node.lon), bounds[j])){
                   count++;
                 }
               }
             }else if(node.tags!.containsKey("public_transport") && node.tags!["public_transport"] == "station"){
               for(int j =0; bounds.length> j; j++) {
                 if (isPointInPolygon(LatLng(node.lat, node.lon), bounds[j])){
                   count++;
                 }
               }
             }
           }
        }
      });

    return Munidata(muni, count);
  }
  //TODO: test
  Munidata getAmenityNodesFromNodes (List<Node> nodes,String muni, String amenity){
    int count = 0;
    nodes.forEach((node) {
      if(node.isAmenity){
        if(node.tags?["amenity"] == amenity){
              count++;
        }else if(amenity == "station"){
          if(node.tags?["railway"] == "station"){
                count++;
          }
        }else if(amenity == "nightlife"){
          if(node.tags?["amenity"] == "bar" ||node.tags?["amenity"] == "pub" || node.tags?["amenity"] == "nightclub"){
                count++;
          }
        }else if(amenity == "bus"){
          if((node.tags!["amenity"] == "bus_station")){
                count++;
          }else if(node.tags!.containsKey("public_transport") && node.tags!["public_transport"] == "station"){
                count++;
          }
        }
      }
    });

    return Munidata(muni, count);
  }



  //get all restaurants
  List<LatLng> getRestaurantCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "restaurant"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //get all bus stations
  List<LatLng> getBusCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity){
        if((node.tags!["amenity"] == "bus_station")){
          tupList.add(LatLng(node.lat, node.lon));
        }else if(node.tags!.containsKey("public_transport") && node.tags!["public_transport"] == "station"){
          tupList.add(LatLng(node.lat, node.lon));
        }
      }
    }
    return tupList;
  }

  //coordinates of nodes tagged "college" or "university"
  List<LatLng> getHigherEducationCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && (node.tags?["amenity"] == "college" || node.tags?["amenity"] == "university")){
        tupList.add(LatLng(node.lat , node.lon));
      }
    }
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<LatLng> getCinemaCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "cinema"){
        tupList.add(LatLng (node.lat, node.lon));
      }
    }
    return tupList;
  }

  //coordinates of nodes tagged "dentist"
  List<LatLng> getDentistCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "dentist"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //coordinates of nodes tagged "cinema"
  List<LatLng> getClinicsCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "clinic"){
        tupList.add(LatLng(node.lat, node.lon ));
      }
    }
    return tupList;
  }

  //coordinates train stations
  List<LatLng> getTrainStationCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["railway"] == "station"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }

  //coordinates of nodes tagged "library"
  List<LatLng> getLibraryCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "library"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }
  List<LatLng> getBarPubNightClubCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && (node.tags?["amenity"] == "bar" ||node.tags?["amenity"] == "pub" || node.tags?["amenity"] == "nightclub")){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }
  List<LatLng> getTrainingCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "training"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }
  List<LatLng> getHospitalCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "hospital"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }
  List<LatLng> getArtsCentreCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "arts_centre"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }
  List<LatLng> getCommunityCentreCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "community_centre"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }
  List<LatLng> getEventsVenueCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "events_venue"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }
  List<LatLng> getExhibitionCentreCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "exhibition_centre"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }
  List<LatLng> getConferenceCentreCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "conference_centre"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }
  List<LatLng> getMusicVenueCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "music_venue"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }
  List<LatLng> getSocialCentreCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "social_centre"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }
  List<LatLng> getTheatreCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "theatre"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }
  List<LatLng> getFireStationCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "fire_station"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
    return tupList;
  }
  List<LatLng> getPoliceCoords(){
    List<LatLng> tupList = [];
    for (var node in nodes) {
      if(node.isAmenity && node.tags?["amenity"] == "police"){
        tupList.add(LatLng(node.lat, node.lon));
      }
    }
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


  List<Polygon> getLargestMuniPolygon(List<String> municipalities){

    List<Polygon> polyList = [];
    List<LatLng> temp = [] ;
    var muni = relations.where((element) => municipalities.contains(element.name));
    for (var boundary in muni) {
      for (var coordList in boundary.multiBoundaryCoords!){
        if(coordList.length>temp.length){
          temp = coordList;
        }
      }
        polyList.add(Polygon(points: temp, isFilled: true));

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
  final String name;
  int value;

}