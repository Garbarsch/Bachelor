import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart';
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
          emit(const graphLoaded(muni: []));
          // emit(const homeLoadedMunicipalities(coordsMunicipalities: []));
        }
    );

  }
  }