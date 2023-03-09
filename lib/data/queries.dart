//food
// entertainment, arts and culture (indeholder nightlife, training, arts osv (kig på på osm))
//transportaion
//education
//

part of 'package:github_client/data/jsonRepository.dart';
class queries {
  jsonRepository repo;

  List<List<query_model>> entertainmentQuery(String muni1, String muni2) {
    List<List<query_model>> model = [];
    List<query_model> mun1 =[];
    List<query_model> mun2 = [];

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
    model.add(mun2);

    return model;
  }

  List<List<query_model>> foodQuery(String muni1, String muni2){
    List<List<query_model>> model = [];
    List<query_model> mun1 =[];
    List<query_model> mun2 = [];

    var cafe = repo.getCafeForMunii(muni1);
    mun1.add(query_model("Cafe", cafe.value));

    cafe = repo.getCafeForMunii(muni2);
    mun2.add(query_model("Cafe", cafe.value));

    var resturants = repo.getRestuarantsForMuni(muni1);
    mun1.add(query_model("Restaurants", resturants.value));

    resturants = repo.getRestuarantsForMuni(muni2);
    mun2.add(query_model("Restaurants", resturants.value));

    model.add(mun1);
    model.add(mun2);
    return model;

  }
  List<List<query_model>> transportationQuery(String muni1,String muni2) {
    List<List<query_model>> model = [];

    List<query_model> mun1 =[];
    List<query_model> mun2 = [];

    var bus_stations = repo.getBusStationsForMuni(muni1);
    mun1.add(query_model("Bus stations", bus_stations.value));

    bus_stations = repo.getBusStationsForMuni(muni2);
    mun2.add(query_model("Bus stations", bus_stations.value));

    var train_stations = repo.getTrainStationsForMuni(muni1);
    mun1.add(query_model("Train stations", train_stations.value));

    train_stations = repo.getTrainStationsForMuni(muni2);
    mun2.add(query_model("Train stations", train_stations.value));

    model.add(mun1);
    model.add(mun2);


    return model;
  }

  queries({required this.repo});


}
