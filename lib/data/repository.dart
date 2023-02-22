import 'dart:ffi';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import '../models/municipality_model.dart';
import 'dart:async';


class Repository {

  late final List<List<dynamic>> myData;

  //remember to await this method call
  Future<void> loadCSV(String csvPath) async{


    //var att = ["OptOmrNr","Optagelsesområder","optagne","standby","total","1. prioritet","kvote 1 kvotient","standby"];

    var list = await parseCSV(csvPath);
    if(list != null){
      myData = list;
    }else{
      myData = [];
      print("Something went wrong - try picking a different .csv file");
    }

  }

  void printAllData() => print(myData);

  //----Testing----
  void printKU() => print(myData[0]);
  void print2D() => print(myData[2][3]);
  void printCPHS(){
    var aux = myData.where((row) => row[3] == 'København S'); //remove whitespace
    print(aux);
  }
  //---------------

  /*
  We have to make sure that the csv files:
  - Align in format
  - Use the same delimiters
  - Has the correct attributes (optional)
  - Contains no redundant entities
  - No whitespace (to ease querying data)
  - No null values

  Code is inspired by Abhay Rastogi' article on csv files in Flutter:
  https://codesearchonline.com/read-and-write-csv-file-in-flutter-web-mobile/
   */
  Future<List<List<dynamic>>?> parseCSV(String csvPath, [List<String>? attributes])async{

    try{

      //create string from csv file
      String csvAsString = await rootBundle.loadString(csvPath);

      //remove whitespace (" København K" -> "København K")
      String trimmed = csvAsString.replaceAll("; ", ";");
      trimmed = trimmed.replaceAll(" ;", ";");

      //replace delimiter
      trimmed.replaceAll(',', ';');

      //Create 2D List of csv
      var listData = CsvToListConverter(fieldDelimiter: ';').convert(trimmed);

      //check list is not empty
      if(listData.isEmpty){
        throw Exception("empty csv");
      }

      // Remove all null rows, if any
      listData.removeWhere((element) => element==null);

      //remove all null attributes of each row - HERE WE HAVE TO DO SOMETHING WITH THE EMPTY VALUES??? BUT WHAT
      //listData.forEach((element) {element.removeWhere((att) => att == null);});

      //remove duplicate rows
      listData.toSet().toList();

      //check that the csv file has the correct attributes
      if(attributes!=null){
        if(listData[0].toString().hashCode != attributes.toString().hashCode){
          throw Exception("the specified file does not contain the expected attributes");
        }
        //check that each row align with the amount of attributes
        print(listData.length);
        listData.removeWhere((element) => element.length != attributes.length);
        print(listData.length);
      }

      return listData;

    } on Exception catch (e){
        print(e.toString());
        return null;
    }


  }

}