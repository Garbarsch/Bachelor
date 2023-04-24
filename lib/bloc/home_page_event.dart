part of 'home_page_bloc.dart';

@immutable
abstract class HomePageEvent {
  const HomePageEvent();

  @override
  List<Object> get props => [];

}
class loadpage extends HomePageEvent{

}

class SearchEvent extends HomePageEvent{}

class addMarkers extends HomePageEvent {
  final List<Marker> coords;
  final List<Polygon> muni;
  const addMarkers({required this.coords, required this.muni} );

  @override
  List<Object> get props => [coords,muni];

}
class showMunicipalities extends HomePageEvent {
  final List<LatLng> coordsMunicipalities;
  final List<Polygon> coordsMultiMuni;
  const showMunicipalities({required this.coordsMunicipalities, required this.coordsMultiMuni});


  @override
  List<Object> get props => [coordsMunicipalities];

}

class LoadDetailedGraphsEvent extends HomePageEvent{} //next page


class CompareEvent extends HomePageEvent{
  final List<Municipality> municipalities;

  const CompareEvent({required this.municipalities});


  @override
  List<Object> get props => [municipalities];
} //single graph in bottom.



class ClickPolygonEvent extends HomePageEvent{}



class AddTextBoxEvent extends HomePageEvent{

  const AddTextBoxEvent();

  @override
  List<Object> get props => [];
}

class RemoveTextBoxEvent extends HomePageEvent{

  const RemoveTextBoxEvent();

  @override
  List<Object> get props => [];


}

