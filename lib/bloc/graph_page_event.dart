part of 'graph_page_bloc.dart';

@immutable
abstract class GraphPageEvent {
  const GraphPageEvent();

  @override
  List<Object> get props => [];

}
class loadGraphPage extends GraphPageEvent{

}