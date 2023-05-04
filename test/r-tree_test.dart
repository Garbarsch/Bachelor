import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/data/csvRepository.dart';
import 'package:github_client/data/jsonRepository.dart';
import 'package:github_client/models/node.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("Test cell cap size", ()  {
    csvRepository csvRepo = csvRepository();
    jsonRepository repo = jsonRepository();


    test("s", () async {
      await csvRepo.loadCSVFiles("assets/hovedtal-2022uddCSV.csv", "assets/SchoolAddresses.csv");
      await repo.loadJsonData();
      repo.addPopulationToMunicipality(csvRepo);


      //var gridFile = PGridFile1(denmarkBounds, repo.relations,repo.nodes);
      //gridFile.initializeGrid();
      queriesRtree queries = queriesRtree(repo: repo, csvRepo: csvRepo);
      Stopwatch stopwatch;
      Stopwatch stopwatch2;
      Stopwatch stopwatch3;

      int countMili1 = 0;
      int countMili2 = 0;
      int countMili3 = 0;
    /*    for(int x = 0 ; x<5 ; x++) {
      for(int i = 0 ; i<repo.relations.length-1 ; i+=2) {

        stopwatch = new Stopwatch()..start();
        queries.entertainmentQueryRect(repo.relations[i].name, repo.relations[i+1].name);
        countMili1 += stopwatch.elapsed.inMilliseconds;

      }}*/

      for(int i = 0 ; i<5 ; i++){
        stopwatch = new Stopwatch()..start();
        queries.entertainmentQueryRect("Københavns Kommune", "Aarhus Kommune");
        countMili1 += stopwatch.elapsed.inMilliseconds;


        stopwatch2 = new Stopwatch()..start();
        queries.transportationQuery("Københavns Kommune", "Aarhus Kommune");
        countMili2 += stopwatch2.elapsed.inMilliseconds;

        stopwatch3 = new Stopwatch()..start();
        queries.foodQuery("Københavns Kommune", "Aarhus Kommune");
        countMili3 += stopwatch3.elapsed.inMilliseconds;

      }
      //print("Billund Entertainment: ${countMili1}");

      //print("KBH + Aarhus time Entertainment: ${countMili1}");
      print("KBH + Aarhus time avg (5) Entertainment: ${countMili1/5}");
      print("KBH + Aarhus time avg (5) Transportation: ${countMili2/5}");
      print("KBH + Aarhus time avg (5) Food: ${countMili3/5}");
      //print("Billund + Morsø time avg (5): ${countMili2/5}");
      //}
      //print(" Stopwatch 49 queries avg: ${countMili1/5}");
      //print(count);
      // print(repo.relations.length);
    });
  });


}