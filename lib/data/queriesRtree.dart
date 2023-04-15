//food
// entertainment, arts and culture (indeholder nightlife, training, arts osv (kig på på osm))
//transportaion
//education
//

part of 'package:github_client/data/jsonRepository.dart';
class queriesRtree {
  final jsonRepository repo;
  final csvRepository csvRepo;

  queriesRtree({required this.repo, required this.csvRepo});

  List<query_model> bulletQuery(String muni) {
    List<query_model> mun =[];

    var popu = csvRepo.getAllMuniPopulations();
    var munici = repo.relations.where((element) => element.name == muni).first;
    mun.add((query_model("Population: ", munici.population!)));
    mun.add(query_model("Cafes: ",repo.getCafeForMunii(muni).value));
    mun.add(query_model("Restuarants: ", repo.getRestuarantsForMuni(muni).value));
    mun.add(query_model("Train stations: ", repo.getTrainStationsForMuni(muni).value));

    return mun;


  }


  List<List<query_model>> entertainmentQueryRect(String muni1, String muni2) {
    Stopwatch stopwatch = new Stopwatch()..start();
    List<List<query_model>> modeltemp = [];
    List<List<query_model>> model = [];
    List<query_model> mun1 =[];
    List<query_model> mun2 = [];
    List<query_model> bulletmuni1 = bulletQuery(muni1);
    List<query_model> bulletmuni2 = bulletQuery(muni2);

    print("Entertainment query time: ${stopwatch.elapsed.inMilliseconds}");
   return getNighlifeForMuniRtree(muni1) + getNighlifeForMuniRtree(muni2);




    model.add(mun1);
    model.add(bulletmuni1);
    model.add(bulletmuni2);
    model.add(mun2);


    return model;
  }

  List<List<query_model>> foodQuery(String muni1, String muni2){
    Stopwatch stopwatch = new Stopwatch()..start();
    List<List<query_model>> model = [];
    List<query_model> mun1 =[];
    List<query_model> mun2 = [];
    List<query_model> bulletmuni1 = bulletQuery(muni1);
    List<query_model> bulletmuni2 = bulletQuery(muni2);

    var cafe = repo.getCafeForMunii(muni1);
    mun1.add(query_model("Cafe", cafe.value));

    cafe = repo.getCafeForMunii(muni2);
    mun2.add(query_model("Cafe", cafe.value));

    var resturants = repo.getRestuarantsForMuni(muni1);
    mun1.add(query_model("Restaurants", resturants.value));

    resturants = repo.getRestuarantsForMuni(muni2);
    mun2.add(query_model("Restaurants", resturants.value));

    model.add(mun1);
    model.add(bulletmuni1);
    model.add(bulletmuni2);
    model.add(mun2);
    print("Food query time: ${stopwatch.elapsed.inMilliseconds}");
    return model;

  }
  List<List<query_model>> transportationQuery(String muni1,String muni2) {
    Stopwatch stopwatch = new Stopwatch()..start();
    List<List<query_model>> model = [];

    List<query_model> mun1 =[];
    List<query_model> mun2 = [];
    List<query_model> bulletmuni1 = bulletQuery(muni1);
    List<query_model> bulletmuni2 = bulletQuery(muni2);

    var bus_stations = repo.getBusStationsForMuni(muni1);
    mun1.add(query_model("Bus stations", bus_stations.value));

    bus_stations = repo.getBusStationsForMuni(muni2);
    mun2.add(query_model("Bus stations", bus_stations.value));

    var train_stations = repo.getTrainStationsForMuni(muni1);
    mun1.add(query_model("Train stations", train_stations.value));

    train_stations = repo.getTrainStationsForMuni(muni2);
    mun2.add(query_model("Train stations", train_stations.value));

    model.add(mun1);
    model.add(bulletmuni1);
    model.add(bulletmuni2);
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
    var bulletMuni1 = bulletQuery(muni1);
    var bulletMuni2 = bulletQuery(muni2);
    graph1.addAll(graph2);
    graph1.addAll(graph3);
    graph1.add(bulletMuni1);
    graph1.add(bulletMuni2);

    print("Education query time: ${stopwatch.elapsed.inMilliseconds}");
    return graph1;
  }

  List<List<query_model>> getNighlifeForMuniRtree(String muni){

    Rectangle<num> boundingBox  = repo.addBoundingBoxToMuni(muni);
    var munilist = repo.getMunilist([muni]);
    List<query_model> bullet = [];
    List<query_model> mun = [];
    List<List<query_model>> model = [];

    int nightlifecounter= 0;
    int cinemacounter = 0;
    int art_centrecounter = 0;
    int community_centrecounter = 0;
    int music_venuecounter = 0;
    int cafecounter =0;
    int restaurantscounter = 0;
    int stationcounter = 0;

    for (rt.RDataRect match in repo.rTree.search(boundingBox)!) {
      switch (match.value) {
        case "bar":
          for(int j =0; munilist.length> j; j++) {
            if (jsonRepository.isPointInPolygon(LatLng(match.rect.left.toDouble(), match.rect.top.toDouble()), munilist[j])){
              nightlifecounter++;
            }}
          // nodes.add(match);
          break;
        case "pub":
          for(int j =0; munilist.length> j; j++) {
            if (jsonRepository.isPointInPolygon(LatLng(match.rect.left.toDouble(), match.rect.top.toDouble()), munilist[j])){
              nightlifecounter++;
            }}
          //nodes.add(match);
          break;
        case "nightclub":
          for(int j =0; munilist.length> j; j++) {
            if (jsonRepository.isPointInPolygon(LatLng(match.rect.left.toDouble(), match.rect.top.toDouble()), munilist[j])){
              nightlifecounter++;
            }}
          //nodes.add(match);
          break;
        case "cinema":
          for(int j =0; munilist.length> j; j++) {
            if (jsonRepository.isPointInPolygon(LatLng(match.rect.left.toDouble(), match.rect.top.toDouble()), munilist[j])){
              cinemacounter++;
            }}
          //  nodes.add(match);
          break;
        case "arts_centre":
          for(int j =0; munilist.length> j; j++) {
            if (jsonRepository.isPointInPolygon(LatLng(match.rect.left.toDouble(), match.rect.top.toDouble()), munilist[j])){
              art_centrecounter++;
            }}
          // nodes.add(match);
          break;
        case "community_centre":
          for(int j =0; munilist.length> j; j++) {
            if (jsonRepository.isPointInPolygon(LatLng(match.rect.left.toDouble(), match.rect.top.toDouble()), munilist[j])){
              community_centrecounter++;
            }}
          // nodes.add(match);
          break;
        case "music_venue":
          for(int j =0; munilist.length> j; j++) {
            if (jsonRepository.isPointInPolygon(LatLng(match.rect.left.toDouble(), match.rect.top.toDouble()), munilist[j])){
              music_venuecounter++;
            }}
          //  nodes.add(match);
          break;
        case "cafe":
          for(int j =0; munilist.length> j; j++) {
            if (jsonRepository.isPointInPolygon(LatLng(match.rect.left.toDouble(), match.rect.top.toDouble()), munilist[j])){
              cafecounter++;
            }}
          //  nodes.add(match);
          break;
        case "restaurants":
          for(int j =0; munilist.length> j; j++) {
            if (jsonRepository.isPointInPolygon(LatLng(match.rect.left.toDouble(), match.rect.top.toDouble()), munilist[j])){
              restaurantscounter++;
            }}
          //  nodes.add(match);
          break;
        case "station":
          for(int j =0; munilist.length> j; j++) {
            if (jsonRepository.isPointInPolygon(LatLng(match.rect.left.toDouble(), match.rect.top.toDouble()), munilist[j])){
              stationcounter++;
            }}
          //  nodes.add(match);
          break;
      }

    }
    mun.add(query_model("Nightlife", nightlifecounter));
    mun.add(query_model("Cinema", cinemacounter));
    mun.add(query_model("Art Centres", art_centrecounter));
    mun.add(query_model("Community Centres", community_centrecounter));
    mun.add(query_model("Music Venues", music_venuecounter));
    bullet.add(query_model("Population", (repo.relations.where((element) => element.name == muni).first).population!));
    bullet.add(query_model("Cafes:", cafecounter));
    bullet.add(query_model("Restaurants:", restaurantscounter));
    bullet.add(query_model("Train Stations:", stationcounter));
    model.add(mun);
    model.add(bullet);
      return model;

  }

}
