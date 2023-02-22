// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_client/data/repository.dart';

import 'package:github_client/main.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized(); //small fix for some async shit

    final repo = Repository();
    await repo.loadCSV("assets/hovedtal-2022uddCSV.csv");
    repo.printCPHS();

    final x = 1;
    final y = 2;

    expect(x, isNot(equals(y)));
}
