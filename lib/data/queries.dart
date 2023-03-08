//food
// entertainment, arts and culture (indeholder nightlife, training, arts osv (kig på på osm))
//transportaion
//education
//

import 'package:github_client/models/query/Entertainment_model.dart';
import 'package:github_client/models/query/transportation_model.dart';

import 'jsonRepository.dart';

class queries{
  late jsonRepository repo;

  Entertainment_model entertainmentQuery(String muni){
    var nightlife = repo.getNighlifeForMuni(muni);

    var cinema = repo.getCinemaForMuni(muni);

    var art_centre = repo.getArtCentreForMuni(muni);

    var community_centre = repo.getCommunityCentreForMuni(muni);

    var music_venue = repo.getMusicVenueForMuni(muni);

   return Entertainment_model(nightlife.value,cinema.value,art_centre.value,community_centre.value,music_venue.value);

  }
  transportation_model transportationQuery(String muni){
    var bus_stations = repo.getBusStationsForMuni(muni);
    var train_stations = repo.getTrainStationsForMuni(muni);
    return transportation_model(bus_stations.value, train_stations.value);
  }



}