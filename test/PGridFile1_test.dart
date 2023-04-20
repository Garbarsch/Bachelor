import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/data/GridFile.dart';
import 'package:github_client/data/PGridFile.dart';
import 'package:github_client/data/PGridFile1.dart';
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
      var gridFile = PGridFile1(denmarkBounds, repo.relations,repo.nodes);
      gridFile.initializeGrid();

      var CPH = repo.relations.firstWhere((element) => element.name == "Viborg Kommune");

      //the Grid File Nodes returned
      List<List<Node>> nodes = gridFile.find(CPH);

      //The bounding box around CPH from repo
      List<Node> allNodesInMuniRect = gridFile.allNodesInRectangle(CPH.boundingBox!);

      List<Node> nodesInPolygon = [];
      var bounds = repo.getMunilist(["Viborg Kommune"]);

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
      expect(nodes[0].length<allNodesInMuniRect.length, true);

      expect(nodesInPolygon.length, nodes[0].length);

    });
  });
}