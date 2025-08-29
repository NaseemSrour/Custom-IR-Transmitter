import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:remote_ir/functions.dart' as Functions;
import 'package:remote_ir/vehicle_history_screen.dart';
import 'package:remote_ir/vehicle_management_screen.dart';
import 'ip_settings_screen.dart'; // Added import for IP settings screen

class LPRDashboardScreen extends StatefulWidget {
  const LPRDashboardScreen({Key? key}) : super(key: key);

  @override
  State<LPRDashboardScreen> createState() => _LPRDashboardScreenState();
}

class _LPRDashboardScreenState extends State<LPRDashboardScreen> {
  // API Configuration - Update with your Flask server URL
  String? baseUrl; // Store the loaded URL
  bool isLoadingUrl = true; // Track URL loading state

  // State variables
  List<Map<String, dynamic>> todaysEvents = [];
  List<Map<String, dynamic>> vehiclesInside = [];
  bool isLoading = true;
  String? errorMessage;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
    /*
    // Auto-refresh every 30 seconds
    refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchDashboardData();
    });
    */
  }

  Future<void> _loadBaseUrl() async {
    final url = await ServerConfig.getBaseUrl();
    setState(() {
      baseUrl = url;
      isLoadingUrl = false;
    });
    // Now load dashboard data with the loaded URL
    fetchDashboardData();
    // Auto-refresh every 30 seconds
    refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      fetchDashboardData();
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  // Fetch all dashboard data
  Future<void> fetchDashboardData() async {
    if (baseUrl == null) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await Future.wait([
        fetchTodaysEvents(),
        fetchVehiclesInside(),
      ]);
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load dashboard data: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch today's events from /events/today
  Future<void> fetchTodaysEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/events/today'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        todaysEvents = data.cast<Map<String, dynamic>>();
      });
    } else {
      throw Exception('Failed to load today\'s events');
    }
  }

  // Fetch vehicles currently inside from /vehicles/inside
  Future<void> fetchVehiclesInside() async {
    final response = await http.get(Uri.parse('$baseUrl/vehicles/inside'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        vehiclesInside = data.cast<Map<String, dynamic>>();
      });
    } else {
      throw Exception('Failed to load vehicles inside');
    }
  }

  // Update vehicle owner name via /vehicles/update
  Future<void> updateVehicleOwner(String licensePlate, String ownerName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vehicle/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'license_plate': licensePlate,
          'owner_name': ownerName,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated owner for $licensePlate'),
            backgroundColor: Colors.green,
          ),
        );
        fetchVehiclesInside(); // Refresh the list
      } else {
        throw Exception('Failed to update vehicle owner');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating vehicle: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Show dialog to edit vehicle owner
  void showEditOwnerDialog(String licensePlate, String? currentOwner) {
    final TextEditingController controller =
        TextEditingController(text: currentOwner ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Owner for $licensePlate'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Owner Name',
              hintText: 'Enter owner name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                updateVehicleOwner(licensePlate, controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LPR Dashboard'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.car_rental),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => VehicleHistoryScreen())),
          ),
          IconButton(
            icon: Icon(Icons.manage_accounts),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => VehicleManagementScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IpSettingsScreen()),
            ),
            tooltip: 'Server Settings',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchDashboardData,
          ),
        ],
      ),
      body: isLoadingUrl
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading server configuration...'),
                ],
              ),
            )
          : isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, size: 64, color: Colors.red[400]),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: fetchDashboardData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchDashboardData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Vehicles Currently Inside Section
                            _buildSectionHeader(
                              'Currently Inside',
                              vehiclesInside.length,
                              Colors.green,
                            ),
                            const SizedBox(height: 12),
                            vehiclesInside.isEmpty
                                ? _buildEmptyState('No vehicles inside')
                                : Column(
                                    children: vehiclesInside
                                        .map((vehicle) => VehicleCard(
                                              vehicle: vehicle,
                                              onEditOwner: () =>
                                                  showEditOwnerDialog(
                                                vehicle['plate_number'],
                                                vehicle['owner_name'],
                                              ),
                                            ))
                                        .toList(),
                                  ),

                            const SizedBox(height: 32),

                            // Today's Events Section
                            _buildSectionHeader(
                              'Today\'s Events',
                              todaysEvents.length,
                              Colors.blue,
                            ),
                            const SizedBox(height: 12),
                            todaysEvents.isEmpty
                                ? _buildEmptyState('No events today')
                                : Column(
                                    children: todaysEvents
                                        .map((event) => EventCard(event: event))
                                        .toList(),
                                  ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                title.contains('Inside') ? Icons.location_on : Icons.event,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Vehicle Card Widget
class VehicleCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback onEditOwner;

  const VehicleCard({
    Key? key,
    required this.vehicle,
    required this.onEditOwner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String licensePlate = vehicle['plate_number'] ?? 'Unknown Plate Num';
    final String? ownerName = vehicle['owner_name'];
    final String lastSeen =
        vehicle['last_seen_at'] ?? 'Unknown Vehicle Last Event';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),

              // Vehicle info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      licensePlate,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (ownerName != null && ownerName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        ownerName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Last seen: ' + Functions.formatDateString(lastSeen),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Edit button
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onEditOwner,
                tooltip: 'Edit Owner',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Event Card Widget
class EventCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventCard({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String licensePlate = event['plate_number'] ?? 'Unknown Plate';
    final String eventType = event['event_type'] ?? 'unknown event type';
    final String timestamp = event['timestamp'] ?? 'Unknown Owner';
    final String? ownerName = event['owner_name'];

    final bool isEntry = eventType.toLowerCase() == 'entry';
    final Color eventColor = isEntry ? Colors.green : Colors.orange;
    final IconData eventIcon = isEntry ? Icons.login : Icons.logout;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Event type indicator
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: eventColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  eventIcon,
                  color: eventColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),

              // Event info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          licensePlate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: eventColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: eventColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            eventType.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: eventColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (ownerName != null && ownerName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        ownerName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      Functions.formatDateString(timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
