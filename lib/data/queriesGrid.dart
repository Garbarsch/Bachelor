part of 'package:github_client/data/jsonRepository.dart';

class queriesGrid{
  final jsonRepository repo;
  final csvRepository csvRepo;
  late final PGridFile grid;
  late List<List<Rectangle<num>>> gridRects;

  queriesGrid(this.repo, this.csvRepo){
    grid = PGridFile(repo.addBoundingBoxToDenmark(), 30000, repo);
    grid.initializeGrid();
    gridRects = grid.linearScalesRectangles;
  }

  List<Polygon> drawIndexAlgorithmOnMap(){
    var muni = "Viborg Kommune";
    List<Polygon> polygonsToBeDrawn;
    List<Polygon> boundary = [];
    List<Polygon> polyList = repo.getMuniPolygons([muni]);
    //List<Polygon> polyList2 = repo.getLargestMuniPolygon([muni]);

    Rectangle<num>? muni1Rect = repo.relations.firstWhere((element) => element.name == muni).boundingBox;

    // Make the coordinates of each corner of the munirect to LatLongs.
    Polygon boundingBoxToPolygon = Polygon(points: [LatLng(muni1Rect!.bottomLeft.y.toDouble(), muni1Rect.bottomLeft.x.toDouble()),LatLng(muni1Rect!.topLeft.y.toDouble(), muni1Rect.topLeft.x.toDouble()),LatLng(muni1Rect!.topRight.y.toDouble(), muni1Rect.topRight.x.toDouble()),LatLng(muni1Rect!.bottomRight.y.toDouble(), muni1Rect.bottomRight.x.toDouble())],isFilled: false, color: Colors.black, borderStrokeWidth: 2);
    boundary.add(boundingBoxToPolygon);
    List<Polygon> gridpolygons = [];
    gridRects.forEach((element) { element.forEach((element) {gridpolygons.add(Polygon(points: [LatLng(element.bottomLeft.y.toDouble(), element.bottomLeft.x.toDouble()),LatLng(element.topLeft.y.toDouble(), element.topLeft.x.toDouble()),LatLng(element.topRight.y.toDouble(), element.topRight.x.toDouble()),LatLng(element.bottomRight.y.toDouble(), element.bottomRight.x.toDouble()) ],isFilled: false, color: Colors.redAccent)); });});

    //green is boundary box of muni
    //pink is cells from grid file.



    return   polyList+ gridpolygons + boundary  ;
  }

  List<query_model> bulletQuery(String muni, MunicipalityRelation muniRect) {//den her skal også fikses.
    List<query_model> mun =[];

    var munici = repo.relations.where((element) => element.name == muni).first;
    List<Node> muniNodes = grid.find(munici);

    mun.add((query_model("Population: ", munici.population!)));
    mun.add(query_model("Cafes: ", repo.getAmenityNodesFromNodes(muniNodes, muni, "cafe").value)); //getAmenityNodesFromNdes for PGrid and getAmenityNdesInMuni for normal grid
    mun.add(query_model("Restuarants: ", repo.getAmenityNodesFromNodes(muniNodes, muni, "restaurant").value));
    mun.add(query_model("Train stations: ", repo.getAmenityNodesFromNodes(muniNodes, muni, "station").value));

    return mun;
  }

  List<List<query_model>> entertainmentQuery(String muni1, String muni2) {
    Stopwatch stopwatch = new Stopwatch()..start();
    List<List<query_model>> model = [];
    List<query_model> mun1 =[];
    List<query_model> mun2 = [];
    MunicipalityRelation muni1Rect = repo.relations.firstWhere((element) => element.name == muni1);
    MunicipalityRelation muni2Rect = repo.relations.firstWhere((element) => element.name == muni2);

    List<query_model> bulletMuni1 = bulletQuery(muni1, muni1Rect);
    List<query_model> bulletMuni2 = bulletQuery(muni2, muni2Rect);

    List<Node> muni1Nodes = grid.find(muni1Rect!);
    List<Node> muni2Nodes = grid.find(muni2Rect!);

    var nightlife = repo.getAmenityNodesFromNodes(muni1Nodes, muni1, "nightlife");
    mun1.add(query_model("Nightlife", nightlife.value));

    nightlife = repo.getAmenityNodesFromNodes(muni2Nodes, muni2, "cafe");
    mun2.add(query_model("Nightlife", nightlife.value));

    var cinema = repo.getAmenityNodesFromNodes(muni1Nodes, muni1, "cinema");
    mun1.add(query_model("Cinema", cinema.value));

    cinema = repo.getAmenityNodesFromNodes(muni2Nodes, muni2, "cafe");
    mun2.add(query_model("Cinema", cinema.value));

    var art_centre = repo.getAmenityNodesFromNodes(muni1Nodes, muni1, "arts_centre");
    mun1.add(query_model("Art Centre", art_centre.value));

    art_centre = repo.getAmenityNodesFromNodes(muni2Nodes, muni2, "arts_centre");
    mun1.add(query_model("Art Centre", art_centre.value));


    var community_centre = repo.getAmenityNodesFromNodes(muni1Nodes, muni1, "community_centre");
    mun1.add(query_model("Community Centre", community_centre.value));

    community_centre = repo.getAmenityNodesFromNodes(muni2Nodes, muni2, "community_centre");
    mun2.add(query_model("Community Centre", community_centre.value));


    var music_venue = repo.getAmenityNodesFromNodes(muni1Nodes, muni1, "music_venue");
    mun1.add(query_model("Music Venues", music_venue.value));

    music_venue = repo.getAmenityNodesFromNodes(muni2Nodes, muni2, "music_venue");
    mun2.add(query_model("Music Venues", music_venue.value));

    model.add(mun1);
    model.add(bulletMuni1);
    model.add(bulletMuni2);
    model.add(mun2);

    print("Entertainment query time: ${stopwatch.elapsed.inMilliseconds}");
    return model;
  }

  List<List<query_model>> foodQuery(String muni1, String muni2){
    Stopwatch stopwatch = new Stopwatch()..start();
    List<List<query_model>> model = [];
    List<query_model> mun1 =[];
    List<query_model> mun2 = [];

    MunicipalityRelation muni1Rect = repo.relations.firstWhere((element) => element.name == muni1);
    MunicipalityRelation muni2Rect = repo.relations.firstWhere((element) => element.name == muni2);

    List<query_model> bulletMuni1 = bulletQuery(muni1, muni1Rect!);
    List<query_model> bulletMuni2 = bulletQuery(muni2, muni2Rect!);

    List<Node> muni1Nodes = grid.find(muni1Rect!);
    List<Node> muni2Nodes = grid.find(muni2Rect!);

    var cafe = repo.getAmenityNodesFromNodes(muni1Nodes, muni1, "cafe");
    mun1.add(query_model("Cafe", cafe.value));



    cafe = repo.getAmenityNodesFromNodes(muni2Nodes, muni2, "cafe");
    mun2.add(query_model("Cafe", cafe.value));

    var resturants = repo.getAmenityNodesFromNodes(muni1Nodes, muni1, "restaurant");
    mun1.add(query_model("Restaurants", resturants.value));

    resturants = repo.getAmenityNodesFromNodes(muni2Nodes, muni2, "restaurant");
    mun2.add(query_model("Restaurants", resturants.value));

    model.add(mun1);
    model.add(bulletMuni1);
    model.add(bulletMuni2);
    model.add(mun2);
    print("Food query time: ${stopwatch.elapsed.inMilliseconds}");
    return model;

  }
  List<List<query_model>> transportationQuery(String muni1,String muni2) {
    Stopwatch stopwatch = new Stopwatch()..start();
    List<List<query_model>> model = [];

    List<query_model> mun1 =[];
    List<query_model> mun2 = [];
    /*Rectangle<num>? muni1Rect = repo.relations.firstWhere((element) => element.name == muni1).boundingBox;
    Rectangle<num>? muni2Rect = repo.relations.firstWhere((element) => element.name == muni2).boundingBox;*/
    MunicipalityRelation muni1Rect = repo.relations.firstWhere((element) => element.name == muni1);
    MunicipalityRelation muni2Rect = repo.relations.firstWhere((element) => element.name == muni2);

    List<query_model> bulletMuni1 = bulletQuery(muni1, muni1Rect!);
    List<query_model> bulletMuni2 = bulletQuery(muni2, muni2Rect!);

    List<Node> muni1Nodes = grid.find(muni1Rect!);
    List<Node> muni2Nodes = grid.find(muni2Rect!);


    var bus_stations =  repo.getAmenityNodesFromNodes(muni1Nodes, muni1, "bus");
    mun1.add(query_model("Bus stations", bus_stations.value));

    bus_stations = repo.getAmenityNodesFromNodes(muni2Nodes, muni2, "bus");
    mun2.add(query_model("Bus stations", bus_stations.value));

    var train_stations = repo.getAmenityNodesFromNodes(muni1Nodes, muni1, "station");
    mun1.add(query_model("Train stations", train_stations.value));

    train_stations = repo.getAmenityNodesFromNodes(muni2Nodes, muni2, "station");
    mun2.add(query_model("Train stations", train_stations.value));

    model.add(mun1);
    model.add(bulletMuni1);
    model.add(bulletMuni2);
    model.add(mun2);

    print("Transportation query time: ${stopwatch.elapsed.inMilliseconds}");
    return model;
  }


  List<List<query_model>> educationOfferPercentageQuery(String muni1, String muni2){

    List<List<LatLng>> muni1Bound = repo.getSingleMuniBoundary(muni1);
    List<List<LatLng>> muni2Bound = repo.getSingleMuniBoundary(muni2);
    int totalEducationOptions = csvRepo.getAllEducationOptions().length;


    double percentageMuni1 = double.parse((csvRepo.getAmountEducationsInMuni(muni1, muni1Bound)/totalEducationOptions * 100).toStringAsFixed(2));
    double percentageMuni2 = double.parse((csvRepo.getAmountEducationsInMuni(muni2, muni2Bound)/totalEducationOptions* 100).toStringAsFixed(2));

    var muni1QueryModel = query_model(muni1, 0, percentageMuni1);
    var muni2QueryModel = query_model(muni2, 0, percentageMuni2);

    return [[muni1QueryModel, muni2QueryModel]];
  }
  List<List<query_model>> educationBarStats(String muni1, String muni2){
    List<List<LatLng>> muni1Bound = repo.getSingleMuniBoundary(muni1);
    List<List<LatLng>> muni2Bound = repo.getSingleMuniBoundary(muni2);
    var applicantsMuni1 = csvRepo.getAllApplicantsInMuni(muni1, muni1Bound);
    var applicantsMuni2 = csvRepo.getAllApplicantsInMuni(muni2, muni2Bound);

    var acceptedApplicantsMuni1 = csvRepo.getAllApplicantsAcceptedInMuni(muni1, muni1Bound);
    var acceptedApplicantsMuni2 = csvRepo.getAllApplicantsAcceptedInMuni(muni2, muni2Bound);

    var popuMuni2DivApp;

    var  popuMuni1DivApp = applicantsMuni1/((repo.relations.where((element) => element.name == muni1).first).population)! * 10000;

    if(applicantsMuni2 == 0){
      popuMuni2DivApp = 0.0;
    }else{
      popuMuni2DivApp = ((repo.relations.where((element) => element.name == muni2).first).population)!/applicantsMuni2;
    }

    var muni1QueryModel =  query_model(muni1, applicantsMuni1,0,acceptedApplicantsMuni1,popuMuni1DivApp);
    var muni2QueryModel = query_model(muni2, applicantsMuni2,0,acceptedApplicantsMuni2,popuMuni2DivApp);

    return [[muni1QueryModel, muni2QueryModel]];
  }

  List<List<query_model>> educationTopLayerSchoolsPercentage(String muni1, String muni2){

    //municipality bounds
    List<List<LatLng>> muni1Bound = repo.getSingleMuniBoundary(muni1);
    List<List<LatLng>> muni2Bound = repo.getSingleMuniBoundary(muni2);

    //schools within these bounds
    List<School> muni1Schools = csvRepo.getAllSchoolsInMuni(muni1, muni1Bound);
    List<School> muni2Schools = csvRepo.getAllSchoolsInMuni(muni2, muni2Bound);

    //placeholders for query_models
    List<query_model> tempQueryList1 = [];
    List<query_model> tempQueryList2 = [];

    //var to increment all appliers of each municipality
    var totalAppliersMuni1 = 0;
    var totalAppliersMuni2 = 0;

    //check for each top-layer school, is the schools within muni a part of that?
    //TODO: vi burde nok bare tjekke hvilke toplayer skole høre til hver skole i kommunen i stedet.
    csvRepo.schoolInfoMap.forEach((key, value) {
      String topLayerSchool = key;
      var inMuni1 = false;
      var inMuni2 = false;
      int schoolAppliersMuni1 = 0;
      int schoolAppliersMuni2 = 0;

      //does this muni have a school under ths top-layer school/faculty
      muni1Schools.forEach((element) {
        if(value.contains(element)){
          schoolAppliersMuni1 += element.appliers.toInt();
          totalAppliersMuni1 += element.appliers.toInt();
          inMuni1 = true;
        }
      });

      //if it does, then we save it for later
      if(inMuni1){
        tempQueryList1.add(query_model(topLayerSchool, 0, (schoolAppliersMuni1/1), 0,0,muni1)); //find ud af noget her wtf luder pis - kan være vi slet ik har brug for muni derinde, hm.
      }

      muni2Schools.forEach((element) {
        if(value.contains(element)){
          schoolAppliersMuni2 += element.appliers.toInt();
          totalAppliersMuni2 += element.appliers.toInt();
          inMuni2 = true;
        }
      });

      if(inMuni2){
        tempQueryList2.add(query_model(topLayerSchool, 0, (schoolAppliersMuni2/1), 0,0, muni2));
      }

    });

    //now make it percentage, to showcase the applier distribution of top-layer schools on the chosen municipalities
    tempQueryList1.forEach((element) {
      element.percentage = element.percentage/totalAppliersMuni1*100;
    });
    tempQueryList2.forEach((element) {
      element.percentage = element.percentage/totalAppliersMuni2*100;
    });


    //we have to reorder the list to align the data for graph visualization.
    List<query_model> tempInBoth = [];
    for (var element in tempQueryList2) {
      tempInBoth.addAll(tempQueryList1.where((element2) => element.x == element2.x));
    }

    List<query_model> both1 = [];
    List<query_model> both2 = [];
    tempInBoth.forEach((element) {

      both2.addAll(tempQueryList2.where((element2) => element2.x == element.x));
      tempQueryList2.removeWhere((element2) => both2.contains(element2));

      both1.addAll(tempQueryList1.where((element1) => element1.x == element.x));
      tempQueryList1.removeWhere((element1) => both1.contains(element1));

    });

    tempQueryList1.addAll(both1);
    both2.addAll(tempQueryList2);

    return [tempQueryList1,both2];
  }

  List<List<query_model>> educationQuery(String muni1, String muni2){
    Stopwatch stopwatch = new Stopwatch()..start();
    var graph1 = educationTopLayerSchoolsPercentage(muni1, muni2);
    var graph2 = educationOfferPercentageQuery(muni1, muni2);
    var graph3 = educationBarStats(muni1, muni2);
    /*Rectangle<num>? muni1Rect = repo.relations.firstWhere((element) => element.name == muni1).boundingBox;
    Rectangle<num>? muni2Rect = repo.relations.firstWhere((element) => element.name == muni2).boundingBox;*/
    MunicipalityRelation muni1Rect = repo.relations.firstWhere((element) => element.name == muni1);
    MunicipalityRelation muni2Rect = repo.relations.firstWhere((element) => element.name == muni2);

    List<query_model> bulletMuni1 = bulletQuery(muni1, muni1Rect!);
    List<query_model> bulletMuni2 = bulletQuery(muni2, muni2Rect!);
    graph1.addAll(graph2);
    graph1.addAll(graph3);
    graph1.add(bulletMuni1);
    graph1.add(bulletMuni2);

    print("Education query time: ${stopwatch.elapsed.inMilliseconds}");
    return graph1;
  }

}
