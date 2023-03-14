//food
// entertainment, arts and culture (indeholder nightlife, training, arts osv (kig på på osm))
//transportaion
//education
//

part of 'package:github_client/data/jsonRepository.dart';
class queries {
  final jsonRepository repo;
  final csvRepository csvRepo;

  queries({required this.repo, required this.csvRepo});

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

  List<List<query_model>> entertainmentQuery(String muni1, String muni2) {
    List<List<query_model>> model = [];
    List<query_model> mun1 =[];
    List<query_model> mun2 = [];
    List<query_model> bulletmuni1 = bulletQuery(muni1);
    List<query_model> bulletmuni2 = bulletQuery(muni2);


    var nightlife = repo.getNighlifeForMuni(muni1);
    mun1.add(query_model("Nightlife", nightlife.value));

    nightlife = repo.getNighlifeForMuni(muni2);
    mun2.add(query_model("Nightlife", nightlife.value));

    var cinema = repo.getCinemaForMuni(muni1);
    mun1.add(query_model("Cinema", cinema.value));

    cinema = repo.getCinemaForMuni(muni2);
    mun2.add(query_model("Cinema", cinema.value));


    var art_centre = repo.getArtCentreForMuni(muni1);
    mun1.add(query_model("Art Centre", art_centre.value));

    art_centre = repo.getArtCentreForMuni(muni2);
    mun1.add(query_model("Art Centre", art_centre.value));


    var community_centre = repo.getCommunityCentreForMuni(muni1);
    mun1.add(query_model("Community Centre", community_centre.value));

    community_centre = repo.getCommunityCentreForMuni(muni2);
    mun2.add(query_model("Community Centre", community_centre.value));


    var music_venue = repo.getMusicVenueForMuni(muni1);
    mun1.add(query_model("Music Venues", music_venue.value));

    music_venue = repo.getMusicVenueForMuni(muni2);
    mun2.add(query_model("Music Venues", music_venue.value));

    model.add(mun1);
    model.add(bulletmuni1);
    model.add(bulletmuni2);
    model.add(mun2);

    return model;
  }

  List<List<query_model>> foodQuery(String muni1, String muni2){
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
    return model;

  }
  List<List<query_model>> transportationQuery(String muni1,String muni2) {
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
      tempInBoth = List<query_model>.from(tempQueryList2.where((element) => tempQueryList1.contains(element)));
      tempInBoth.forEach((element) {
        tempQueryList2.remove(element);
        tempQueryList1.remove(element);
      });


    if(tempQueryList1.length > tempQueryList2.length){
      tempQueryList1.addAll(tempInBoth);
      tempInBoth.addAll(tempQueryList2);
      return [tempQueryList1,tempInBoth];
    }else{
      tempQueryList2.addAll(tempInBoth);
      tempInBoth.addAll(tempQueryList1);
      return [tempQueryList2,tempInBoth];
    }
  }

  List<List<query_model>> educationQuery(String muni1, String muni2){
      var graph1 = educationTopLayerSchoolsPercentage(muni1, muni2);
      var graph2 = educationOfferPercentageQuery(muni1, muni2);
      var graph3 = educationBarStats(muni1, muni2);
      var bulletMuni1 = bulletQuery(muni1);
      var bulletMuni2 = bulletQuery(muni2);
      graph1.addAll(graph2);
      graph1.addAll(graph3);
      graph1.add(bulletMuni1);
      graph1.add(bulletMuni2);

      return graph1;
  }

}
