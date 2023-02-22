//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:multiselect/multiselect.dart';
import 'package:searchfield/searchfield.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  List<String> choices = ['Subway','Train','Cafe','Education','Bars'];
  List<String> selecteChoices = [];
  MapController _mapController = MapController();
  late List<MapModel> _mapData;
  @override
  void initState(){
    _mapData = _getMapData();
    //_shapeSource = MapShapeSource.asset('assets/municipalitiesDK.json',
   // shapeDataField: 'label_dk',
    //dataCount: _mapData.length,
    //primaryValueMapper: (int index) => _mapData[index].kommune);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Padding(
          padding: EdgeInsets.fromLTRB(0,0, 0,0),
          child: Stack(
          children: [ Container(height:35, width: MediaQuery.of(context).size.width ,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(width: 45.0, color: Colors.black),

                ),
                child: const Text('  Danish Municipalities',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25, height:1.5)),

              )),Container(height: MediaQuery.of(context).size.width ), Positioned(top: 55, bottom: 10, left: 10,child: Container(height: MediaQuery.of(context).size.width -500, width: MediaQuery.of(context).size.width/2,
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
            layers: [
              TileLayerOptions(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: 'dev.fleaflet.flutter_map.example'
              ),
      ], )),),
            Container(height: MediaQuery.of(context).size.width ), Positioned(top: 45, bottom: 10, left: MediaQuery.of(context).size.width -300, right: 150 ,child: Container(height: MediaQuery.of(context).size.width -500, width: MediaQuery.of(context).size.width/2,
              child: SearchField(
                  suggestions: _mapData.map((e) =>
                      SearchFieldListItem(e.kommune)).toList(),
                  suggestionState: Suggestion.expand,
                  textInputAction: TextInputAction.next,
                  hint: 'Search on Municipality ',
                  hasOverlay: false,
                  searchStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(0.8),
                  )),

                  ),),Container(height: MediaQuery.of(context).size.width ), Positioned(top: 400, bottom: 10, left: MediaQuery.of(context).size.width -300, right: 150 ,child: Container(height: MediaQuery.of(context).size.width -500, width: MediaQuery.of(context).size.width/2,
              child: DropDownMultiSelect(
                options: choices,
                selectedValues: selecteChoices,
                onChanged: (value) {
                  setState(() {
                    selecteChoices = value;
                  });
                },
                whenEmpty: 'Choose filter',
              ),

            ),)





          ])));
  }
}


List<MapModel> _getMapData(){
  return <MapModel>[
    MapModel('Sønderborg'),
    MapModel('København'),
    MapModel('Århus'),
    MapModel('Aalborg'),
    MapModel('Odense'),
    MapModel('Vejle'),
    MapModel('Esbjerg'),
    MapModel('Frederiksberg'),
    MapModel('Randers'),
    MapModel('Viborg'),
    MapModel('Silkeborg'),
    MapModel('Kolding'),
    MapModel('Horsens'),
    MapModel('Herning'),
    MapModel('Roskilde'),
    MapModel('Næstved'),
    MapModel('Slagelse'),
    MapModel('Gentofte'),
    MapModel('Holbæk'),
    MapModel('Gladsaxe'),
    MapModel('Hjørring'),
    MapModel('Skanderborg'),
    MapModel('Helsingør'),
    MapModel('Køge'),
    MapModel('Guldborgsund'),
    MapModel('Frederikshavn'),
    MapModel('Holstebro'),
    MapModel('Svendborg'),
    MapModel('Aabenraa'),
    MapModel('Rudersdal'),
    MapModel('Lyngby-Taastrup'),
    MapModel('Faaborg-Midtfyn'),
    MapModel('Hillerød'),
    MapModel('Fredericia'),
    MapModel('Greve'),
    MapModel('Varde'),
    MapModel('Ballerup'),
    MapModel('Kalundborg'),
    MapModel('Favrskov'),
    MapModel('Hedensted'),
    MapModel('Frederikssund'),
    MapModel('Skive'),
    MapModel('Vordingborg'),
    MapModel('Egedal'),
    MapModel('Syddjurs'),
    MapModel('Thisted'),
    MapModel('Vejen'),
    MapModel('Tårnby'),
    MapModel('Mariagerfjord'),
    MapModel('Ikast-Brande'),
    MapModel('Rødovre'),
    MapModel('Furesø'),
    MapModel('Fredensborg'),
    MapModel('Gribskov'),
    MapModel('Assens'),
    MapModel('Lolland'),
    MapModel('Bornholm'),
    MapModel('Middelfart'),
    MapModel('Jammerbugt'),
    MapModel('Tønder'),
    MapModel('Norddjurs'),
    MapModel('Faxe'),
    MapModel('Vesthimmerland'),
    MapModel('Brønderslev-Dronninglund'),
    MapModel('Brøndby'),
    MapModel('Ringsted'),
    MapModel('Odsherred'),
    MapModel('Nyborg'),
    MapModel('Halsnæs'),
    MapModel('Rebild'),
    MapModel('Sorø'),
    MapModel('Nordfyns'),
    MapModel('Herlev'),
    MapModel('Lejre'),
    MapModel('Albertslund'),
    MapModel('Billund'),
    MapModel('Allerød'),
    MapModel('Hørsholm'),
    MapModel('Kerteminde'),
    MapModel('Solrød'),
    MapModel('Odder'),
    MapModel('Ishøj'),
    MapModel('Stevns'),
    MapModel('Glostrup'),
    MapModel('Struer'),
    MapModel('Morsø'),
    MapModel('Lemvig'),
    MapModel('Vallensbæk'),
    MapModel('Dragør'),
    MapModel('Langeland'),
    MapModel('Ærø'),
    MapModel('Samsø'),
    MapModel('Fanø'),
    MapModel('Læsø'),
    MapModel('Ringkøbing-Skjern'),
    MapModel('Haderslev'),
    MapModel('Høje-Taastrup'),


  ];
}
class MapModel{
  MapModel(this.kommune);
  late String kommune;
}

