import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Color getPriceColor(double price, double budget) {
    if (price <= budget) return Colors.green;
    if (price <= budget * 1.1) return Colors.orange;
    return Colors.red;
  }

  String getPriceLabel(double price, double budget) {
    if (price <= budget) return "In budget";
    if (price <= budget * 1.1) return "Close to budget";
    return "Cheapest available";
  }

  @override
  Widget build(BuildContext context) {
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.account_circle,
                              color: Colors.white, size: 32),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                        ),
                      ],
                    ),
                  ),
                ),
                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/images/logos/a_bientot_full_logo.png',
                            height: 100,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "We'll let you know when it's time to go!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Saved Trips',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // First Trip
                        Card(
                          color: Colors.white,
                          child: ListTile(
                            title: const Text("London → Ibiza"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("June, 3 nights"),
                                Text(
                                  getPriceLabel(89, 100),
                                  style:
                                      TextStyle(color: getPriceColor(89, 100)),
                                ),
                              ],
                            ),
                            trailing: Text(
                              "£89",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: getPriceColor(89, 100),
                              ),
                            ),
                          ),
                        ),

                        // Second Trip
                        Card(
                          color: Colors.white,
                          child: ListTile(
                            title: const Text("Paris → Mykonos"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("July, 1 week"),
                                Text(
                                  getPriceLabel(230, 210),
                                  style:
                                      TextStyle(color: getPriceColor(230, 210)),
                                ),
                              ],
                            ),
                            trailing: Text(
                              "£230",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: getPriceColor(230, 210),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/new-trip'),
        label: const Text("Add a trip"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
      ),
    );
  }
}
