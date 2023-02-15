part of 'home_page_bloc.dart';

@immutable
abstract class HomePageEvent {
  const HomePageEvent();

  @override
  List<Object> get props => [];

}

class SearchEvent extends HomePageEvent{}



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

