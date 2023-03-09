import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:github_client/bloc/graph_page_bloc.dart';
import 'package:github_client/bloc/home_page_bloc.dart';
import 'package:github_client/data/csvRepository.dart';
import 'package:github_client/data/jsonRepository.dart';
import 'package:github_client/models/municipality_model.dart';
import 'package:github_client/ui/graph_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:multiselect/multiselect.dart';
import 'package:searchfield/searchfield.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;
import 'package:tuple/tuple.dart';



class MyHomePage extends StatelessWidget {
  List<String> choices = ['Restaurants','Bus Stop','Cinemas', 'Dentists','Clinics','Muni'];
  List<String> selecteChoices = [];
  List<Marker> markers = [];
  List<Polygon> polyMuni = [];
  jsonRepository repo;
  csvRepository csvRepo;

  static MaterialPageRoute<void> route(BuildContext context, jsonRepository repo, csvRepository csvRepo) => MaterialPageRoute(
    builder: (_) => MyHomePage(blocContext: context, repo: repo, csvRepo: csvRepo,),
  );

  int temp = 0;
    MyHomePage({
    super.key,
    required this.repo, required this.csvRepo, required BuildContext blocContext,
    //required this.shapeSource, required this.mapData,
  });



  final List<Municipality> mapData =  Municipality(name: 'h').getList;
  final MapController _mapController = MapController();

  final MapShapeSource shapeSource =
  MapShapeSource.asset('assets/municipalitiesDK.json',
      shapeDataField: 'label_dk',
      dataCount: defaultList.length,
      primaryValueMapper: (int index) => defaultList[index].name);

  //Have to create a static member to initialize shapeSource.
  static List<Municipality> get defaultList => Municipality(name: 'h').getList;

  @override
  Widget build(BuildContext context) {


    return Scaffold(
        body: Padding(
            padding: EdgeInsets.fromLTRB(0,0, 0,0),
            child: Stack(
                children: [ BlocBuilder<HomePageBloc, HomePageState>(
                  builder: (context,state) {
    print(state);
    if (state is HomePageInitial) { //HOMEPAGE
    return const CircularProgressIndicator(color: Colors.blue);
    }
    if (state is homeLoaded) {
      for (int index = 0;
      index < state.coords.length; {
        print("hallo"),
        markers.add(
            Marker(
              point: state.coords[index],
              width: 80,
              height: 80,
              builder: (context) =>
                  Icon(Icons.circle, color: Colors.red,
                    size: 4,),
            )), index++
      });
      // if(state is homeLoadedMunicipalities){

      print("Carl");
      print(state.coordsMuni);
      polyMuni.add(
          Polygon(points: state.coordsMuni, color: Colors.blue,)
      );

      print("halloklam");
      print(polyMuni.first.points);
      //LOADEDGRAPH

      print("HALLO2");
    }

                     else {
                      print("HALLObøsse");
//ELSE
                      return const Text('Something went wrong');
                    }
    return Positioned(top: 55, bottom: 10, left: 10,child: Container(height: MediaQuery.of(context).size.width -500, width: MediaQuery.of(context).size.width/2,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: LatLng(56, 10),
            swPanBoundary:LatLng(54, 8) ,
            nePanBoundary: LatLng(60, 13),
            zoom: 6,

            // maxBounds: LatLngBounds(LatLng(56, 10),LatLng(76, 15)),
          ),
          nonRotatedChildren: [
            AttributionWidget.defaultWidget(
              source: '',
              onSourceTapped: null,
            ),
          ],
          children: [
            TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'dev.fleaflet.flutter_map.example'
            ),
            PolygonLayer(
                polygons: state.coordsMultiMuni
            ),
            MarkerLayer(

                markers:  markers


            ),
          ],)),);
                  },
                ),

                  Container(height:35, width: MediaQuery.of(context).size.width ,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        border: Border.all(width: 45.0, color: Colors.black),

                      ),
                      child: const Text('  Danish Municipalities',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25, height:1.5)),

                    )),
                  Container(height: MediaQuery.of(context).size.width ), Positioned(top: 45, bottom: 10, left: MediaQuery.of(context).size.width -300, right: 150 ,child: Container(height: MediaQuery.of(context).size.width -500, width: MediaQuery.of(context).size.width/2,
                    child: SearchField(
                        suggestions: repo.relations.map((e) =>
                            SearchFieldListItem(e.name!)).toList(),
                        suggestionState: Suggestion.expand,
                        textInputAction: TextInputAction.next,
                        hint: 'Search on Municipality ',
                        onSubmit: (value) {
                          print(value);
                          context.read<HomePageBloc>().add(
                              showMunicipalities(coordsMunicipalities: repo.getMuniBoundary(value),coordsMultiMuni: repo.getMuniPolygons([value])));
                        },
                        hasOverlay: false,
                        searchStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.8),
                        )),

                  ),),Container(height: MediaQuery.of(context).size.width ), Positioned(top: 400, bottom: 10, left: MediaQuery.of(context).size.width -300, right: 150 ,child: Container(height: MediaQuery.of(context).size.width -500, width: MediaQuery.of(context).size.width/2,
                    child: DropDownMultiSelect(
                      options: choices,
                      selectedValues: selecteChoices,
                      onChanged: (List<String> value) {
                        context.read<HomePageBloc>().add(
                            addMarkers(coords: repo.getCoords(value)));
                      },


                        whenEmpty:
                        'Choose filter',


                    ),

                  ),), Positioned(top: 400, bottom: MediaQuery.of(context).size.height-450, left: MediaQuery.of(context).size.width -300, right: 100, child: SizedBox( width: 50,height:
                  100,
                    child: ElevatedButton(

                      child: Text('Compare', style: TextStyle(fontSize: 20.0),),
                      onPressed: () {Navigator.of(context).push(MyGraphPage.route(context, repo, csvRepo))
                      ;
                        print(context.read<GraphPageBloc>().state);},

                    ),

                  ),)





                ],)));
  }
}

