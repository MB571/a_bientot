import 'package:flutter/foundation.dart';
import '../models/trip_model.dart';

class TripProvider with ChangeNotifier {
  final List<TripModel> _trips = [];

  List<TripModel> get trips => List.unmodifiable(_trips);

  void addTrip(TripModel trip) {
    _trips.add(trip);
    notifyListeners();
  }

  void removeTrip(int index) {
    if (index >= 0 && index < _trips.length) {
      _trips.removeAt(index);
      notifyListeners();
    }
  }

  void clearTrips() {
    _trips.clear();
    notifyListeners();
  }
}
