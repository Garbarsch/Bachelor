import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:github_client/bloc/home_page_bloc.dart';
import 'package:github_client/data/jsonRepository.dart';
import 'package:github_client/models/municipality_model.dart';
import 'package:github_client/ui/home_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:multiselect/multiselect.dart';
import 'package:searchfield/searchfield.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:tuple/tuple.dart';
import 'package:awesome_select/awesome_select.dart';

import '../bloc/graph_page_bloc.dart';



class MyGraphPage extends StatelessWidget {
  jsonRepository repo;
  List<String> selecteChoices = [];
  List<String> radioOptions = ["Entertainment", "Transportation"];
  String choice = "Entertainment";
  List<Munidata> data = [];
  var a;
  MyGraphPage({
  super.key,
  required this.repo, required BuildContext blocContext,
  //required this.shapeSource, required this.mapData,
  });
  
  static MaterialPageRoute<void> route(BuildContext context, jsonRepository repo) => MaterialPageRoute(
    builder: (_) => MyGraphPage(blocContext: context, repo: repo),
  );


  @override
  Widget build(BuildContext context) {


    return Scaffold(
        body: Padding(
            padding: EdgeInsets.fromLTRB(0,0, 0,0),
            child: Stack(
                children: [ BlocBuilder<GraphPageBloc, GraphPageState>(
                  builder: (context,state) {
                    print("Jeg er her");
                    print(state);
                    if (state is HomePageInitial) { //HOMEPAGE
                      return const CircularProgressIndicator(color: Colors.blue);
                    }
                    if (state is graphLoaded) {
                      print("GraphLoaded og data");
                     data = state.muni;
                    }

                    else {
                      return Text("hallo");



                    }
                    if(data.isNotEmpty){
                      print(data.last.value);
                    return Positioned(top: 75, bottom: 10, left: 10,child: Container(height: MediaQuery.of(context).size.width -700, width: MediaQuery.of(context).size.width/4,
                    child: SfCartesianChart( primaryXAxis: CategoryAxis(),
                        series:<ChartSeries<Munidata, String>>

                    [ ColumnSeries<Munidata,String>(dataSource: data,xValueMapper: (Munidata data,_) => data.name.toString(),yValueMapper: (Munidata data,_) => data.value)
                    ])));
                  } else{
                      return const Text("Choose municipality");
                    }
    }
                ),

                  Container(height:35, width: MediaQuery.of(context).size.width ,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(width: 45.0, color: Colors.black),

                        ),
                        child: const Text('  Detailed Graph',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25, height:1.5)),

                      )),
                      Container(height: MediaQuery.of(context).size.width ), Positioned(top: 50, bottom: 520, left: MediaQuery.of(context).size.width -120, right: 20 ,child: SizedBox(height: MediaQuery.of(context).size.width -500, width: MediaQuery.of(context).size.width/2,
    child:  ElevatedButton(

          child: Text('Go back', style: TextStyle(fontSize: 15.0),),
            onPressed: () {Navigator.of(context).push(MyHomePage.route(context, repo))
            ;
            print(context.read<GraphPageBloc>().state);},

            ))), Container(height: MediaQuery.of(context).size.width ), Positioned(top: 50, bottom: 520, left: 20, right: MediaQuery.of(context).size.width -263 ,child: SizedBox(height: MediaQuery.of(context).size.width -500, width: MediaQuery.of(context).size.width,
                      child:  DropDownMultiSelect(
                        options: (repo.relations.map((e) => e.name!).toList()),
                        selectedValues: selecteChoices,
                        onChanged: (List<String> value) {
                          selecteChoices = value;
                          print(selecteChoices);
                          context.read<GraphPageBloc>().add(
                              updateGraph(data: repo.getCafeForMuni(value.last)));
                        },


                        whenEmpty:
                        'Choose filter',


                      ), )),
    Container(height: MediaQuery.of(context).size.width ), Positioned(top: 100, bottom: 420, left: MediaQuery.of(context).size.width -263, right:20  ,child: SizedBox(height: MediaQuery.of(context).size.width -500, width: MediaQuery.of(context).size.width,
    child: Column(
      children: [Radio<String>(
    value: radioOptions.first,
    groupValue: choice,
    onChanged: (String? value) {
    },
    ),
    Radio<String>(

    value: radioOptions[1],
    groupValue: choice,

    onChanged: (String? value) {
      print(value);
      choice = value!;

    },
    ),



                ])))])));
  }

}

