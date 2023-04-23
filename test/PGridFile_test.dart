import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/data/GridFile.dart';
import 'package:github_client/data/PGridFile.dart';
import 'package:github_client/data/csvRepository.dart';
import 'package:github_client/data/jsonRepository.dart';
import 'package:github_client/models/node.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

    group("Access nodes", () {
      jsonRepository repo = jsonRepository();

      test("grid file FIND on Københavns Kommune contains all the boundary box nodes", () async {
        await repo.loadJsonData();
        Rectangle denmarkBounds = repo.addBoundingBoxToDenmark();
        var gridFile = PGridFile(denmarkBounds, repo.relations,repo.nodes);
        gridFile.initializeGrid();

        var CPH = repo.relations.firstWhere((element) => element.name == "Aarhus Kommune");

        //the Grid File Nodes returned
        List<List<Node>> nodes = gridFile.find(CPH);

        //The bounding box around CPH from repo
        List<Node> allNodesInMuniRect = gridFile.allNodesInRectangle(CPH.boundingBox!);

        List<Node> nodesInPolygon = [];
        var bounds = repo.getMunilist(["Aarhus Kommune"]);
        print(nodes[0].length);
        print(nodes[1].length);
        
        for( var element in nodes[1]){
          for (int j = 0; bounds.length > j; j++) {
            if (jsonRepository.isPointInPolygon(
                LatLng(element.lat, element.lon), bounds[j])) {
              nodes[0].add(element);
              break;
            }
          }
            }


        for (var element in allNodesInMuniRect) {
          if(element.isAmenity) {
            for (int j = 0; bounds.length > j; j++) {
              if (jsonRepository.isPointInPolygon(
                  LatLng(element.lat, element.lon), bounds[j])) {
                nodesInPolygon.add(element);
              }
            }
          }
        }


        nodes[0].forEach((element) {
          if(!allNodesInMuniRect.contains(element)){
            print("FEJL");
          }
        });
        print(nodes[0].length);
        print(allNodesInMuniRect.length);
        expect(nodes[0].length<allNodesInMuniRect.length, true);
        print(nodesInPolygon.length);
        expect(nodesInPolygon.length, nodes[0].length);

      });
    });
  group("Test subgrid partition size", ()  {
    csvRepository csvRepo = csvRepository();
    jsonRepository repo = jsonRepository();


    test("s", () async {
      await csvRepo.loadCSVFiles("assets/hovedtal-2022uddCSV.csv", "assets/SchoolAddresses.csv");
      await repo.loadJsonData();
      repo.addPopulationToMunicipality(csvRepo);

      //var gridFile = PGridFile1(denmarkBounds, repo.relations,repo.nodes);
      //gridFile.initializeGrid();
      queriesGrid queries = queriesGrid(repo, csvRepo);
      Stopwatch stopwatch;
      Stopwatch stopwatch2;
      Stopwatch stopwatch3;

      int countMili1 = 0;
      int countMili2 = 0;
      int countMili3 = 0;
      //for(int i = 0 ; i<repo.relations.length-1 ; i+=2){
      for(int i = 0 ; i<5 ; i++){
        stopwatch = new Stopwatch()..start();
        queries.entertainmentQuery("Københavns Kommune", "Aarhus Kommune");
        countMili1 += stopwatch.elapsed.inMilliseconds;

        //count++;
        stopwatch2 = new Stopwatch()..start();
        queries.transportationQuery("Københavns Kommune", "Aarhus Kommune");
        countMili2 += stopwatch2.elapsed.inMilliseconds;

        stopwatch3 = new Stopwatch()..start();
        queries.foodQuery("Københavns Kommune", "Aarhus Kommune");
        countMili3 += stopwatch3.elapsed.inMilliseconds;

        /*stopwatch2 = new Stopwatch()..start();
        queries.entertainmentQuery("Billund Kommune", "Morsø Kommune");
        countMili2 += stopwatch2.elapsed.inMilliseconds;
*/

      }
      print("KBH + Aarhus time avg (5) Entertainment: ${countMili1/5}");
      print("KBH + Aarhus time avg (5) Transportation: ${countMili2/5}");
      print("KBH + Aarhus time avg (5) Food: ${countMili3/5}");
      //print("Billund + Morsø time avg (5): ${countMili2/5}");
      //}
      //print(" Stopwatch 49 queries: ${stopwatch.elapsed.inMilliseconds}");
      //print(count);
     // print(repo.relations.length);
    });
  });
}