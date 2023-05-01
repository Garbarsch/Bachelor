import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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



class MyHomePage extends StatelessWidget {
  List<String> choices = ['Cafes','Restaurants','Cinemas','Art Centres','Community Centres','Music Venues','Bars','Nightclubs','Bus Stations','Train Stations'];
  List<String> selecteChoices = [];
  List<Marker> markers = [];
  List<Polygon> polyMuni = [];
  jsonRepository repo;
  csvRepository csvRepo;
  String? muni;

  static MaterialPageRoute<void> route(BuildContext context, jsonRepository repo, csvRepository csvRepo) => MaterialPageRoute(
    builder: (_) => MyHomePage(blocContext: context, repo: repo, csvRepo: csvRepo,),
  );
  late queriesGrid query = queriesGrid(repo, csvRepo);

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
    //print(state);
    if (state is HomePageInitial) { //HOMEPAGE
    return const CircularProgressIndicator(color: Colors.blue);
    }
    if (state is homeLoaded) {
     polyMuni = state.coordsMultiMuni;

    }

                     else {
                      //print("HALLObøsse");
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
                polygons: polyMuni
            ),
            MarkerLayer(

                markers:  state.coords


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

                    )),Container(height:700, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-400,200, 0,50),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(width: 1.0, color: Colors.grey),

                        ),
                        child: const Text.rich(
                          TextSpan(
                            text: '         ',
                            style: TextStyle(fontSize: 25, height:1.5),
                            children: <TextSpan>[
                              TextSpan(
                                  text: 'Show Amenities',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25, height:1.5,
                                    decoration: TextDecoration.underline,
                                  )),
                              // can add more TextSpans here...
                            ],
                          ),
                        ),

                      )),Container(height:700, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-575,100, 0,50),
              child:  const Text.rich(
                TextSpan(
                  text: '.',
                  style: TextStyle(fontSize: 100, height:1.5,color: Colors.purple),

                  children: <TextSpan>[
                    TextSpan(
                        text: 'Cafes',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15, height:1.5,
                        )),
                    // can add more TextSpans here...
                  ],
                ),
              ),
            ),Container(height:700, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-575,125, 0,50),
                    child:  const Text.rich(
                      TextSpan(
                        text: '.',
                        style: TextStyle(fontSize: 100, height:1.5,color: Colors.purpleAccent),

                        children: <TextSpan>[
                          TextSpan(
                              text: 'Restaurants',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15, height:1.5,
                              )),
                          // can add more TextSpans here...
                        ],
                      ),
                    ),
                  ),Container(height:700, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-575,150, 0,50),
                    child:  const Text.rich(
                      TextSpan(
                        text: '.',
                        style: TextStyle(fontSize: 100, height:1.5,color: Colors.pink),

                        children: <TextSpan>[
                          TextSpan(
                              text: 'Cinemas',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15, height:1.5,
                              )),
                          // can add more TextSpans here...
                        ],
                      ),
                    ),
                  ),Container(height:700, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-575,175, 0,50),
                    child:  const Text.rich(
                      TextSpan(
                        text: '.',
                        style: TextStyle(fontSize: 100, height:1.5,color: Colors.black),

                        children: <TextSpan>[
                          TextSpan(
                              text: 'Art Centres',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15, height:1.5,
                              )),
                          // can add more TextSpans here...
                        ],
                      ),
                    ),
                  ),Container(height:700, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-575,200, 0,50),
                    child:  const Text.rich(
                      TextSpan(
                        text: '.',
                        style: TextStyle(fontSize: 100, height:1.5,color: Colors.black45),

                        children: <TextSpan>[
                          TextSpan(
                              text: 'Community Centres',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15, height:1.5,
                              )),
                          // can add more TextSpans here...
                        ],
                      ),
                    ),
                  ),Container(height:700, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-575,225, 0,50),
                    child:  const Text.rich(
                      TextSpan(
                        text: '.',
                        style: TextStyle(fontSize: 100, height:1.5,color: Colors.blueGrey),

                        children: <TextSpan>[
                          TextSpan(
                              text: 'Music Venues',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15, height:1.5,
                              )),
                          // can add more TextSpans here...
                        ],
                      ),
                    ),
                  ),Container(height:700, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-575,250, 0,50),
                    child:  const Text.rich(
                      TextSpan(
                        text: '.',
                        style: TextStyle(fontSize: 100, height:1.5,color: Colors.blue),

                        children: <TextSpan>[
                          TextSpan(
                              text: 'Bars',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15, height:1.5,
                              )),
                          // can add more TextSpans here...
                        ],
                      ),
                    ),
                  ),Container(height:700, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-575,275, 0,50),
                    child:  const Text.rich(
                      TextSpan(
                        text: '.',
                        style: TextStyle(fontSize: 100, height:1.5,color: Colors.lightBlueAccent),

                        children: <TextSpan>[
                          TextSpan(
                              text: 'Nightclubs',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15, height:1.5,
                              )),
                          // can add more TextSpans here...
                        ],
                      ),
                    ),
                  ),Container(height:700, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-575,300, 0,50),
                    child:  const Text.rich(
                      TextSpan(
                        text: '.',
                        style: TextStyle(fontSize: 100, height:1.5,color: Colors.redAccent),

                        children: <TextSpan>[
                          TextSpan(
                              text: 'Bus Stations',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15, height:1.5,
                              )),
                          // can add more TextSpans here...
                        ],
                      ),
                    ),
                  ),Container(height:700, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-575,325, 0,50),
                    child:  const Text.rich(
                      TextSpan(
                        text: '.',
                        style: TextStyle(fontSize: 100, height:1.5,color: Colors.red),

                        children: <TextSpan>[
                          TextSpan(
                              text: 'Train Stations',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15, height:1.5,
                              )),
                          // can add more TextSpans here...
                        ],
                      ),
                    ),
                  ),Container(height:600, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-300,240, 0,0),
                      child: const Text("Denmark",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25, height:1.5))

                  ),Container(height:600, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-260,275, 0,0),
                      child: const Text("Or",style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25, height:1.5))

                      ),
                  Container(height:600, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-320,377, 69,0),child: const Text("Hint: Leave searchbar empty to show all municipalities",style: TextStyle(color: Colors.grey, fontSize: 12, height:1.5)), ),
                  Container(height:600, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-320,325, 69,0),
                    child: SearchField(
                        suggestions: repo.relations.map((e) =>
                            SearchFieldListItem(e.name!)).toList(),
                        suggestionState: Suggestion.expand,
                        textInputAction: TextInputAction.next,
                        hint: 'Search on a municipality ',
                        onSubmit: (value) {
                          if(value == ""){
                            context.read<HomePageBloc>().add(
                                const showMunicipalities(coordsMunicipalities: [],coordsMultiMuni: []));
                          }
                          context.read<HomePageBloc>().add(
                              showMunicipalities(coordsMunicipalities: repo.getMuniBoundary(value)!,coordsMultiMuni: repo.getMuniPolygons([value])));
                        },
                        hasOverlay: true,
                        searchStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.8),
                        )),),
                  Container(height:700, width: MediaQuery.of(context).size.width -100,padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-340,250, 50,0),
                    child: DropDownMultiSelect(
                      options: choices,
                      selectedValues: selecteChoices,
                      onChanged: (List<String> value) {
                        context.read<HomePageBloc>().add(
                            addMarkers(coords: repo.getMarkers(value,polyMuni),muni: polyMuni));
                      },


                        whenEmpty:
                        'Choose amenities',


                    ),
                  ),

                  Positioned(top: 50, left: MediaQuery.of(context).size.width -225, right: 25, child: Container( width: 50,height:
                  50,
                    child: ElevatedButton(

                      child: const Text('Complete Statistics ', style: TextStyle(fontSize: 17.0),),
                      onPressed: () {Navigator.of(context).push(MyGraphPage.route(context, repo, csvRepo))
                      ;},


                    ),

                  ),)





                ],)));
  }
}

