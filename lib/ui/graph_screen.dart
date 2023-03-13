import 'package:bulleted_list/bulleted_list.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:github_client/bloc/home_page_bloc.dart';
import 'package:github_client/data/csvRepository.dart';
import 'package:github_client/data/jsonRepository.dart';
import 'package:github_client/models/municipality_model.dart';
import 'package:github_client/models/query/query_model.dart';
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
  csvRepository csvRepo;
  List<String> selecteChoices = [];
  List<String> radioOptions = ["Entertainment", "Transportation", "Restaurants", "Education"]; //
  String choice = "Entertainment";
  List<Munidata> data = [];
  List<List<query_model>> querymodel = [];
  List<String> bullet1 = [];
  List<String> bullet2 = [];
  var a;
  MyGraphPage({
  super.key,
  required this.repo, required this.csvRepo, required BuildContext blocContext,
  //required this.shapeSource, required this.mapData,
  });

  
  static MaterialPageRoute<void> route(BuildContext context, jsonRepository repo, csvRepository csvRepo) => MaterialPageRoute(
    builder: (_) => MyGraphPage(blocContext: context, repo: repo, csvRepo: csvRepo,),
  );
  late queries query = queries(repo: repo, csvRepo: csvRepo );
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
                     querymodel = state.querymodel;
                    }

                    else {
                      return Text("hallo");



                    }
                    if(data.isEmpty){
                      if(state.querymodel.isNotEmpty){
                        if(state.type == "Education"){
                          return Positioned(top: 90, bottom: 10, left: 10,child: Container(height: MediaQuery.of(context).size.width -720, width: MediaQuery.of(context).size.width/1.35,
                              child: Stack(
                                children: [
                                  Positioned(top: 90, bottom: 10, left: 10,child: Container(height: MediaQuery.of(context).size.width -720, width: MediaQuery.of(context).size.width/1.35,
                                  child: SfCircularChart(
                                    title: ChartTitle(text: "Percentage of all danish educations available in each municipality"),
                                    legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                                    series: <CircularSeries>[
                                      RadialBarSeries<query_model,String>(
                                        dataSource: querymodel.first,
                                        xValueMapper: (query_model data, _) => data.x,
                                        yValueMapper: (query_model data,_) => data.percentage,
                                        dataLabelSettings: DataLabelSettings(isVisible: true),
                                        dataLabelMapper: (query_model data, _) => data.percentage.toString() + " %",
                                        radius: '35%',
                                        maximumValue: 100,
                                      )
                                    ],
                                  )
                                  )

                                  ),
                                ],


                              )));
                        }

                        if(state.querymodel.length>2) {
                          bullet1 = [];
                          bullet2 = [];
                          for (int i = 0; i < state.querymodel[2].length; i++) {
                            bullet1.add(state.querymodel[1][i].x + state
                                .querymodel[1][i].y.toString());
                            bullet2.add(state.querymodel[2][i].x + state
                                .querymodel[2][i].y.toString());
                          }
                        }
                        return Positioned(top: 90, bottom: 10, left: 10,child: Container(height: MediaQuery.of(context).size.width -720, width: MediaQuery.of(context).size.width/1,
                            child: Stack( children:[Positioned(left:MediaQuery.of(context).size.width-200,right: 10,top:
                                175,bottom: 10,child: Stack(children: [  Text(selecteChoices
                            .first),
                            BulletedList(listItems: bullet1, ), Positioned( top: 160,right:0,left:0,bottom:0,child: Stack( children:[ Text(selecteChoices.last),  BulletedList(listItems: bullet2, )]))])),Positioned(top: 10, child: Container(height: MediaQuery.of(context).size.width -720, width: MediaQuery.of(context).size.width/1.35, child: SfCartesianChart(

                                primaryXAxis: CategoryAxis(),
                                legend: Legend(
                                    isVisible: true,
                                    // Overflowing legend content will be wraped
                                    overflowMode: LegendItemOverflowMode.wrap
                                ),
                                title: ChartTitle(
                                    text: selecteChoices.first +" and "+ selecteChoices.last),
                                series:<ChartSeries<query_model, String>>


                                [ ColumnSeries<query_model,String>(dataSource: querymodel.first, xValueMapper: (query_model data,_) => data.x,yValueMapper: (query_model data,_) => data.y, legendItemText: selecteChoices.first ),
                                  ColumnSeries<query_model,String>(dataSource: querymodel.last, xValueMapper: (query_model data,_) => data.x,yValueMapper: (query_model data,_) => data.y,legendItemText: selecteChoices.last  )
                                ])))
                            ])));

                      }
                    return Positioned(top: 90, bottom: 10, left: 10,child: Container(height: MediaQuery.of(context).size.width -720, width: MediaQuery.of(context).size.width/1.35,
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
                      Container(height: MediaQuery.of(context).size.width ), Positioned(top: 50, bottom: MediaQuery.of(context).size.height-100, left: MediaQuery.of(context).size.width -120, right: 20 ,child: SizedBox(height: MediaQuery.of(context).size.width -500, width: MediaQuery.of(context).size.width/2,
    child:  ElevatedButton(

          child: Text('Go back', style: TextStyle(fontSize: 15.0),),
            onPressed: () {Navigator.of(context).push(MyHomePage.route(context, repo, csvRepo))
            ;
            print(context.read<GraphPageBloc>().state);},

            ))), Container(height: MediaQuery.of(context).size.width ), Positioned(top: 50, bottom: 520, left: 20, right: MediaQuery.of(context).size.width -263 ,child: SizedBox(height: MediaQuery.of(context).size.width -500, width: MediaQuery.of(context).size.width,
                      child:  DropDownMultiSelect(
                        options: (repo.relations.map((e) => e.name!).toList()),
                        selectedValues: selecteChoices,
                        onChanged: (List<String> value) {
                          selecteChoices = value;
                          print(selecteChoices);
                          print(choice);
                          if(value.length == 2) {
                            if (choice == "Transportation") {
                              context.read<GraphPageBloc>().add(
                                  updateGraph(
                                      data: [], querymodel:
                                    query.transportationQuery(value.first,
                                        value.last), type: "Transportation"

                                  ));
                            }
                            if (choice == "Entertainment") {
                              context.read<GraphPageBloc>().add(
                                  updateGraph(
                                      data: [], querymodel:
                                    query.entertainmentQuery( value.first,
                                        value.last),
                                        type: "Entertainment"
                                  ));
                            }
                            if (choice == "Restaurants") {
                              context.read<GraphPageBloc>().add(
                                  updateGraph(
                                      data: [], querymodel: query.foodQuery(
                                      value.first, value.last),
                                      type: "Restaurants"
                                  ));
                            }
                            if (choice == "Education") {
                              context.read<GraphPageBloc>().add(
                                  updateGraph(
                                      data: [], querymodel:
                                      query.educationOfferPercentageQuery(value.first,
                                      value.last), type: "Education"
                                  ));
                            }
                          }
                        },


                        whenEmpty:
                        'Choose filter',


                      ), )),
    Container(height: MediaQuery.of(context).size.width ), Positioned(top: 75, bottom: 350, left: MediaQuery.of(context).size.width -200,right: 10  ,child: SizedBox(height: MediaQuery.of(context).size.width -500, width: (MediaQuery.of(context).size.width/4)-30,
    child: CustomRadioButton( buttonTextStyle: const ButtonTextStyle(
          selectedColor: Colors.black,
          unSelectedColor: Colors.black,
          textStyle: TextStyle(
            fontSize: 12,
          ),
        ),
          unSelectedColor: Theme.of(context).canvasColor,
          buttonLables: radioOptions,
          buttonValues: radioOptions,
         defaultSelected: "Entertainment",
          radioButtonValue: (values) {
            if(selecteChoices.isNotEmpty) {
              if (values.toString() == "Entertainment") {
                context.read<GraphPageBloc>().add(
                    updateGraph(
                        data: [], querymodel: query.entertainmentQuery( selecteChoices.first,
                        selecteChoices.last),type: "Entertainment"));
              }
              if (values.toString() == "Transportation") {
                context.read<GraphPageBloc>().add(
                    updateGraph(
                        data: [], querymodel: query.transportationQuery(selecteChoices.first,
                        selecteChoices.last),type: "Transportation"));
              }
              if (values.toString() == "Restaurants") {
                context.read<GraphPageBloc>().add(
                    updateGraph(
                        data: [], querymodel: query.foodQuery(selecteChoices.first,
                        selecteChoices.last),type: "Restaurants"));
              }
              if (values.toString() == "Education") {
                context.read<GraphPageBloc>().add(
                    updateGraph(
                        data: [], querymodel: query.educationOfferPercentageQuery(selecteChoices.first,
                        selecteChoices.last),type: "Education"));
              }
            }

            choice = values.toString();
            print(choice);

          },
          spacing: 0,

      horizontal:true,
          enableButtonWrap: false,
          width: 120,

        height:30,
          absoluteZeroSpacing: false,
          selectedColor: Theme.of(context).accentColor,
          padding: 5,
        )),



                )])));
  }

}

