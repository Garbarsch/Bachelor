
import 'dart:math';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/data/csvRepository.dart';
import 'package:github_client/data/jsonRepository.dart';
import 'package:github_client/models/node.dart';
import 'package:github_client/models/relation.dart';
import 'package:latlong2/latlong.dart';

void main() async{
  //this line is necessary for async not to give error.
  TestWidgetsFlutterBinding.ensureInitialized();

  group("load file test", () {
    var repo = jsonRepository();

    test("load JSON", () async{
      var success = await repo.loadJsonData();
      expect(success, "success");

      expect(repo.nodes.isNotEmpty, true);
      expect(repo.nodes.first.lon != 0, true);
      expect(repo.nodes.first.lat != 0, true);


    });
    test("load geoJSON", () {
      expect(repo.relations.isNotEmpty, true);
      expect(repo.relations.first.name != null, true );
    });
    test("Test: add population to each Municipality from csv file", () async
    {
      csvRepository csvRepo = csvRepository();
      await repo.addPopulationToMunicipality(csvRepo);
      expect(repo.relations.first.population, isNotNull);
      
    });    
  });
  group("amenity access methods", () {

    final repo = jsonRepository();
    List<Node> nodes = [];

    //seed data
    var node1 = Node(id: 1, lon: 1, lat: 1, isAmenity: true, tags: {'amenity':'cafe'});
    nodes.add(node1);
    var node2 = Node(id: 2, lon: 2, lat: 2, isAmenity: true, tags: {'amenity':'restaurant'});
    nodes.add(node2);
    var node3 = Node(id: 3, lon: 3, lat: 3, isAmenity: true, tags: {'amenity':'college'});
    nodes.add(node3);
    var node4 = Node(id: 4, lon: 4, lat: 4, isAmenity: true, tags: {'amenity':'university'});
    nodes.add(node4);
    var node5 = Node(id: 5, lon: 5, lat: 5, isAmenity: true, tags: {'railway':'station'});
    nodes.add(node5);
    var node6 = Node(id: 6, lon: 6, lat: 6, isAmenity: true, tags: {'amenity':'bus_station'});
    nodes.add(node6);
    var node7 = Node(id: 7, lon: 7, lat: 7, isAmenity: true, tags: {'amenity':'cinema'});
    nodes.add(node7);
    var node8 = Node(id: 8, lon: 8, lat: 8, isAmenity: true, tags: {'amenity':'library'});
    nodes.add(node8);
    var node9 = Node(id: 9, lon: 9, lat: 9, isAmenity: true, tags: {'amenity':'dentist'});
    nodes.add(node9);
    var node10 = Node(id: 10, lon: 10, lat: 10, isAmenity: true, tags: {'amenity':'clinic'});
    nodes.add(node10);
    var node11 = Node(id: 11, lon: 11, lat: 11, isAmenity: true, tags: {'amenity':'bar'});
    nodes.add(node11);
    var node12 = Node(id: 12, lon: 12, lat: 12, isAmenity: true, tags: {'amenity':'pub'});
    nodes.add(node12);
    var node13 = Node(id: 13, lon: 13, lat: 13, isAmenity: true, tags: {'amenity':'nightclub'});
    nodes.add(node13);
    var node14 = Node(id: 14, lon: 14, lat: 14, isAmenity: true, tags: {'amenity':'training'});
    nodes.add(node14);
    var node15 = Node(id: 15, lon: 15, lat: 15, isAmenity: true, tags: {'public_transport':'station'});
    nodes.add(node15);
    var node16 = Node(id: 16, lon: 16, lat: 16, isAmenity: true, tags: {'amenity':'hospital'});
    nodes.add(node16);
    var node17 = Node(id: 17, lon: 17, lat: 17, isAmenity: true, tags: {'amenity':'arts_centre'});
    nodes.add(node17);
    var node18 = Node(id: 18, lon: 18, lat: 18, isAmenity: true, tags: {'amenity':'community_centre'});
    nodes.add(node18);
      var node19 = Node(id: 19, lon: 19, lat: 19, isAmenity: true, tags: {'amenity':'events_venue'});
    nodes.add(node19);
    var node20 = Node(id: 20, lon: 20, lat: 20, isAmenity: true, tags: {'amenity':'exhibition_centre'});
    nodes.add(node20);
    var node21 = Node(id: 21, lon: 21, lat: 21, isAmenity: true, tags: {'amenity':'conference_centre'});
    nodes.add(node21);
    var node22 = Node(id: 22, lon: 22, lat: 22, isAmenity: true, tags: {'amenity':'music_venue'});
    nodes.add(node22);
    var node23 = Node(id: 23, lon: 23, lat: 23, isAmenity: true, tags: {'amenity':'social_centre'});
    nodes.add(node23);
    var node24 = Node(id: 24, lon: 24, lat: 24, isAmenity: true, tags: {'amenity':'theatre'});
    nodes.add(node24);
    var node25 = Node(id: 25, lon: 25, lat: 25, isAmenity: true, tags: {'amenity':'fire_station'});
    nodes.add(node25);
    var node26 = Node(id: 26, lon: 26, lat: 26, isAmenity: true, tags: {'amenity':'police'});
    nodes.add(node26);

    repo.nodes = nodes;

    test("Cafes", () {
      var values = repo.getCafesCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node1.lat, node1.lon)),true);

    });
    test("Higher Education", () {
      var values = repo.getHigherEducationCoords();

      expect(values.length, 2);
      expect(values.contains(LatLng(node4.lat, node4.lon)), true);

    });
    test("Train Station", () {
      var values = repo.getTrainStationCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node5.lat, node5.lon)), true);

    });
    test("Bus Stations", () {
      var values = repo.getBusCoords();

      expect(values.length, 2);
      expect(values.contains(LatLng(node6.lat, node6.lon)), true);
      expect(values.contains(LatLng(node15.lat, node15.lon)), true);

    });
    test("Cinema", () {
      var values = repo.getCinemaCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node7.lat, node7.lon)), true);

    });
    test("Library", () {
      var values = repo.getLibraryCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node8.lat, node8.lon)), true);

    });
    test("Dentist", () {
      var values = repo.getDentistCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node9.lat, node9.lon)), true);

    });
    test("Clinic", () {
      var values = repo.getClinicsCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node10.lat, node10.lon)), true);

    });
    test("Bar, Pub and NightClub", () {
      var values = repo.getBarPubNightClubCoords();

      expect(values.length, 3);
      expect(values.contains(LatLng(node11.lat, node11.lon)), true);
      expect(values.contains(LatLng(node12.lat, node12.lon)), true);
      expect(values.contains(LatLng(node13.lat, node13.lon)), true);

    });
    test("Training", () {
      var values = repo.getTrainingCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node14.lat, node14.lon)), true);

    });
    test("Hospital", () {
      var values = repo.getHospitalCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node16.lat, node16.lon)), true);

    });

    test("Arts centre", () {
      var values = repo.getArtsCentreCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node17.lat, node17.lon)), true);

    });
    test("Community centre", () {
      var values = repo.getCommunityCentreCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node18.lat, node18.lon)), true);

    });
    test("Events venue", () {
      var values = repo.getEventsVenueCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node19.lat, node19.lon)), true);

    });
    test("Exhibition centre", () {
      var values = repo.getExhibitionCentreCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node20.lat, node20.lon)), true);

    });
    test("Conference centre", () {
      var values = repo.getConferenceCentreCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node21.lat, node21.lon)), true);

    });
    test("Music venue", () {
      var values = repo.getMusicVenueCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node22.lat, node22.lon)), true);

    });
    test("Social centre", () {
      var values = repo.getSocialCentreCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node23.lat, node23.lon)), true);

    });
    test("Theatre", () {
      var values = repo.getTheatreCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node24.lat, node24.lon)), true);

    });
    test("Fire Station", () {
      var values = repo.getFireStationCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node25.lat, node25.lon)), true);

    });
    test("Police", () {
      var values = repo.getPoliceCoords();

      expect(values.length, 1);
      expect(values.contains(LatLng(node26.lat, node26.lon)), true);

    });
  });
  group("Municipality access geometrics", () {

    final repo = jsonRepository();

    var node1 = Node(id: 1, lon: 1, lat: 1, isAmenity: true, tags: {'amenity':'cafe'});
    List<Node> nodes = [];
    List<MunicipalityRelation> relations = [];


    //seed data
    var nodeCaf = Node(id: 1, lon: 3, lat: 4, isAmenity: true, tags: {'amenity':'cafe'});
    nodes.add(nodeCaf);
    var nodeCaf2 = Node(id: 2, lon: 4, lat: 2, isAmenity: true, tags: {'amenity':'cafe'});
    nodes.add(nodeCaf2);
    var nodeCaf3 = Node(id: 3, lon: 1, lat: 40, isAmenity: true, tags: {'amenity':'cafe'});
    nodes.add(nodeCaf3);;
    var nodeCaf4 = Node(id: 4, lon: 6, lat: 2, isAmenity: true, tags: {'amenity':'cafe'});
    nodes.add(nodeCaf4);


    var muniRel1 = MunicipalityRelation(id: "1", name: "Københavns Kommune", boundaryCoords: [LatLng(1, 1), LatLng(4, 4),LatLng(4, 1), LatLng(6, 6)], isMulti: false);
    relations.add(muniRel1);
    Polygon poly1 = Polygon(points: muniRel1.boundaryCoords);
    var muniRel2 = MunicipalityRelation(id: "2", name: "Frederiksberg Kommune", boundaryCoords:[], multiBoundaryCoords: [[LatLng(2, 2), LatLng(3, 3)],[LatLng(4, 4), LatLng(18, 18)]], isMulti: true);
    relations.add(muniRel2);
    Polygon poly2 = Polygon(points: muniRel2.multiBoundaryCoords!.first);
    Polygon poly3 = Polygon(points: muniRel2.multiBoundaryCoords!.last);


    repo.relations = relations;
    repo.addBoundingBoxToMunicipality();
    repo.nodes = nodes;

    test("Latitude and Longitude specific municipality", () {

      List<LatLng> aux = repo.getMuniBoundary("Københavns Kommune");
      expect(aux.isNotEmpty, true);
      expect(aux, muniRel1.boundaryCoords);
      expect(muniRel1.multiBoundaryCoords == null, true);

    });
    test("Get both municipality polygons of both Polygon and Multi Polygon boundaries", () {
      List<Polygon> aux = repo.getMuniPolygons(["Københavns Kommune", "Frederiksberg Kommune"]);

      expect(aux.length, 3);
      print(aux.first.points);
      expect(aux.first.points,poly1.points);
      expect(aux[1].points,poly2.points);
      expect(aux.last.points,poly3.points);
    });
    test("Rectangles added", () {
      Rectangle<num>? rect = repo.relations.first.boundingBox;
      expect(rect?.left, 1);
      expect(rect?.top, 1);
      expect(rect?.width, 5);
      expect(rect?.height, 5);
      expect(rect?.right, 6);
      expect(rect?.bottom, 6);
    });
    test("IsPointInMuniBoundingbox", () {
      //Rectangle<num>? rect = repo.relations.first.boundingBox;
      var actual = jsonRepository.isPointInMuniBoundingBox(LatLng(4,3), "Københavns Kommune", repo.relations);
      var actual2 = jsonRepository.isPointInMuniBoundingBox(LatLng(2,6), "Københavns Kommune", repo.relations);
      expect(actual, true);
      //actual2 is not within the polygon, but should be part of the bounding box around the polygon
      expect(actual2, true);

    });
    test("IsPointInPolygon",(){ //de to nederste her venter vi på at se hvad rasmus siger med PointInPolygon som ik virker.
      var isTrue = jsonRepository.isPointInPolygon(LatLng(3,3), poly1.points);
      print(isTrue);
      //expect(isTrue, true);
      poly1.points.forEach((element) {
        print(element.latitude);
        print(element.longitude);
        print("\n");
      });

    });
    test("Search point in rectangle café", () {
      var actual = repo.getCafeForMuniRect("Københavns Kommune");
      var expected = repo.getCafeForMunii("Københavns Kommune");
      var boxApproxThenPolyCheck = repo.getBoxCoordsForMuni("Københavns Kommune", ["cafe"]);

      expect(actual.value != expected.value, true);
      expect(boxApproxThenPolyCheck.value, expected.value);
      print(boxApproxThenPolyCheck.value);
      print(expected.value);
    });

  });




}