import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_functions/cloud_functions.dart';

class DataService {
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<List<String>> searchCities(String pattern, String type) async {
    pattern = pattern.trim();
    if (pattern.isEmpty) return [];

    try {
      print('📤 Sending query: "$pattern" ($type)');

      final result = await _functions
          .httpsCallable('searchAirports')
          .call({'query': pattern, 'type': type});

      print('📥 Received: ${result.data}');
      return List<String>.from(result.data);
    } catch (e) {
      print('❌ Firebase call error: $e');
      return [];
    }
  }

  Future<List<dynamic>> loadCities() async {
    final String response =
        await rootBundle.loadString('assets/data/cities.json');
    return json.decode(response);
  }

  Future<List<dynamic>> loadAirports() async {
    final String response =
        await rootBundle.loadString('assets/data/airports.json');
    return json.decode(response);
  }

  Future<List<dynamic>> loadAirlines() async {
    final String response =
        await rootBundle.loadString('assets/data/airlines.json');
    return json.decode(response);
  }
}
