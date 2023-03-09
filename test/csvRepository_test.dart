import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/data/csvRepository.dart';
import 'package:github_client/models/school_model.dart';

void main() async{
  TestWidgetsFlutterBinding.ensureInitialized();

  group("load files test", () {
    var repo = csvRepository();
    test("load both CSV files", () async {
      await repo.loadCSVFiles("assets/hovedtal-2022uddCSV.csv", "assets/SchoolAddresses.csv");
      expect(repo.schoolInfoMap, isNotNull);
      expect(repo.totalAcceptedAppliers.runtimeType, isNotNull);
      expect(repo.totalAppliers.runtimeType, isNotNull);
    });
    test("Test: get municipality populations", () async {
      var map = await repo.getAllMuniPopulations();
      expect(map.keys.length, 98);
      expect(map["København"], 653664);

    });
  });
  group("Access Methods", () {
    
    final repo = csvRepository();
    Map<String,List<School>> schoolMap = {};
    
    //seed data
    School schoolTop1 = School(name: "Københavns Universitet", acceptedAppliers: 6, appliers: 6);
    School school1 = School(name: "1", acceptedAppliers: 1, appliers: 1, campusName: "1", campusLat: 1, campusLon: 1);
    School school2 = School(name: "2", acceptedAppliers: 2, appliers: 2, campusName: "2", campusLat: 2, campusLon: 2);
    School school3 = School(name: "3", acceptedAppliers: 3, appliers: 3, campusName: "3", campusLat: 3, campusLon: 3);

    School schoolTop2 = School(name: "SDU", acceptedAppliers: 15, appliers: 15);
    School school4 = School(name: "4", acceptedAppliers: 4, appliers: 4, campusName: "4", campusLat: 4, campusLon: 4);
    School school5 = School(name: "5", acceptedAppliers: 5, appliers: 5, campusName: "5", campusLat: 5, campusLon: 5);
    School school6 = School(name: "6", acceptedAppliers: 6, appliers: 6, campusName: "6", campusLat: 6, campusLon: 6);

    School schoolTop3 = School(name: "ITU", acceptedAppliers: 7, appliers: 7);
    School school7 = School(name: "7", acceptedAppliers: 7, appliers: 7, campusName: "7", campusLat: 7, campusLon: 7);
    
    schoolMap["Københavns Universitet"] = [schoolTop1, school1, school2, school3];
    schoolMap["SDU"] = [schoolTop2, school4,school5,school6];
    schoolMap["ITU"] = [schoolTop3, school7];

    repo.schoolInfoMap = schoolMap;
    repo.totalAcceptedAppliers = 28;
    repo.totalAppliers = 28;


    test("Test: Get list of schools/educations from one top-layer school", () {
      var schoolList = repo.getAllEducationsFromSchool("Københavns Universitet");
      var expectedLength = (repo.schoolInfoMap["Københavns Universitet"]?.length)! -1; //we dont want to return the top-layer entry of the list
      var actualLength = schoolList.length;

      expect(expectedLength, actualLength);
      expect(schoolList.contains(schoolTop1), false);
      expect(schoolList.contains(school1), true);
      expect(schoolList.contains(school2), true);
      expect(schoolList.contains(school3), true);


      //check we don't ruin the original data structure of the repo.
      var counter=0;
      repo.schoolInfoMap.values.forEach((element) {
        element.forEach((element) {
          counter++;
        });
      });

      expect(counter, 10);


    });
    test("Test: get total appliers and total accepted appliers", (){

      expect(repo.getTotalAppliers(), 28);
      expect(repo.getTotalAcceptedAppliers(), 28);

    });
    test("Test: get top-layer school", (){
      var school = repo.getTopLayerSchool("ITU");

      expect(school, isNotNull);
      expect(school?.name, "ITU");
      expect(school?.acceptedAppliers, 7);
      expect(school?.appliers, 7);

    });
    test("Test: Get all educations beneath each top-layer school", () {

      List<School> schoolList = repo.getAllEducations();

      var counter=0;
      repo.schoolInfoMap.values.forEach((element) {
        element.forEach((element) {
          counter++;
        });
      });


      expect(schoolList.length, 7);
      expect(counter, 10); //check we don't ruin the original data structure of the repo.
      expect(schoolList.contains(school1), true);
      expect(schoolList.contains(school2), true);
      expect(schoolList.contains(school3), true);
      expect(schoolList.contains(school4), true);
      expect(schoolList.contains(school5), true);
      expect(schoolList.contains(school6), true);
      expect(schoolList.contains(school7), true);
    });
    test("Test: get all top-layer schools", () {
      var topLayerList = repo.getAllTopLayerSchools();

      expect(topLayerList.length, 3);
      expect(topLayerList.contains(schoolTop1), true);
      expect(topLayerList.contains(schoolTop2), true);
      expect(topLayerList.contains(schoolTop3), true);
    });
    
  });




}