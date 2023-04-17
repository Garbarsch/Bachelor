import 'package:bulleted_list/bulleted_list.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_client/bloc/home_page_bloc.dart';
import 'package:github_client/data/csvRepository.dart';
import 'package:github_client/data/jsonRepository.dart';
import 'package:github_client/models/query/query_model.dart';
import 'package:github_client/ui/home_screen.dart';
import 'package:multiselect/multiselect.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  });

  
  static MaterialPageRoute<void> route(BuildContext context, jsonRepository repo, csvRepository csvRepo) => MaterialPageRoute(
    builder: (_) => MyGraphPage(blocContext: context, repo: repo, csvRepo: csvRepo,),
  );
  late queriesGrid query = queriesGrid(repo, csvRepo);
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Padding(
            padding: EdgeInsets.fromLTRB(0,0, 0,0),
            child: Stack(
                children: [ BlocBuilder<GraphPageBloc, GraphPageState>(
                  builder: (context,state) {
                    if (state is HomePageInitial) { //HOMEPAGE
                      return const CircularProgressIndicator(color: Colors.blue);
                    }
                    if (state is graphLoaded) {
                     data = state.muni;
                     querymodel = state.querymodel;
                    }

                    else {
                      return Text("hallo");
                    }
                    if(data.isEmpty){
                      if(state.querymodel.isNotEmpty){
                        if(state.type == "Education"){
                          return Positioned(top: 90, bottom: 10, left: 10,child: Container(height: MediaQuery.of(context).size.width -720, width: MediaQuery.of(context).size.width,
                              child: Stack(
                                children: [Positioned(left:MediaQuery.of(context).size.width-200,right: 10,top:
                                150,bottom: 10,child: Stack(children: [  Text(selecteChoices
                                    .first),
                                  BulletedList(listItems: bullet1, ), Positioned( top: 170,right:0,left:0,bottom:0,child: Stack( children:[ Text(selecteChoices.last),  BulletedList(listItems: bullet2, )]))])),
                                  Positioned(top: 40, bottom: MediaQuery.of(context).size.height/2.2, left: 10,child: Container(height: MediaQuery.of(context).size.width -720, width: MediaQuery.of(context).size.width/1.35,
                                  child: Stack(
                                    children: [
                                      Positioned(top: 0, bottom: 0, left: 10, right: 100,child: Container(height: MediaQuery.of(context).size.width -720, width: MediaQuery.of(context).size.width/1.35,
                                          child: SfCartesianChart(
                                            title: ChartTitle(text: "Applier Distribution"),
                                            legend: Legend(isVisible: true),
                                            tooltipBehavior: TooltipBehavior(enable: true),
                                            series: <ChartSeries>[
                                              LineSeries<query_model,String>(
                                                name: querymodel[0].isEmpty ? "(No schools in dataset)" : querymodel[0].first.municipality,
                                                dataSource: querymodel[0],
                                                xValueMapper: (query_model data, _) => data.x,
                                                yValueMapper: (query_model data,_) => data.percentage,
                                                dataLabelSettings: DataLabelSettings(isVisible: true),
                                                enableTooltip: true,
                                                dataLabelMapper: (query_model data, _) => data.percentage.toStringAsFixed(2) + " %",


                                              ),
                                              LineSeries<query_model,String>(
                                                name: querymodel[1].isEmpty ?  "(No schools in dataset)" : querymodel[1].last.municipality,
                                                dataSource: querymodel[1],
                                                xValueMapper: (query_model data, _) => data.x,
                                                yValueMapper: (query_model data,_) => data.percentage,
                                                dataLabelSettings: DataLabelSettings(isVisible: true),
                                                enableTooltip: true,
                                                dataLabelMapper: (query_model data, _) => data.percentage.toStringAsFixed(2) + " %",


                                              )
                                            ],
                                            primaryXAxis: CategoryAxis(
                                              majorGridLines: MajorGridLines(width: 0),
                                              maximumLabelWidth: 80,
                                            ),

                                          )
                                      )

                                      ),
                                    ],


                                  ))),
                                  Positioned(top: MediaQuery.of(context).size.height/2.2, bottom: 10, left: 10,child: Container(height: MediaQuery.of(context).size.height/3, width: MediaQuery.of(context).size.width/3,
                                  child: SfCircularChart(
                                    title: ChartTitle(text: "Percentage of all danish educations available in each municipality"),
                                    legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                                    tooltipBehavior: TooltipBehavior(enable: true),
                                    series: <CircularSeries>[
                                      RadialBarSeries<query_model,String>(
                                        dataSource: querymodel[2],
                                        xValueMapper: (query_model data, _) => data.x,
                                        yValueMapper: (query_model data,_) => data.percentage,
                                        dataLabelSettings: DataLabelSettings(isVisible: true),
                                        dataLabelMapper: (query_model data, _) => data.percentage.toString() + " %",
                                        enableTooltip: true,
                                        radius: '70%',
                                        maximumValue: 100,
                                      )
                                    ],
                                  )
                                  )

                                  ),
                                  Positioned(top: MediaQuery.of(context).size.height/2.2, bottom: 10, left: MediaQuery.of(context).size.width/3, right: 150,child: Container(height: MediaQuery.of(context).size.height/3, width: MediaQuery.of(context).size.width/1.35,
                                      child: SfCartesianChart(
                                        title: ChartTitle(text: "Applicant information"),
                                        legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
                                        tooltipBehavior: TooltipBehavior(enable: true),
                                        primaryXAxis: CategoryAxis(
                                          maximumLabelWidth: 80
                                        ),
                                        series: <CartesianSeries>[
                                          ColumnSeries<query_model,String>(
                                            name: "Applicants",
                                            dataSource: querymodel[3],
                                            xValueMapper: (query_model data, _) => data.x,
                                            yValueMapper: (query_model data,_) => data.y,
                                              enableTooltip: true,
                                              legendItemText: "Applicants"
                                          ),
                                          ColumnSeries<query_model,String>(
                                            name:"Accepted applicants",
                                            dataSource: querymodel[3],
                                            xValueMapper: (query_model data, _) => data.x,
                                            yValueMapper: (query_model data,_) => data.y2,
                                              enableTooltip: true,
                                              legendItemText: "Accepted applicants"
                                          ),ColumnSeries<query_model,String>(
                                            name:"Applicants per 10.000 resident",
                                            dataSource: querymodel[3],
                                            xValueMapper: (query_model data, _) => data.x,
                                            yValueMapper: (query_model data,_) => data.y3,
                                              enableTooltip: true,
                                              legendItemText: "Applicants per 10.000 resident"
                                          ),

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
                        return Positioned(top: 90, bottom: 0, left: 10,child: Container(height: MediaQuery.of(context).size.width -720, width: MediaQuery.of(context).size.width,
                            child: Stack( children:[Positioned(left:MediaQuery.of(context).size.width-200,right: 10,top:
                                150,bottom: 10,child: Stack(children: [  Text(selecteChoices
                            .first),
                            BulletedList(listItems: bullet1, ), Positioned( top: 170,right:0,left:0,bottom:0,child: Stack( children:[ Text(selecteChoices.last),  BulletedList(listItems: bullet2, )]))])),Positioned(top: 10,bottom: 0, child: Container(height: MediaQuery.of(context).size.width -720, width: MediaQuery.of(context).size.width/1.35, child: SfCartesianChart(

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
                                  ColumnSeries<query_model,String>(dataSource: querymodel.last, xValueMapper: (query_model data,_) => data.x,yValueMapper: (query_model data,_) => data.y,legendItemText: selecteChoices.last,  )
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

            ))), Container(height: MediaQuery.of(context).size.height ), Positioned(top:10 , bottom: MediaQuery.of(context).size.height-150, left: 20, right: MediaQuery.of(context).size.width -263 ,child: SizedBox(height: MediaQuery.of(context).size.width -500, width: MediaQuery.of(context).size.width,
                      child:  DropDownMultiSelect(
                        options: (repo.relations.map((e) => e.name!).toList()),
                        selectedValues: selecteChoices,
                        onChanged: (List<String> value) {
                          selecteChoices = value;
                          //print(selecteChoices);
                          //print(choice);
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
                                      query.educationQuery(value.first,
                                      value.last), type: "Education"
                                  ));

                            }

                          }
                        },


                        whenEmpty:
                        'Choose filter',


                      ), )),  Positioned(top: 55, bottom: MediaQuery.of(context).size.height-95, left:10 ,right: MediaQuery.of(context).size.width/8 ,
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
                        data: [], querymodel:
                    query.educationQuery(selecteChoices.first,
                        selecteChoices.last), type: "Education"
                    ));
              }
            }

            choice = values.toString();
            //print(choice);

          },
          spacing: 0,

      horizontal:false,
          enableButtonWrap: false,
          width: 100,

        height:30,
          absoluteZeroSpacing: false,
          selectedColor: Theme.of(context).accentColor,
          padding: 5,
        )),



                ])));
  }

}

