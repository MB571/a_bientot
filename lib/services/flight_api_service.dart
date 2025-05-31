import 'dart:convert'; // Add this import for jsonDecode
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For debugPrint
import '../models/trip_model.dart'; // For Flight class

class FlightApiService {
  static const String _baseUrl = 'https://api.travelpayouts.com/aviasales/v3';
  final String _apiKey;

  FlightApiService(this._apiKey);

  Future<Flight?> getBestFlight({
    required String origin,
    required String destination,
    required String monthYear, // Format: "yyyy-MM"
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/prices_for_dates').replace(queryParameters: {
          'origin': origin,
          'destination': destination,
          'currency': 'GBP',
          'month': monthYear,
          'limit': '1', // Fixed typo - was 'l' instead of '1'
          'sorting': 'price',
        }),
        headers: {'X-Access-Token': _apiKey},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is List && (data['data'] as List).isNotEmpty) {
          return Flight.fromJson((data['data'] as List).first);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Flight API Error: $e'); // Fixed typo - was debugFLight
      return null;
    }
  }
}
