import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/trip_model.dart';
import '../services/data_service.dart';
import '../services/flight_checker.dart';

class NewTripFormPage extends StatefulWidget {
  const NewTripFormPage({super.key});

  @override
  State<NewTripFormPage> createState() => _NewTripFormPageState();
}

// Updated _NewTripFormPageState class (replace your existing one)
class _NewTripFormPageState extends State<NewTripFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _dataService = DataService();

  String? fromCode;
  String? toCode;
  double budgetAmount = 0;
  bool returnFlight = true;
  DateTime? startDate;
  DateTime? endDate;
  int dateFlexibility = 0;

  String tripTiming = 'Exact Dates';
  DateTime? startMonth;
  DateTime? endMonth;

  String selectedDuration = 'Days';
  int stayValue = 1;
  int stayFlexibility = 0;

  List<DateTime> monthOptions = List.generate(
    18,
    (i) => DateTime(DateTime.now().year, DateTime.now().month + i, 1),
  );

  // New dropdown options for date flexibility
  final List<int> flexibilityOptions = [0, 1, 2, 3, 4, 5];

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }

  void _onMonthTapped(DateTime tappedMonth) {
    if (startMonth == null || (startMonth != null && endMonth != null)) {
      setState(() {
        startMonth = tappedMonth;
        endMonth = null;
      });
    } else if (startMonth != null && endMonth == null) {
      if (tappedMonth.isBefore(startMonth!)) {
        setState(() {
          endMonth = startMonth;
          startMonth = tappedMonth;
        });
      } else {
        setState(() {
          endMonth = tappedMonth;
        });
      }
    }
  }

  bool _isMonthInRange(DateTime m) {
    if (startMonth != null && endMonth != null) {
      return !m.isBefore(startMonth!) && !m.isAfter(endMonth!);
    }
    return false;
  }

  List<Widget> _buildMonthGroups() {
    final grouped = <int, List<DateTime>>{};
    for (final month in monthOptions) {
      final year = month.year;
      grouped.putIfAbsent(year, () => []).add(month);
    }

    return grouped.entries.map((entry) {
      final year = entry.key;
      final months = entry.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "$year",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          GridView.builder(
            itemCount: months.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6, // Changed from 3 to 6 for smaller containers
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1.5, // More square aspect ratio
            ),
            itemBuilder: (context, index) {
              final month = months[index];
              final isSelected = month == startMonth || month == endMonth;
              final inRange = _isMonthInRange(month);

              // Hide month if it's in range and not an endpoint
              if (inRange && !isSelected) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () => _onMonthTapped(month),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue
                        : inRange
                            ? Colors.blue.shade100
                            : Colors.grey.shade200,
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat.MMM().format(
                        month), // Changed to MMM for shorter month names
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:
            const Text("New Trip Alert", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child:
                Image.asset('assets/images/bg_new_trip.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    // Combined From/To/One Way container
                    _whiteCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTypeAheadField(
                                  label: "From",
                                  controller: _fromController,
                                  onSelected: (code) => fromCode = code,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTypeAheadField(
                                  label: "To",
                                  controller: _toController,
                                  onSelected: (code) => toCode = code,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text("One Way?"),
                              Switch(
                                value: returnFlight,
                                onChanged: (val) {
                                  setState(() => returnFlight = val);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Trip timing selection
                    _whiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("When?"),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              'Exact Dates',
                              'Within Dates',
                              'Within Months'
                            ].map((option) {
                              final isSelected = tripTiming == option;
                              return Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected
                                          ? Colors.blue
                                          : Colors.white,
                                      foregroundColor: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      side:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                    onPressed: () =>
                                        setState(() => tripTiming = option),
                                    child: Text(option),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                          if (tripTiming == 'Exact Dates' ||
                              tripTiming == 'Within Dates') ...[
                            ElevatedButton(
                              onPressed: () => _selectDateRange(context),
                              child: const Text("Select Date Range"),
                            ),
                            if (startDate != null && endDate != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  "From ${_formatDate(startDate!)} to ${_formatDate(endDate!)}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            if (tripTiming == 'Exact Dates') ...[
                              const SizedBox(height: 12),
                              const Text("Allow ± extra days"),
                              DropdownButtonFormField<int>(
                                value: dateFlexibility,
                                items: flexibilityOptions.map((value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(
                                        "$value day${value == 1 ? '' : 's'}"),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => dateFlexibility = val ?? 0),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                ),
                              ),
                            ]
                          ],
                          if (tripTiming == 'Within Months')
                            ..._buildMonthGroups(),
                        ],
                      ),
                    ),

                    // Rest of your existing code remains the same...
                    if (tripTiming != 'Exact Dates' && !returnFlight)
                      _whiteCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Trip Length"),
                            const SizedBox(height: 8),
                            Row(
                              children:
                                  ['Days', 'Weeks', 'Months'].map((label) {
                                final selected = selectedDuration == label;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: selected
                                            ? Colors.blue
                                            : Colors.white,
                                        foregroundColor: selected
                                            ? Colors.white
                                            : Colors.black,
                                        side: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      onPressed: () => setState(() {
                                        selectedDuration = label;
                                        stayValue = 1;
                                      }),
                                      child: Text(label),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<int>(
                              value: stayValue,
                              isExpanded: true,
                              items: List.generate(
                                selectedDuration == 'Days' ? 30 : 12,
                                (i) => DropdownMenuItem<int>(
                                  value: i + 1,
                                  child: Text(
                                      "${i + 1} ${selectedDuration.toLowerCase()}"),
                                ),
                              ),
                              onChanged: (val) =>
                                  setState(() => stayValue = val!),
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: stayFlexibility == 1,
                                  onChanged: (val) => setState(
                                      () => stayFlexibility = val! ? 1 : 0),
                                ),
                                const Text("Flexible?"),
                              ],
                            ),
                          ],
                        ),
                      ),

                    _whiteCard(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Budget (£)',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) => (val == null || val.isEmpty)
                            ? "Please enter a budget"
                            : null,
                        onChanged: (val) =>
                            budgetAmount = double.tryParse(val) ?? 0,
                      ),
                    ),

                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() &&
                            fromCode != null &&
                            toCode != null) {
                          final trip = TripModel(
                            from: fromCode!,
                            to: toCode!,
                            returnFlight: returnFlight,
                            useExactDates: tripTiming == 'Exact Dates',
                            startDate: startDate,
                            endDate: endDate,
                            dateFlexibility: dateFlexibility,
                            budgetAmount: budgetAmount,
                            stayValue: stayValue,
                            startMonth: startMonth,
                            endMonth: endMonth,
                            selectedWhen: tripTiming,
                            selectedDuration: selectedDuration,
                            stayFlexibility: stayFlexibility.toDouble(),
                          );

                          Provider.of<FlightChecker>(context, listen: false)
                              .addTrip(trip);

                          await FirebaseFirestore.instance
                              .collection('trips')
                              .add({
                            'from': fromCode,
                            'to': toCode,
                            'budget': budgetAmount,
                            'returnFlight': returnFlight,
                            'useExactDates': tripTiming == 'Exact Dates',
                            'startDate': startDate?.toIso8601String(),
                            'endDate': endDate?.toIso8601String(),
                            'dateFlexibility': dateFlexibility,
                            'stayValue': stayValue,
                            'startMonth': startMonth?.toIso8601String(),
                            'endMonth': endMonth?.toIso8601String(),
                            'selectedWhen': tripTiming,
                            'selectedDuration': selectedDuration,
                            'stayFlexibility': stayFlexibility.toDouble(),
                            'createdAt': Timestamp.now(),
                          });

                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Track This Trip"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Rest of your helper methods remain the same...
  Widget _buildTypeAheadField({
    required String label,
    required TextEditingController controller,
    required Function(String code) onSelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TypeAheadField<String>(
          suggestionsCallback: (pattern) async {
            return await _dataService.searchCities(pattern, 'airport');
          },
          itemBuilder: (context, suggestion) =>
              ListTile(title: Text(suggestion)),
          onSelected: (suggestion) {
            final match = RegExp(r'\((\w{3})\)\$').firstMatch(suggestion);
            controller.text = suggestion;
            onSelected(match?.group(1) ?? suggestion);
          },
          builder: (context, textEditingController, focusNode) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: "Type city, country, or airport",
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              validator: (val) =>
                  (val == null || val.isEmpty) ? "Required" : null,
            );
          },
        ),
      ],
    );
  }

  Widget _whiteCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: child,
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
