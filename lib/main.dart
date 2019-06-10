import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:public_apis/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://api.publicapis.org",
  ));
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Public APIs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(
        dio: _dio,
      ),
    );
  }
}
