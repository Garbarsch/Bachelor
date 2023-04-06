
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
      expect(repo.data.isNotEmpty, true);
      expect(repo.amenityNodes.isNotEmpty, true);
      expect(repo.amenityNodes.values.first.lon != 0, true);
      expect(repo.amenityNodes.values.first.lat != 0, true);
    });
    test("load geoJSON", () {
      expect(repo.geoData.isNotEmpty, true);
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
    Map<int, Node> nodes = {};

    //seed data
    var node1 = Node(id: 1, lon: 1, lat: 1, isAmenity: true, tags: {'amenity':'cafe'});
    nodes[node1.id] = node1;
    var node2 = Node(id: 2, lon: 2, lat: 2, isAmenity: true, tags: {'amenity':'restaurant'});
    nodes[node2.id] = node2;
    var node3 = Node(id: 3, lon: 3, lat: 3, isAmenity: true, tags: {'amenity':'college'});
    nodes[node3.id] = node3;
    var node4 = Node(id: 4, lon: 4, lat: 4, isAmenity: true, tags: {'amenity':'university'});
    nodes[node4.id] = node4;
    var node5 = Node(id: 5, lon: 5, lat: 5, isAmenity: true, tags: {'railway':'station'});
    nodes[node5.id] = node5;
    var node6 = Node(id: 6, lon: 6, lat: 6, isAmenity: true, tags: {'amenity':'bus_station'});
    nodes[node6.id] = node6;
    var node7 = Node(id: 7, lon: 7, lat: 7, isAmenity: true, tags: {'amenity':'cinema'});
    nodes[node7.id] = node7;
    var node8 = Node(id: 8, lon: 8, lat: 8, isAmenity: true, tags: {'amenity':'library'});
    nodes[node8.id] = node8;
    var node9 = Node(id: 9, lon: 9, lat: 9, isAmenity: true, tags: {'amenity':'dentist'});
    nodes[node9.id] = node9;
    var node10 = Node(id: 10, lon: 10, lat: 10, isAmenity: true, tags: {'amenity':'clinic'});
    nodes[node10.id] = node10;
    var node11 = Node(id: 11, lon: 11, lat: 11, isAmenity: true, tags: {'amenity':'bar'});
    nodes[node11.id] = node11;
    var node12 = Node(id: 12, lon: 12, lat: 12, isAmenity: true, tags: {'amenity':'pub'});
    nodes[node12.id] = node12;
    var node13 = Node(id: 13, lon: 13, lat: 13, isAmenity: true, tags: {'amenity':'nightclub'});
    nodes[node13.id] = node13;
    var node14 = Node(id: 14, lon: 14, lat: 14, isAmenity: true, tags: {'amenity':'training'});
    nodes[node14.id] = node14;
    var node15 = Node(id: 15, lon: 15, lat: 15, isAmenity: true, tags: {'public_transport':'station'});
    nodes[node15.id] = node15;
    var node16 = Node(id: 16, lon: 16, lat: 16, isAmenity: true, tags: {'amenity':'hospital'});
    nodes[node16.id] = node16;
    var node17 = Node(id: 17, lon: 17, lat: 17, isAmenity: true, tags: {'amenity':'arts_centre'});
    nodes[node17.id] = node17;
    var node18 = Node(id: 18, lon: 18, lat: 18, isAmenity: true, tags: {'amenity':'community_centre'});
    nodes[node18.id] = node18;
      var node19 = Node(id: 19, lon: 19, lat: 19, isAmenity: true, tags: {'amenity':'events_venue'});
    nodes[node19.id] = node19;
    var node20 = Node(id: 20, lon: 20, lat: 20, isAmenity: true, tags: {'amenity':'exhibition_centre'});
    nodes[node20.id] = node20;
    var node21 = Node(id: 21, lon: 21, lat: 21, isAmenity: true, tags: {'amenity':'conference_centre'});
    nodes[node21.id] = node21;
    var node22 = Node(id: 22, lon: 22, lat: 22, isAmenity: true, tags: {'amenity':'music_venue'});
    nodes[node22.id] = node22;
    var node23 = Node(id: 23, lon: 23, lat: 23, isAmenity: true, tags: {'amenity':'social_centre'});
    nodes[node23.id] = node23;
    var node24 = Node(id: 24, lon: 24, lat: 24, isAmenity: true, tags: {'amenity':'theatre'});
    nodes[node24.id] = node24;
    var node25 = Node(id: 25, lon: 25, lat: 25, isAmenity: true, tags: {'amenity':'fire_station'});
    nodes[node25.id] = node25;
    var node26 = Node(id: 26, lon: 26, lat: 26, isAmenity: true, tags: {'amenity':'police'});
    nodes[node26.id] = node26;

    repo.amenityNodes = nodes;

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
    List<MunicipalityRelation> relations = [];

    var muniRel1 = MunicipalityRelation(id: "1", name: "KBH", boundaryCoords: [LatLng(1, 1), LatLng(2, 2), LatLng(6, 6)], isMulti: false);
    relations.add(muniRel1);
    Polygon poly1 = Polygon(points: muniRel1.boundaryCoords);
    var muniRel2 = MunicipalityRelation(id: "2", name: "FB", boundaryCoords:[], multiBoundaryCoords: [[LatLng(2, 2), LatLng(3, 3)],[LatLng(4, 4), LatLng(18, 18)]], isMulti: true);
    relations.add(muniRel2);
    Polygon poly2 = Polygon(points: muniRel2.multiBoundaryCoords!.first);
    Polygon poly3 = Polygon(points: muniRel2.multiBoundaryCoords!.last);


    repo.relations = relations;

    test("Latitude and Longitude specific municipality", () {

      List<LatLng> aux = repo.getMuniBoundary("KBH");
      expect(aux.isNotEmpty, true);
      expect(aux, muniRel1.boundaryCoords);
      expect(muniRel1.multiBoundaryCoords == null, true);

    });
    test("Get both municipality polygons of both Polygon and Multi Polygon boundaries", () {
      List<Polygon> aux = repo.getMuniPolygons(["KBH", "FB"]);

      expect(aux.length, 3);
      print(aux.first.points);
      expect(aux.first.points,poly1.points);
      expect(aux[1].points,poly2.points);
      expect(aux.last.points,poly3.points);
    });

    test("Test of isPointInPolygon method", (){
      List<LatLng> vertices = [LatLng(10, 10),LatLng(1, 10),LatLng(1, 1),LatLng(10, 1)]; // a square
      expect(jsonRepository.isPointInPolygon(LatLng(5, 5), vertices),true);
      expect(jsonRepository.isPointInPolygon(LatLng(7, 7), vertices),true);
      expect(jsonRepository.isPointInPolygon(LatLng(20, 20), vertices),false);
      expect(jsonRepository.isPointInPolygon(LatLng(1, 11), vertices),false);
    });

  });




}