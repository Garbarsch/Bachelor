part of 'graph_page_bloc.dart';

@immutable
abstract class GraphPageEvent {
  const GraphPageEvent();

  @override
  List<Object> get props => [];

}
class loadGraphPage extends GraphPageEvent{

}
class updateGraph extends GraphPageEvent {
  final List<Munidata> data;
  const updateGraph({required this.data});

  @override
  List<Object> get props => [data];

}