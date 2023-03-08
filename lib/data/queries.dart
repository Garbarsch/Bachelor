//food
// entertainment, arts and culture (indeholder nightlife, training, arts osv (kig på på osm))
//transportaion
//education
//

part of 'package:github_client/data/jsonRepository.dart';
class queries {
  jsonRepository repo;

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

  List<query_model> transportationQuery(String muni) {
    List<query_model> model = [];
    var bus_stations = repo.getBusStationsForMuni(muni);
    model.add(query_model("Bus stations", bus_stations.value));

    var train_stations = repo.getTrainStationsForMuni(muni);
    model.add(query_model("Train stations", train_stations.value));

    return model;
  }

  queries({required this.repo});


}
