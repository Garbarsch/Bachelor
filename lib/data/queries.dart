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

  List<query_model> entertainmentQuery(String muni) {
    List<query_model> model = [];

    var nightlife = repo.getNighlifeForMuni(muni);
    model.add(query_model("Nightlife", nightlife.value));

    var cinema = repo.getCinemaForMuni(muni);
    model.add(query_model("Cinema", cinema.value));


    var art_centre = repo.getArtCentreForMuni(muni);
    model.add(query_model("Art Centre", art_centre.value));


    var community_centre = repo.getCommunityCentreForMuni(muni);
    model.add(query_model("Community Centre", community_centre.value));


    var music_venue = repo.getMusicVenueForMuni(muni);
    model.add(query_model("Music Venues", music_venue.value));


    return model;
  }

  List<query_model> foodQuery(String muni){
    List<query_model> model = [];
    var cafe = repo.getCafeForMunii(muni);
    model.add(query_model("Cafe", cafe.value));
    var resturants = repo.getRestuarantsForMuni(muni);
    model.add(query_model("Restaurants", resturants.value));

    return model;
  }

  List<query_model> transportationQuery(String muni) {
    List<query_model> model = [];
    var bus_stations = repo.getBusStationsForMuni(muni);
    model.add(query_model("Bus stations", bus_stations.value));

    var train_stations = repo.getTrainStationsForMuni(muni);
    model.add(query_model("Train stations", train_stations.value));

    return model;
  }

  List<query_model> educationOfferPercentageQuery(String muni1){
    print("EDUCATION OFFER PERCENTAGE QUERY");

    String muni2 = "Gladsaxe Kommune";
    List<List<LatLng>> muni1Bound = repo.getSingleMuniBoundary(muni1);
    List<List<LatLng>> muni2Bound = repo.getSingleMuniBoundary(muni2);
    int totalEducationOptions = csvRepo.getAllEducationOptions().length;


    var percentageMuni1 = csvRepo.getAmountEducationsInMuni(muni1, muni1Bound);
    var percentageMuni2 = csvRepo.getAmountEducationsInMuni(muni2, muni2Bound);

    print(totalEducationOptions);
    print(percentageMuni1);
    print(percentageMuni2);
    print("\n");

    return [];
  }



}
