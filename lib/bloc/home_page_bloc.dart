import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

import '../models/municipality_model.dart';

part 'home_page_event.dart';
part 'home_page_state.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  HomePageBloc() : super(HomePageInitial()) {
    //find muni on map
    on<loadpage>(
            (event, emit) async {
              await Future<void>.delayed(const Duration(seconds: 1));
              emit(const homeLoaded(coords: [], coordsMuni: [], coordsMultiMuni: []));
             // emit(const homeLoadedMunicipalities(coordsMunicipalities: []));
            }
    );
    on<addMarkers>(
            (event, emit) async {
          if(state is homeLoaded){
            final state = this.state as homeLoaded;
            emit(
                homeLoaded(
                  coords: List.from(state.coords)..addAll(event.coords
                  ), coordsMuni: [], coordsMultiMuni: []

                )
            );
          }
        }
    );
    on<showMunicipalities>(
            (event, emit) async {
          if(state is homeLoaded){
            final state = this.state as homeLoaded;
            emit(
                homeLoaded(
                  coordsMuni: List.from(state.coordsMuni)..addAll(event.coordsMunicipalities), coords:[] ,coordsMultiMuni: List.from(state.coordsMultiMuni)..addAll(event.coordsMultiMuni)

                )
            );
          }
        }
    );

    //next page
    on<LoadDetailedGraphsEvent>(
            (event, emit) async {}
    );

    //compare two or more muni
    on<CompareEvent>(
            (event, emit) async {
              await Future<void>.delayed(const Duration(seconds: 1));
            //  emit(
                 // homeLoaded(municipalities: List.from(event.municipalities),
             //     )
             // );
            }
    );

    //click and see name on map
    on<ClickPolygonEvent>(
            (event, emit) async {}
    );


    //on<AddTextBoxEvent>(
      //      (event, emit) async {
       //         await Future<void>.delayed(const Duration(seconds: 1));
        //        emit(
          //          homeLoadedGraph(municipalities: List.from(state.props),)
           //     );
           // }
   // );

//    on<RemoveTextBoxEvent>(
  //          (event, emit) async {
    //            await Future<void>.delayed(const Duration(seconds: 1));
      //          emit(
        //            homeLoadedGraph(municipalities: List.from(state.props),)
          //      );
         //   }
   // );

  }
}
