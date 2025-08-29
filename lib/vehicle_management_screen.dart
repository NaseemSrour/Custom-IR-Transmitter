import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ip_settings_screen.dart';
import 'functions.dart' as Functions;

class VehicleManagementScreen extends StatefulWidget {
  @override
  _VehicleManagementScreenState createState() =>
      _VehicleManagementScreenState();
}

class _VehicleManagementScreenState extends State<VehicleManagementScreen> {
  String? baseUrl;
  bool isLoading = true;
  List<Map<String, dynamic>> allVehicles = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBaseUrl();
  }

  Future<void> _loadBaseUrl() async {
    final url = await ServerConfig.getBaseUrl();
    setState(() {
      baseUrl = url;
      isLoading = false;
    });
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    if (baseUrl == null) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Get vehicles inside and outside
      final insideResponse =
          await http.get(Uri.parse('$baseUrl/vehicles/inside'));
      final outsideResponse =
          await http.get(Uri.parse('$baseUrl/vehicles/outside'));

      if (insideResponse.statusCode == 200 &&
          outsideResponse.statusCode == 200) {
        final insideVehicles =
            List<Map<String, dynamic>>.from(json.decode(insideResponse.body));
        final outsideVehicles =
            List<Map<String, dynamic>>.from(json.decode(outsideResponse.body));

        // Add status to each vehicle
        for (var vehicle in insideVehicles) {
          vehicle['status'] = 'inside';
        }
        for (var vehicle in outsideVehicles) {
          vehicle['status'] = 'outside';
        }

        setState(() {
          allVehicles = [...insideVehicles, ...outsideVehicles];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load vehicles';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _updateVehicleOwner(String plateNumber, String ownerName) async {
    if (baseUrl == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vehicle/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'license_plate': plateNumber,
          'owner_name': ownerName,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully updated $plateNumber')),
        );
        _loadVehicles(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update vehicle')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showEditDialog(Map<String, dynamic> vehicle) {
    final TextEditingController controller = TextEditingController(
      text: vehicle['owner_name'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Owner for ${vehicle['plate_number']}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Owner Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateVehicleOwner(
                  vehicle['plate_number'], controller.text.trim());
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Vehicle Management')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadVehicles,
          ),
        ],
      ),
      body: errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(errorMessage, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadVehicles,
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          : allVehicles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No vehicles found', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadVehicles,
                  child: ListView.builder(
                    itemCount: allVehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = allVehicles[index];
                      final isInside = vehicle['status'] == 'inside';

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                isInside ? Colors.green : Colors.orange,
                            child: Icon(
                              isInside ? Icons.home : Icons.exit_to_app,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            vehicle['plate_number'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle['owner_name']?.isEmpty ?? true
                                    ? 'No owner assigned'
                                    : '${vehicle['owner_name']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: vehicle['owner_name']?.isEmpty ?? true
                                      ? Colors.grey
                                      : null,
                                ),
                              ),
                              Text(
                                'Status: ${isInside ? 'Inside' : 'Outside'}',
                                style: TextStyle(
                                  color:
                                      isInside ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Last seen: ${Functions.formatDateString(vehicle['last_seen_at'])}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showEditDialog(vehicle),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
