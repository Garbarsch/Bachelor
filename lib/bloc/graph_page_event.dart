part of 'graph_page_bloc.dart';

@immutable
abstract class GraphPageEvent {
  const GraphPageEvent();

  @override
  List<Object> get props => [];

}
class loadGraphPage extends GraphPageEvent{

}
class updateGrahpQuery extends GraphPageEvent{
  final query_model model;
  const updateGrahpQuery({required this.model});
  @override
  List<Object> get props => [model];
}
class updateGraph extends GraphPageEvent {
  final List<Munidata> data;
  final List<query_model> querymodel;
  const updateGraph({required this.data, required this.querymodel});

  @override
  List<Object> get props => [data,querymodel];

}