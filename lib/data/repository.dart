import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:github_client/models/school_model.dart';
import 'package:intl/intl.dart';
import 'dart:async';


class Repository {


  late final Map<String, List<School>> schoolInfoMap;
  late final double totalAcceptedAppliers;
  late final double totalAppliers;


  Future<void> loadCSVFiles(String csvPathMap, String csvPathLocation) async {
    //load the csv of schools and information on appliers into a map.
    var schoolMap = await parseSchoolMap(csvPathMap);

    if(schoolMap != null){
      schoolInfoMap = schoolMap;

      //load the csv of schools and their latitude and longitude values into a map.
      await parseSchoolLocations(csvPathLocation, schoolMap);
    }else{
      print("Something went wrong: try picking a different file");
    }

  }

  /*
  We have to make sure that the csv files:
  - Align in format
  - Use the same delimiters
  - Has the correct attributes (optional)
  - Contains no redundant entities
  - No whitespace (to ease querying data)
  - No null values

  Code is inspired by Abhay Rastogi's article on csv files in Flutter:
  https://codesearchonline.com/read-and-write-csv-file-in-flutter-web-mobile/
   */
  Future<Map<String, List<School>>?> parseSchoolMap(String csvPath) async {
    //TODO: create one repository class, and then have two parse classes; one parse json and one parse csv files.
    try {
      //create string from csv file
      String csvAsString = await rootBundle.loadString(csvPath);

      //remove whitespace (" København K" -> "København K")
      String trimmed = csvAsString.replaceAll("; ", ";");
      trimmed = trimmed.replaceAll(" ;", ";");

      //replace delimiter
      trimmed.replaceAll(',', ';');

      //Create 2D List of csv
      var listData = CsvToListConverter(fieldDelimiter: ';').convert(trimmed);

      //check list is not empty
      if (listData.isEmpty) {
        throw Exception("empty csv");
      }

      //remove duplicate rows
      listData.toSet().toList();

      //remove the last entry in the csv: the line of total appliers and accepted appliers.

      totalAcceptedAppliers = listData.last[3];
      totalAppliers = listData.last[5];
      listData.removeLast();




      //clone list of all data
      List<dynamic> schools = List.from(listData);

      //remove top-layer schools from original list
      listData.removeWhere((element) => element[2].contains("i alt"));

      //get top-layer school information (name, accepted appliers, appliers total)
      //NOTE: we have to call this here, as the list is not properly cloned? - its just still the same objects
      //OKAY: i see why it works now - so we might have the same objects, but the objects we are removing above, are not removed in the "schools" list.
      schools = getSchoolList(schools);

      //create map to be returned
      Map<String, List<School>> schoolMap = {};

      //for each top layer school, add the school as a key entrant in the map
      for (var element in schools) {
        schoolMap[element[0].toString()] = [];
      }

      //Create a map of all educations (sub-departments) from each school as well as information on them.
      String schoolName = "";
      //For each of the remaining csv data, if one education name contains a top-layer school name
      //We then know are at a new sequence of sub-departments(educations) from that school in the csv.
      for (var element in listData) {

        if (schoolMap.keys.contains(element[2])) {
          schoolName = element[2];

          var topLevelSchool = schools.where((topLevelSchool) => topLevelSchool[0] == schoolName).first;

          //add the topLevel school as the first entrant of the list the corresponding school fits in.
          School newSchool = School(name: element[2], acceptedAppliers: topLevelSchool[1], appliers: topLevelSchool[2]);
          schoolMap[schoolName]?.add(newSchool);

          //print("\n");
          //print("New school: ${schoolName}");
          //print("Values: ${schools.where((element) => element[0] == schoolName).first}");

          //add the sub-department of the school as a new school model
          //TODO: rename to education perhaps? or something better than school at least
        } else if (!element[2].contains("i alt")) {
          //print("Education: ${element[2]}\n Accepted appliers: ${element[3]}\n Appliers: ${element[5]}\n");

          School newSchool = School(name: element[2].toString(), acceptedAppliers: element[3], appliers: element[5], postDistrict: getPostDistrict(element[2]));
          schoolMap[schoolName]?.add(newSchool);
        }
      }

      return schoolMap;

    } on Exception catch (e) {
      print(e.toString());
      return null;
    }
  }

  String getPostDistrict(String schoolModelName){
    String subDistrictString = schoolModelName.substring(0,schoolModelName.lastIndexOf(","));//String without "studiestart"
    String subSubDistrictString = subDistrictString.substring(subDistrictString.lastIndexOf(",")+2);

    //print(subSubDistrictString);
    return subSubDistrictString;
  }

  //helper method to remove all data but the target top-layer schools and their information
  List<dynamic> getSchoolList(List<dynamic> dynamicData) {
    //remove unused entries
    dynamicData.removeWhere((element) => !element[2].contains("i alt"));

    for (var element in dynamicData) {
      element.removeRange(0, 2);
      element.removeAt(2);
      element.removeRange(3, 6);
      element[0] = element[0].replaceAll(" i alt", "");
    }

    return dynamicData;
  }

  Future<void> parseSchoolLocations(String csvPath, Map<String, List<School>> schoolInfoMap) async {
    //TODO: vi mangler nogle skoler som Arkitekt skolen, Det kongelige akademi mm. (kan hentes indefra linke hvor vi fik datasættet)

    //parse csv
    String csvAsString = await rootBundle.loadString(csvPath);
    var listData = CsvToListConverter(fieldDelimiter: ',').convert(csvAsString);
    listData.removeAt(0);

    //parse each school with lat lon based on postdistricts
    for (var element in listData) {
      var campusName= element[2];
      var postDistrict = element[6];
      late double lat,lon;

      if(element[26] != "" && element[27] != ""){

        lat = double.parse(element[27].replaceAll(',','.'));
        lon = double.parse(element[26].replaceAll(',','.'));

      }else{
        lat = 0.0;
        lon = 0.0;
      }

      //for each top-layer school
      for (var uni in schoolInfoMap.keys) {
        //if the campus from above is a department of either of the top-layer schools
        if(campusName.contains(uni)){
          //then find the schools that match the post-district and add the coordinates
          for (var school in schoolInfoMap[uni]!) {
            if(school.postDistrict == postDistrict){
              school.campusName = campusName;
              school.campusLat = lat;
              school.campusLon = lon;
            }
          }
      }
      }

    }
  }

  void printAllSchoolInfo(){

    schoolInfoMap.keys.forEach((element) {
      print("Top-layer school: ${element}\n");
      schoolInfoMap[element]!.forEach((school) {
        print("School name: ${school.name}\n");
        print("School accepted appliers: ${school.acceptedAppliers}\n");
        print("School total appliers: ${school.appliers}\n");
        if(school.campusName == null){
          print("no campus!!!!!!!!\n");
          print("\n");
          //Det Kongelige Akademi
          //Arkitektskolen Aarhus
          //Designskolen Kolding
          //Copenhagen Business Academy
          //Københavns Erhvervsakademi (KEA)
          //Zealand Sjællands Erhvervsakademi
          //IBA Erhvervsakademi Kolding
          //Erhvervsakademi SydVest
          //Erhvervsakademi MidtVest
          //Erhvervsakademi Aarhus
          //Erhvervsakademi Dania
          //
        }else{
          //print("Campus: ${school.campusName}\n");
          //print("Campus lat: ${school.campusLat}\n");
          //print("Campus lon: ${school.campusLon}\n");
          //print("\n");
        }
      });

    });

  }

}