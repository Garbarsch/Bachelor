part of 'graph_page_bloc.dart';


@immutable
abstract class GraphPageState extends Equatable{
  const GraphPageState();

  @override
  List<Object> get props => [];
}


class GraphPageInitial extends GraphPageState {

  const GraphPageInitial();
  @override
  List<Object> get props => [];
}

class graphLoaded extends GraphPageState{

  final List<String> muni;

  const graphLoaded({required this.muni});

  @override
  List<Object> get props => [muni];

}