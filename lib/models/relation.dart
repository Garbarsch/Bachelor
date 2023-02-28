

import 'package:latlong2/latlong.dart';

class MunicipalityRelation{
  final String id;
  final String? name;
  List<LatLng> boundaryCoords; //node ids
  final bool isMulti;

  MunicipalityRelation({required this.id, required this.name, required this.boundaryCoords, required this.isMulti});

  factory MunicipalityRelation.fromJson(Map<String,dynamic> data){
    if(data["geometry"]["type"] == "MultiPolygon"){


      return MunicipalityRelation(
          id: data["id"],
          name: data["properties"]["name:da"],
          boundaryCoords: [],
          isMulti: true
      );
    }
    //data["geometry"]["coordinates"][0].forEach((coordList){print("lat: ${LatLng(coordList[0], coordList[1])}");});
    //var list = data["geometry"]["coordinates"][0].map((e) => LatLng(e[0], e[1])).toList();
    return MunicipalityRelation(
        id: data["id"],
        name: data["properties"]["name:da"],
        boundaryCoords: List<LatLng>.from(data["geometry"]["coordinates"][0].map((e) => LatLng(e[0], e[1]))),
        isMulti: false
      );

  }

}