import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../models/municipality_model.dart';

part 'home_page_event.dart';
part 'home_page_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  HomePageBloc() : super(HomePageInitial()) {
    //find muni on map
    on<SearchEvent>(
            (event, emit) async {}
    );

    //next page
    on<LoadDetailedGraphsEvent>(
            (event, emit) async {}
    );

    //compare two or more muni
    on<CompareEvent>(
            (event, emit) async {
              await Future<void>.delayed(const Duration(seconds: 1));
              emit(
                  homeLoadedGraph(municipalities: List.from(event.municipalities)
                  )
              );
            }
    );

    //click and see name on map
    on<ClickPolygonEvent>(
            (event, emit) async {}
    );

    on<AddTextBoxEvent>(
            (event, emit) async {
                await Future<void>.delayed(const Duration(seconds: 1));
                emit(
                    homeLoadedGraph(municipalities: List.from(state.props),)
                );
            }
    );

    on<RemoveTextBoxEvent>(
            (event, emit) async {
                await Future<void>.delayed(const Duration(seconds: 1));
                emit(
                    homeLoadedGraph(municipalities: List.from(state.props),)
                );
            }
    );

  }
}
