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
class homeLoadedMarkers extends HomePageState{

  final List<LatLng> coords;

  const homeLoadedMarkers({required this.coords});

  @override
  List<Object> get props => [coords];
}

class homeLoaded extends HomePageState{

  final List<Municipality> municipalities;

  const homeLoaded({required this.municipalities});

  //har en final graph ting her.
  @override
  List<Object> get props => [municipalities];

}