

import 'package:latlong2/latlong.dart';

class Node{
  final int id;
  final num lon,lat;
  final bool isAmenity;
  Map<String,dynamic>? tags;

  Node({required this.id, required this.lon, required this.lat, this.tags, required this.isAmenity});

  factory Node.fromJson(Map<String,dynamic> data){
      if (data.containsKey("tags")) {
        return Node(
            id: data["id"],
            lon: data["lon"],
            lat: data["lat"],
            tags: data["tags"],
            isAmenity: true
        );
      }
      return Node(
          id: data["id"],
          lon: data["lon"],
          lat: data["lat"],
          isAmenity: false
      );
  }






}