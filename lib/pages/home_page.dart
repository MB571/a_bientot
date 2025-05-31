import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/trip_model.dart';
import '../services/flight_checker.dart';
import 'new_trip_form_page.dart';
import 'login_page.dart';
import 'trip_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final flightChecker = Provider.of<FlightChecker>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/beach_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Foreground UI
          Positioned.fill(
            child: Column(
              children: [
                // AppBar with profile icon
                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48), // For balance
                        const Text(
                          'À Bientôt',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.account_circle,
                              color: Colors.white, size: 32),
                          onPressed: () {
                            if (user == null) {
                              Navigator.pushNamed(context, '/login');
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Profile'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: user.photoURL != null
                                            ? NetworkImage(user.photoURL!)
                                            : null,
                                        child: user.photoURL == null
                                            ? const Icon(Icons.person, size: 40)
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(user.email ?? 'No email'),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: () async {
                                          await FirebaseAuth.instance.signOut();
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Sign Out'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Main content
                Expanded(
                  child: flightChecker.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildTripList(context, flightChecker),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/new-trip'),
        label: const Text("Add Trip"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildTripList(BuildContext context, FlightChecker flightChecker) {
    if (flightChecker.trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No trips yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/new-trip'),
              child: const Text('Add your first trip'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => flightChecker.checkAllTrips(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Your Trips',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...flightChecker.trips.map((trip) => _buildTripCard(context, trip)),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripModel trip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => Navigator.pushNamed(
          context,
          '/trip-details',
          arguments: trip,
        ),
        title: Text("${trip.from} → ${trip.to}"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${trip.monthDisplay}, ${trip.durationDisplay}'),
            Text(
              trip.status,
              style: TextStyle(color: trip.statusColor),
            ),
          ],
        ),
        trailing: trip.bestFlight != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "£${trip.bestFlight!.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: trip.statusColor,
                    ),
                  ),
                  if (trip.lastChecked != null)
                    Text(
                      DateFormat('MMM d').format(trip.lastChecked!),
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
