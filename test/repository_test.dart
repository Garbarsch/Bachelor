

import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/data/repository.dart';

void main() async{
  TestWidgetsFlutterBinding.ensureInitialized();


  var repo = new Repository();
  await repo.loadCSV("assets/hovedtal-2022uddCSV.csv");

  //print(repo.myData.first);
  //print(repo.myData[1]);
  //print(repo.myData[2]);
  repo.myData.forEach((element) {print(element);});

}