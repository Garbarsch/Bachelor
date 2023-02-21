import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_client/bloc/home_page_bloc.dart';
import 'package:github_client/models/municipality_model.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:searchfield/searchfield.dart';


class MyHomePage extends StatelessWidget{

  MyHomePage({
    super.key,
    //required this.shapeSource, required this.mapData,
  });

  final List<Municipality> mapData =  Municipality(name: 'h').getList;

  final MapShapeSource shapeSource =
  MapShapeSource.asset('assets/municipalitiesDK.json',
      shapeDataField: 'label_dk',
      dataCount: defaultList.length,
      primaryValueMapper: (int index) => defaultList[index].name);

  //Have to create a static member to initialize shapeSource.
  static List<Municipality> get defaultList => Municipality(name: 'h').getList;

  List<List<dynamic>> _data = [];

  void _loadCSV() async {
    final _rawData = await rootBundle.loadString("assets/mycsv.csv");
    List<List<dynamic>> _listData =
        const CsvToListConverter().convert(_rawData);
      _data = _listData;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            children:[ BlocBuilder<HomePageBloc, HomePageState>(
            builder: (context,state) {
              if (state is HomePageInitial) { //HOMEPAGE
                return Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                );

              }
              if (state is homeLoadedGraph) { //LOADEDGRAPH
                return const CircularProgressIndicator(color: Colors.orange,);
              } //ELSE
              return const CircularProgressIndicator(color: Colors.orange,);
            },
            ),
              Container(height:35, width: MediaQuery.of(context).size.width ,

                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(width: 45.0, color: Colors.black),
                  ),
                  child: Text('  Danish Municipalities',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25, height:1.5)),
                )),
              Row(
                children: <Widget> [

              Container(height: 250, width: 150,
                padding: EdgeInsets.fromLTRB(20, 20,0, 0),
                child: SearchField(
    suggestions: mapData.map((e) =>
    SearchFieldListItem(e.name)).toList(),
    suggestionState: Suggestion.expand,
    textInputAction: TextInputAction.next,
    hint: 'Search',

    hasOverlay: false,
    searchStyle: TextStyle(
    fontSize: 18,
    color: Colors.black.withOpacity(0.8),
    ))

                ),Stack(
    children: <Widget> [
                  Container(height: 250, width: MediaQuery.of(context).size.width-200,
                      padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-400, 20,0, 0),decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent)),
                      child: SearchField(
                          suggestions: mapData.map((e) =>
                              SearchFieldListItem(e.name)).toList(),
                          suggestionState: Suggestion.expand,
                          textInputAction: TextInputAction.next,
                          hint: 'Municipality ',
                          hasOverlay: false,
                          searchStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.black.withOpacity(0.8),
                          )),

                  ),
      Container(height: 250, width: MediaQuery.of(context).size.width-400,
        padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width-600, 20,20, 0),decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent)),
        child: SearchField(
            suggestions: mapData.map((e) =>
                SearchFieldListItem(e.name)).toList(),
            suggestionState: Suggestion.expand,
            textInputAction: TextInputAction.next,
            hint: 'Municipality ',
            hasOverlay: false,
            searchStyle: TextStyle(
              fontSize: 18,
              color: Colors.black.withOpacity(0.8),
            )),

      )])]),Container(height: 50, width: 900 , alignment: Alignment.bottomRight,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent)),
                  child: ElevatedButton(
                  child: Text("Compare"),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                  ),
                  onPressed: () {_loadCSV;},
                )


              ), Expanded(child: SizedBox(
                    height: 200,
                child: ListView.builder(
                    itemCount: _data.length,
                    shrinkWrap: true,
                    itemBuilder: (_, index){

                return Card(
                  margin: const EdgeInsets.all(3),
                  color: index == 0? Colors.amber : Colors.white,
                  child: ListTile(
                    leading: Text(_data[index][0].toString()),
                    title: Text(_data[index][1]),
                    trailing: Text(_data[index][2].toString())
              ),
                );
               },
              ),)),
              Container(height: 346, width: MediaQuery.of(context).size.width, alignment: Alignment.bottomLeft,
                  padding: EdgeInsets.fromLTRB(0, 20,600, 0),
                  decoration: BoxDecoration(

                  border: Border.all(color: Colors.blueAccent)),
              child:
              SfMaps(
                layers: [
                  MapShapeLayer(source: shapeSource,
                    showDataLabels: false,
                    dataLabelSettings: MapDataLabelSettings(
                        textStyle: TextStyle(
                            color: Colors.transparent)),
                    shapeTooltipBuilder: (BuildContext context, int index){
                      return Padding(padding: EdgeInsets.all(7),
                          child: Text(mapData[index].name,
                            style: TextStyle(color: Colors.white),
                          )
                      );
                    },
                    tooltipSettings:
                    MapTooltipSettings(color: Colors.blue),

                  )
                ],
              ))]





          ),

        );



      /*
        body: Padding(
            padding: EdgeInsets.fromLTRB(0,0, 0,0),
            child: Column(
              children: [ Container(height:35, width: MediaQuery.of(context).size.width ,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border.all(width: 45.0, color: Colors.black),

                    ),
                    child: Text('  Danish Municipalities',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25, height:1.5)),

                  )),Container(height: 100), Container(height: 300,
                  child: SfMaps(
                    layers: [
                      MapShapeLayer(source: shapeSource,
                        showDataLabels: false,
                        dataLabelSettings: MapDataLabelSettings(
                            textStyle: TextStyle(
                                color: Colors.transparent)),
                        color: Colors.white,
                        shapeTooltipBuilder: (BuildContext context, int index){
                          return Padding(padding: EdgeInsets.all(7),
                              child: Text(mapData[index].name,
                                style: TextStyle(color: Colors.white),
                              )
                          );
                        },
                        tooltipSettings:
                        MapTooltipSettings(color: Colors.blue),

                      )
                    ],
                  )),

              ],)),*/

  }
}
