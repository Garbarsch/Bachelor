import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:github_client/data/jsonRepository.dart';
import 'package:github_client/models/query/query_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

import '../models/municipality_model.dart';

part 'graph_page_event.dart';
part 'graph_page_state.dart';

class GraphPageBloc extends Bloc<GraphPageEvent, GraphPageState> {
  GraphPageBloc() : super(GraphPageInitial()) {
    on<loadGraphPage>(
            (event, emit) async {
          await Future<void>.delayed(const Duration(seconds: 1));
          emit(const graphLoaded(muni: [], querymodel: [], type: ""));
          // emit(const homeLoadedMunicipalities(coordsMunicipalities: []));
        }
    );
    on<updateGraph>(
            (event, emit) async {
          if(state is graphLoaded){
            final state = this.state as graphLoaded;
            emit(
                graphLoaded(
                    muni: List.from(state.muni)..addAll(event.data),
                        querymodel: (event.querymodel),
                        type: event.type
                )
            );
          }
        }
    );

  }
  }