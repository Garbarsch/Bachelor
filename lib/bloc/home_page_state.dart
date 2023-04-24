part of 'home_page_bloc.dart';

@immutable
abstract class HomePageState extends Equatable{
  const HomePageState();

  @override
  List<Object> get props => [];
}


class HomePageInitial extends HomePageState {

  const HomePageInitial();
  @override
  List<Object> get props => [];
}
class homeLoaded extends HomePageState{

  final List<Marker> coords;
  final List<LatLng> coordsMuni;
  final List<Polygon> coordsMultiMuni;

  const homeLoaded({required this.coords, required this.coordsMuni, required this.coordsMultiMuni});

  @override
  List<Object> get props => [coords,coordsMuni,coordsMultiMuni];

}
class homeLoadedMunicipalities extends HomePageState{

  final List<LatLng> coordsMunicipalities;

  const homeLoadedMunicipalities({required this.coordsMunicipalities});

  @override
  List<Object> get props => [coordsMunicipalities];
}

class homeLoadede extends HomePageState{

  final List<Municipality> municipalities;

  const homeLoadede({required this.municipalities});

  //har en final graph ting her.
  @override
  List<Object> get props => [municipalities];

}