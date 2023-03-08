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

  final List<Munidata> muni;
  final List<query_model> querymodel;
  const graphLoaded({required this.muni, required this.querymodel});

  @override
  List<Object> get props => [muni,querymodel];

}