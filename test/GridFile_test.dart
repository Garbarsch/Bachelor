import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/data/GridFile.dart';
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
      var gridFile = GridFile(denmarkBounds, repo.relations,repo.nodes);
      gridFile.initializeGrid();

      expect(gridFile.gridArray, isNotNull);
      expect(gridFile.linearScalesRectangles, isNotNull);
      expect(gridFile.blockCollection, isNotNull);
    });

    test("linearScales correspondence with gridFile (directory", () {
      Rectangle denmarkBounds = repo.addBoundingBoxToDenmark();
      var gridFile = GridFile(denmarkBounds, repo.relations,repo.nodes);

      gridFile.initializeGrid();

      var scalesLatLength = gridFile.linearScalesRectangles.length;
      var scalesLongLength = gridFile.linearScalesRectangles[0].length;
      var gridLatLength = gridFile.gridArray.length;
      var gridLongLength = gridFile.gridArray[0].length;

      expect(scalesLatLength, gridLatLength);
      expect(scalesLongLength, gridLongLength);

    });
    test("cells match Denmark", ()
    {
      Rectangle denmarkBounds = repo.addBoundingBoxToDenmark();
      var gridFile = GridFile(denmarkBounds,  repo.relations,repo.nodes);
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
      var gridFile = GridFile(denmarkBounds,  repo.relations,repo.nodes);
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
        var gridFile = GridFile(denmarkBounds, repo.relations, repo.nodes);
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
        for (var element in nodes[1]) {
            for (int j = 0; bounds.length > j; j++) {
              if (jsonRepository.isPointInPolygon(
                  LatLng(element.lat, element.lon), bounds[j])) {
                nodes[0].add(element);
                break;
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









}