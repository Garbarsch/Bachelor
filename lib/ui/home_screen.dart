import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_client/bloc/home_page_bloc.dart';
import 'package:github_client/models/municipality_model.dart';
import 'package:syncfusion_flutter_maps/maps.dart';


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: BlocBuilder<HomePageBloc, HomePageState>(
            builder: (context,state){
              if(state is HomePageInitial){ //HOMEPAGE
                return Padding(
                  padding: EdgeInsets.fromLTRB(0,0, 0,0),
                  child:
                  SfMaps(
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
              )
                );
              }
              if(state is homeLoadedGraph){ //LOADEDGRAPH
                  return const CircularProgressIndicator(color: Colors.orange,);

              } //ELSE
                return const CircularProgressIndicator(color: Colors.orange,);
            }



          ),

        )


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
    );
  }
}
