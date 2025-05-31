import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/trip_model.dart';
import 'flight_api_service.dart';
import 'notification_service.dart';
import 'dart:convert'; // For jsonEncode and jsonDecode

class FlightChecker with ChangeNotifier {
  final FlightApiService _apiService;
  final NotificationService _notificationService;
  final List<TripModel> _trips = [];
  bool _isLoading = false;

  FlightChecker(this._apiService, this._notificationService);

  List<TripModel> get trips => List.unmodifiable(_trips);
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    await _loadTrips();
  }

  Future<void> _loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripsJson = prefs.getStringList('tracked_trips');
    if (tripsJson != null) {
      _trips.clear();
      _trips.addAll(
        tripsJson.map((jsonString) {
          final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
          return TripModel.fromMap('', jsonMap);
        }),
      );
      notifyListeners();
    }
  }

  Future<void> _saveTrips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'tracked_trips',
      _trips.map((trip) => jsonEncode(trip.toJson())).toList(),
    );
  }

  Future<void> addTrip(TripModel trip) async {
    _trips.add(trip);
    notifyListeners();
    await _saveTrips();
    await _checkAndUpdateTrip(trip);
  }

  Future<void> removeTrip(String tripId) async {
    _trips.removeWhere((t) => t.id == tripId);
    notifyListeners();
    await _saveTrips();
  }

  Future<void> checkAllTrips([BuildContext? context]) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      for (final trip in _trips) {
        await _checkAndUpdateTrip(trip, context);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkAndUpdateTrip(TripModel trip,
      [BuildContext? context]) async {
    try {
      final flights = await _apiService.getBestFlight(
        origin: trip.from,
        destination: trip.to,
        monthYear: _formatMonthYear(trip.startDate ?? trip.startMonth!),
      );

      if (flights != null) {
        final updatedTrip = trip.copyWith(
          bestFlight: flights,
          lastChecked: DateTime.now(),
        );

        final index = _trips.indexWhere((t) => t.id == trip.id);
        if (index != -1) {
          _trips[index] = updatedTrip;
          notifyListeners();
          await _saveTrips();
        }

        if (updatedTrip.shouldNotify(flights.price)) {
          await _notificationService.showNotification(
            title: '✈️ Deal! ${trip.from} → ${trip.to}',
            body:
                '£${flights.price.toStringAsFixed(2)} (budget: £${trip.budgetAmount.toStringAsFixed(2)})',
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking trip ${trip.id}: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking ${trip.from} → ${trip.to}')),
        );
      }
    }
  }

  String _formatMonthYear(DateTime date) => DateFormat('yyyy-MM').format(date);
}
