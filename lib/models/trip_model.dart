class TripModel {
  final String from;
  final String to;
  final bool returnFlight;
  final bool useExactDates;
  final DateTime? startDate;
  final DateTime? endDate;
  final int dateFlexibility;
  final String? selectedWhen;
  final DateTime? startMonth;
  final DateTime? endMonth;
  final String? selectedDuration;
  final int stayValue;
  final double stayFlexibility;
  final double budgetAmount;

  TripModel({
    required this.from,
    required this.to,
    required this.returnFlight,
    required this.useExactDates,
    required this.startDate,
    required this.endDate,
    required this.dateFlexibility,
    required this.selectedWhen,
    required this.startMonth,
    required this.endMonth,
    required this.selectedDuration,
    required this.stayValue,
    required this.stayFlexibility,
    required this.budgetAmount,
  });
}
