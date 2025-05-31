import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // Add this for JSON handling

class TripModel {
  // Core Trip Information
  final String id;
  final String from;
  final String to;
  Map<String, dynamic> toJson() => toMap();
  final double budgetAmount;
  final DateTime createdAt;
  double? get bestPrice => bestFlight?.price;
  double get budgetAmountWithFlexibility =>
      budgetAmount * (1 + (stayFlexibility / 100));

  // Trip Type
  final bool returnFlight;

  // Date Configuration
  final bool useExactDates;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? startMonth;
  final DateTime? endMonth;
  final String? selectedWhen;
  final int dateFlexibility;

  // Duration Configuration
  final String selectedDuration;
  final int stayValue;
  final double stayFlexibility;

  // Flight Data
  final List<Flight>? foundFlights;
  final Flight? bestFlight;
  final DateTime? lastChecked;

  // Notifications
  final bool notificationsEnabled;
  final double? notificationThreshold;

  TripModel({
    // Core
    this.id = '',
    required this.from,
    required this.to,
    required this.budgetAmount,
    DateTime? createdAt,

    // Trip Type
    required this.returnFlight,

    // Dates
    required this.useExactDates,
    this.startDate,
    this.endDate,
    this.startMonth,
    this.endMonth,
    this.selectedWhen,
    this.dateFlexibility = 0,

    // Duration
    this.selectedDuration = 'Days',
    this.stayValue = 1,
    this.stayFlexibility = 0,

    // Flight Data
    this.foundFlights,
    this.bestFlight,
    this.lastChecked,

    // Notifications
    this.notificationsEnabled = true,
    this.notificationThreshold,
  }) : createdAt = createdAt ?? DateTime.now();

  /* ------------------------- */
  /* ---- Serialization ------ */
  /* ------------------------- */

  // Add this method for direct JSON string conversion
  factory TripModel.fromJson(String jsonString) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return TripModel.fromMap('', map);
  }

  // Add this method for direct JSON string output
  String toJsonString() => jsonEncode(toMap());

  Map<String, dynamic> toMap() {
    return {
      // Core
      'id': id,
      'from': from,
      'to': to,
      'budgetAmount': budgetAmount,
      'createdAt': createdAt.toIso8601String(),

      // Trip Type
      'returnFlight': returnFlight,

      // Dates
      'useExactDates': useExactDates,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'startMonth': startMonth?.toIso8601String(),
      'endMonth': endMonth?.toIso8601String(),
      'selectedWhen': selectedWhen,
      'dateFlexibility': dateFlexibility,

      // Duration
      'selectedDuration': selectedDuration,
      'stayValue': stayValue,
      'stayFlexibility': stayFlexibility,

      // Flight Data
      'foundFlights': foundFlights?.map((f) => f.toJson()).toList(),
      'bestFlight': bestFlight?.toJson(),
      'lastChecked': lastChecked?.toIso8601String(),

      // Notifications
      'notificationsEnabled': notificationsEnabled,
      'notificationThreshold': notificationThreshold,
    };
  }

  factory TripModel.fromMap(String id, Map<String, dynamic> map) {
    return TripModel(
      id: id,
      from: map['from'] ?? '',
      to: map['to'] ?? '',
      budgetAmount: (map['budgetAmount'] ?? 0).toDouble(),
      createdAt: _parseDateTime(map['createdAt']),
      returnFlight: map['returnFlight'] ?? true,
      useExactDates: map['useExactDates'] ?? false,
      startDate: _parseDateTime(map['startDate']),
      endDate: _parseDateTime(map['endDate']),
      startMonth: _parseDateTime(map['startMonth']),
      endMonth: _parseDateTime(map['endMonth']),
      selectedWhen: map['selectedWhen'],
      dateFlexibility: map['dateFlexibility'] ?? 0,
      selectedDuration: map['selectedDuration'] ?? 'Days',
      stayValue: map['stayValue'] ?? 1,
      stayFlexibility: (map['stayFlexibility'] ?? 0).toDouble(),
      foundFlights: _parseFlights(map['foundFlights']),
      bestFlight: map['bestFlight'] != null
          ? Flight.fromJson(map['bestFlight'] as Map<String, dynamic>)
          : null,
      lastChecked: _parseDateTime(map['lastChecked']),
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      notificationThreshold: (map['notificationThreshold'] as num?)?.toDouble(),
    );
  }

  /* ------------------------- */
  /* -------- Helpers -------- */
  /* ------------------------- */

  static DateTime? _parseDateTime(dynamic dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString as String);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return null;
    }
  }

  static List<Flight>? _parseFlights(dynamic flightsData) {
    if (flightsData == null || flightsData is! List) return null;
    return flightsData
        .whereType<Map<String, dynamic>>()
        .map((f) => Flight.fromJson(f))
        .toList();
  }

  /* ------------------------- */
  /* -------- Methods -------- */
  /* ------------------------- */

  TripModel copyWith({
    String? id,
    String? from,
    String? to,
    double? budgetAmount,
    bool? returnFlight,
    bool? useExactDates,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? startMonth,
    DateTime? endMonth,
    String? selectedWhen,
    int? dateFlexibility,
    String? selectedDuration,
    int? stayValue,
    double? stayFlexibility,
    List<Flight>? foundFlights,
    Flight? bestFlight,
    DateTime? lastChecked,
    bool? notificationsEnabled,
    double? notificationThreshold,
  }) {
    return TripModel(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      createdAt: createdAt,
      returnFlight: returnFlight ?? this.returnFlight,
      useExactDates: useExactDates ?? this.useExactDates,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth ?? this.endMonth,
      selectedWhen: selectedWhen ?? this.selectedWhen,
      dateFlexibility: dateFlexibility ?? this.dateFlexibility,
      selectedDuration: selectedDuration ?? this.selectedDuration,
      stayValue: stayValue ?? this.stayValue,
      stayFlexibility: stayFlexibility ?? this.stayFlexibility,
      foundFlights: foundFlights ?? this.foundFlights,
      bestFlight: bestFlight ?? this.bestFlight,
      lastChecked: lastChecked ?? this.lastChecked,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationThreshold:
          notificationThreshold ?? this.notificationThreshold,
    );
  }

  /* ------------------------- */
  /* ------ UI Getters ------- */
  /* ------------------------- */

  bool shouldNotify(double currentPrice) {
    if (!notificationsEnabled) return false;
    return currentPrice <= (notificationThreshold ?? budgetAmount);
  }

  String get routeDisplay => '$from → $to';

  String get durationDisplay {
    switch (selectedDuration) {
      case 'Days':
        return '$stayValue night${stayValue != 1 ? 's' : ''}';
      case 'Weeks':
        return '$stayValue week${stayValue != 1 ? 's' : ''}';
      case 'Months':
        return '$stayValue month${stayValue != 1 ? 's' : ''}';
      default:
        return '$stayValue day${stayValue != 1 ? 's' : ''}';
    }
  }

  String get dateRangeDisplay {
    if (useExactDates && startDate != null) {
      return returnFlight && endDate != null
          ? '${_formatDate(startDate!)} - ${_formatDate(endDate!)}'
          : _formatDate(startDate!);
    } else if (startMonth != null) {
      return returnFlight && endMonth != null
          ? '${_formatMonth(startMonth!)} - ${_formatMonth(endMonth!)}'
          : _formatMonth(startMonth!);
    }
    return 'Flexible dates';
  }

  String get monthDisplay {
    final date = startDate ?? startMonth;
    return date != null ? DateFormat('MMM').format(date) : '';
  }

  String get status {
    if (bestFlight == null) return 'Checking...';
    if (bestFlight!.price <= budgetAmount) return 'In budget';
    if (bestFlight!.price <= budgetAmount * 1.1) return 'Close to budget';
    return 'Expensive';
  }

  Color get statusColor {
    if (bestFlight == null) return Colors.grey;
    if (bestFlight!.price <= budgetAmount) return Colors.green;
    if (bestFlight!.price <= budgetAmount * 1.1) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);
  String _formatMonth(DateTime date) => DateFormat('MMM yyyy').format(date);
}

/* ------------------------- */
/* ----- Flight Model ------ */
/* ------------------------- */

class Flight {
  final String origin;
  final String destination;
  final DateTime departureDate;
  final DateTime? returnDate;
  final double price;
  final String airline;
  final String flightNumber;
  final String? deepLink;

  Flight({
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    required this.price,
    required this.airline,
    required this.flightNumber,
    this.deepLink,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      departureDate: DateTime.parse(json['departure_at']),
      returnDate:
          json['return_at'] != null ? DateTime.parse(json['return_at']) : null,
      price: (json['price'] ?? 0).toDouble(),
      airline: json['airline'] ?? 'Unknown',
      flightNumber: json['flight_number'] ?? '',
      deepLink: json['deep_link'],
    );
  }

  Map<String, dynamic> toJson() => {
        'origin': origin,
        'destination': destination,
        'departure_at': departureDate.toIso8601String(),
        'return_at': returnDate?.toIso8601String(),
        'price': price,
        'airline': airline,
        'flight_number': flightNumber,
        'deep_link': deepLink,
      };

  String get formattedDepartureDate =>
      DateFormat('EEE, MMM d').format(departureDate);
  String get formattedReturnDate => returnDate != null
      ? DateFormat('EEE, MMM d').format(returnDate!)
      : 'One Way';
  String get durationDisplay => returnDate != null
      ? '${returnDate!.difference(departureDate).inDays} days'
      : 'One way';
}
