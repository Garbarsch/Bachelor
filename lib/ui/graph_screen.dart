
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
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:tuple/tuple.dart';

import '../bloc/graph_page_bloc.dart';



class MyGraphPage extends StatelessWidget {
  jsonRepository repo;
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

                    }

                    else {
                      print("HALLObøsse");
//ELSE
                      return const Text('Something went wrong');
                    }
                    print("her?");
                    return Text("go");
                  },
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
            onPressed: () {Navigator.of(context).push(MyGraphPage.route(context, repo))
            ;
            print(context.read<GraphPageBloc>().state);},

            )))


                ])));
  }
}

