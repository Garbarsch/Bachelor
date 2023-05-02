import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/data/GridFile.dart';
import 'package:github_client/data/GridFileFlex.dart';
import 'package:github_client/data/csvRepository.dart';
import 'package:github_client/data/jsonRepository.dart';
import 'package:github_client/models/node.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("Load Grid File", ()  {
    jsonRepository repo = jsonRepository();


    test("Load Grid File", () async
    {
      Stopwatch stopwatch = new Stopwatch()..start();
      await repo.loadJsonData();
      print("load JSON time: ${stopwatch.elapsed.inMilliseconds}");

      Rectangle denmarkBounds = repo.addBoundingBoxToDenmark();
      var gridFile = GridFileFlex(denmarkBounds, repo.relations,repo.nodes, 400);
      gridFile.initializeGrid();

      expect(gridFile.gridArray, isNotNull);
      expect(gridFile.linearScalesRectangles, isNotNull);
      expect(gridFile.blockCollection, isNotNull);
    });

    test("linearScales correspondence with gridFile (directory", () {
      Rectangle denmarkBounds = repo.addBoundingBoxToDenmark();
      var gridFile = GridFileFlex(denmarkBounds, repo.relations,repo.nodes, 400);
      gridFile.initializeGrid();

      var scalesLongLength = gridFile.linearScalesRectangles.length;
      var scalesLatLength = gridFile.linearScalesRectangles[0].length;
      var gridLongLength = gridFile.gridArray.length;
      var gridLatLength = gridFile.gridArray[0].length;

      expect(scalesLatLength, gridLatLength);
      expect(scalesLongLength, gridLongLength);

    });
    test("cells match Denmark", ()
    {
      Rectangle denmarkBounds = repo.addBoundingBoxToDenmark();
      var gridFile = GridFileFlex(denmarkBounds, repo.relations,repo.nodes, 400);
      gridFile.initializeGrid();

      print(denmarkBounds.top);
      print(denmarkBounds.bottom);

      //print(denmarkBounds.height);
      print(denmarkBounds.left);
      print(denmarkBounds.right);
      //print(denmarkBounds.width);

      expect(denmarkBounds.left, gridFile.linearScalesRectangles[0].first.left);
      //expect(denmarkBounds.right, gridFile.linearScalesRectangles.last[0].right); //TODO: this and the other commented we will fix when we fix the divide shit in the amount of cells up and right
      expect(denmarkBounds.top, gridFile.linearScalesRectangles[0].first.top); //so this is actually bottom..
      //expect(denmarkBounds.bottom, gridFile.linearScalesRectangles[0].last.bottom);
    });

    test("Test all nodes in blocks", ()
    {
      Rectangle denmarkBounds = repo.addBoundingBoxToDenmark();
      var gridFile = GridFileFlex(denmarkBounds, repo.relations,repo.nodes, 400);
      gridFile.initializeGrid();

      int countBlockNodes = 0;
      for (var nodeList in gridFile.blockCollection.values) {
        nodeList.forEach((node) {
          countBlockNodes++;
        });
      }

      expect(countBlockNodes, repo.nodes.length);
    });
  });

    group("Access nodes", () {
      jsonRepository repo = jsonRepository();

      test("grid file FIND on Københavns Kommune contains all the boundary box nodes", () async {
        await repo.loadJsonData();
        Rectangle denmarkBounds = repo.addBoundingBoxToDenmark();
        var gridFile = GridFileFlex(denmarkBounds, repo.relations,repo.nodes, 500);
        gridFile.initializeGrid();

        var CPH = repo.relations.firstWhere((element) => element.name == "Aarhus Kommune");

        //the Grid File Nodes returned
        List<List<Node>> nodes = gridFile.find(CPH);

        //The bounding box around CPH from repo
        List<Node> allNodesInMuniRect = gridFile.allNodesInRectangle(CPH.boundingBox!);

        List<Node> nodesInPolygon = [];
        var bounds = repo.getMunilist(["Aarhus Kommune"]);

        for (var element in allNodesInMuniRect) {
          if(element.isAmenity) {
            for (int j = 0; bounds.length > j; j++) {
              if (jsonRepository.isPointInPolygon(
                  LatLng(element.lat, element.lon), bounds[j])) {
                nodesInPolygon.add(element);
                break;
              }
            }
          }
        }


        for( var element in nodes[1]){
          for (int j = 0; bounds.length > j; j++) {
            if (jsonRepository.isPointInPolygon(
                LatLng(element.lat, element.lon), bounds[j])) {
              nodes[0].add(element);
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
        print(nodesInPolygon.length);
        expect(nodes[0].length < allNodesInMuniRect.length, true);
        expect(nodesInPolygon.length, nodes[0].length);

      });
    });
  group("Test cell cap size", ()  {
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
    /*  for(int x = 0 ; x<5 ; x++) {
      for(int i = 0 ; i<repo.relations.length-1 ; i+=2) {

        stopwatch = new Stopwatch()..start();
        queries.entertainmentQuery(repo.relations[i].name, repo.relations[i+1].name);
        countMili1 += stopwatch.elapsed.inMilliseconds;

      }}*/

      for(int i = 0 ; i<5 ; i++){
        stopwatch = new Stopwatch()..start();
        queries.entertainmentQuery("Københavns Kommune", "Aarhus Kommune");
        countMili1 += stopwatch.elapsed.inMilliseconds;
        /*stopwatch = new Stopwatch()..start();
        queries.getNighlifeForMuniForGrid("Billund Kommune");
        countMili1 += stopwatch.elapsed.inMilliseconds;*/

        stopwatch2 = new Stopwatch()..start();
        queries.transportationQuery("Københavns Kommune", "Aarhus Kommune");
        countMili2 += stopwatch2.elapsed.inMilliseconds;

        stopwatch3 = new Stopwatch()..start();
        queries.foodQuery("Københavns Kommune", "Aarhus Kommune");
        countMili3 += stopwatch3.elapsed.inMilliseconds;

       /*stopwatch2 = new Stopwatch()..start();
        queries.entertainmentQuery("Billund Kommune", "Morsø Kommune");
        countMili2 += stopwatch2.elapsed.inMilliseconds;*/

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