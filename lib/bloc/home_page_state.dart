part of 'home_page_bloc.dart';

@immutable
abstract class HomePageState extends Equatable{
  const HomePageState();

  @override
  List<Object> get props => [];
}


class HomePageInitial extends HomePageState {}

class homeLoadedGraph extends HomePageState{

  final List<Municipality> municipalities;

  const homeLoadedGraph({required this.municipalities});

  //har en final graph ting her.
  @override
  List<Object> get props => [municipalities];

}