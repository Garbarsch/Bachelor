

import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/data/repository.dart';

void main() async{
  TestWidgetsFlutterBinding.ensureInitialized();


  var repo = new Repository();
  await repo.loadCSVFiles("assets/hovedtal-2022uddCSV.csv", "assets/SchoolAddresses.csv");
  repo.printAllSchoolInfo();
}