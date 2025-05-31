import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/trip_model.dart';
import '../services/flight_checker.dart';

class TripDetailsPage extends StatefulWidget {
  final TripModel trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  State<TripDetailsPage> createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  bool _isRefreshing = false;

  Future<void> _refreshFlights() async {
    setState(() => _isRefreshing = true);
    try {
      await Provider.of<FlightChecker>(context, listen: false)
          .checkAllTrips(context); // Changed from checkTrip to checkAllTrips
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final flightChecker = Provider.of<FlightChecker>(context);
    final trip = widget.trip;

    return Scaffold(
      appBar: AppBar(
        title: Text('${trip.from} → ${trip.to}'),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const CircularProgressIndicator()
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshFlights,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow('Dates', _formatDateRange(trip)),
                    _buildDetailRow(
                        'Trip Type', trip.returnFlight ? 'Return' : 'One Way'),
                    _buildDetailRow(
                        'Budget', '£${trip.budgetAmount.toStringAsFixed(2)}'),
                    if (trip.bestFlight !=
                        null) // Changed from bestPrice to bestFlight
                      _buildDetailRow(
                        'Best Price Found',
                        '£${trip.bestFlight!.price.toStringAsFixed(2)}', // Access price through bestFlight
                        color: trip.bestFlight!.price <= trip.budgetAmount
                            ? Colors.green
                            : Colors.orange,
                      ),
                    if (trip.lastChecked != null)
                      _buildDetailRow(
                        'Last Checked',
                        DateFormat('MMM d, h:mm a').format(trip.lastChecked!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Flight list
            if (flightChecker.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (trip.foundFlights?.isNotEmpty ?? false) ...[
              Text(
                'Available Flights',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ...trip.foundFlights!.map((flight) => FlightCard(
                    flight: flight,
                    budget: trip.budgetAmount,
                  )),
            ] else if (!flightChecker.isLoading) ...[
              const Center(
                child: Text('No flights found yet. Check back later!'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(TripModel trip) {
    final formatDay = DateFormat('MMM d');
    final formatMonth = DateFormat('MMM yyyy');

    if (trip.useExactDates) {
      if (trip.startDate != null) {
        if (trip.returnFlight && trip.endDate != null) {
          return '${formatDay.format(trip.startDate!)} - ${formatDay.format(trip.endDate!)}';
        }
        return formatDay.format(trip.startDate!);
      }
    } else {
      if (trip.startMonth != null) {
        if (trip.returnFlight && trip.endMonth != null) {
          return '${formatMonth.format(trip.startMonth!)} - ${formatMonth.format(trip.endMonth!)}';
        }
        return formatMonth.format(trip.startMonth!);
      }
    }
    return 'Flexible dates';
  }
}

class FlightCard extends StatelessWidget {
  final Flight flight;
  final double budget;

  const FlightCard({
    super.key,
    required this.flight,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${flight.airline} ${flight.flightNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '£${flight.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        flight.price <= budget ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Depart: ${flight.formattedDepartureDate}'),
            if (flight.returnDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Return: ${flight.formattedReturnDate}'),
              ),
            if (flight.deepLink != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _launchBooking(flight.deepLink!),
                  child: const Text('Book Now'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _launchBooking(String url) async {
    // TODO: Implement deep link launching
    // Example: await launchUrl(Uri.parse(url));
  }
}
