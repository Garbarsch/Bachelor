import 'dart:math';

import 'package:latlong2/latlong.dart';

class MunicipalityRelation{
  final String id;
  final String name;
  late int? population;
  List<LatLng> boundaryCoords; //node ids
  List<List<LatLng>>? multiBoundaryCoords;
  final bool isMulti;
  late Rectangle? boundingBox;

  MunicipalityRelation({required this.id, required this.name, required this.boundaryCoords, this.multiBoundaryCoords, required this.isMulti, this.population, this.boundingBox});

  factory MunicipalityRelation.fromJson(Map<String,dynamic> data){
    if(data["geometry"]["type"] == "MultiPolygon"){

      List<List<LatLng>> aux = [];

      //print(data["geometry"]["coordinates"]);
      data["geometry"]["coordinates"].forEach((polygon){
        aux.add(
            List<LatLng>.from(polygon[0].map((dynamic coordinateList) => LatLng(coordinateList[1]/1, coordinateList[0]/1)))
        );
      });

      return MunicipalityRelation(
          id: data["id"],
          name: data["properties"]["name:da"],
          boundaryCoords: [],
          multiBoundaryCoords: aux,//(data["geometry"]["coordinates"].map((e1) => e1[0].map((e) => LatLng(e[0], e[1])))),//List<List<LatLng>>.from(data["geometry"]["coordinates"][0].map((e) => LatLng(e[0], e[1])).toList()),
          isMulti: true
      );
    }
    return MunicipalityRelation(
        id: data["id"],
        name: data["properties"]["name:da"],
        boundaryCoords: List<LatLng>.from(data["geometry"]["coordinates"][0].map((e) => LatLng(e[1], e[0]))),
        isMulti: false
      );

  }

}