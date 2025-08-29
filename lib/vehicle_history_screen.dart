import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ip_settings_screen.dart';

class VehicleHistoryScreen extends StatefulWidget {
  @override
  _VehicleHistoryScreenState createState() => _VehicleHistoryScreenState();
}

class _VehicleHistoryScreenState extends State<VehicleHistoryScreen> {
  String? baseUrl;
  bool isLoading = true;
  List<String> availablePlates = [];
  String? selectedPlate;
  List<Map<String, dynamic>> events = [];
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
    _loadAvailablePlates();
  }

  Future<void> _loadAvailablePlates() async {
    if (baseUrl == null) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Get all vehicles (inside and outside)
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

        final allVehicles = [...insideVehicles, ...outsideVehicles];
        final plates = allVehicles
            .map((v) => v['plate_number'] as String)
            .toSet()
            .toList();
        plates.sort();

        setState(() {
          availablePlates = plates;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load available plates';
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

  Future<void> _loadVehicleHistory(String plateNumber) async {
    if (baseUrl == null) return;

    setState(() {
      isLoading = true;
      errorMessage = '';
      events = [];
    });

    try {
      final response =
          await http.get(Uri.parse('$baseUrl/vehicle/$plateNumber'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          events = List<Map<String, dynamic>>.from(data['events']);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load vehicle history';
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

  Widget _buildEventCard(Map<String, dynamic> event) {
    final isEntry = event['event_type'] == 'entry';
    final timestamp = DateTime.parse(event['timestamp']);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isEntry ? Colors.green : Colors.red,
          child: Icon(
            isEntry ? Icons.login : Icons.logout,
            color: Colors.white,
          ),
        ),
        title: Text(
          isEntry ? 'Entry' : 'Exit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isEntry ? Colors.green : Colors.red,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'),
            if (event['confidence'] != null)
              Text('Confidence: ${event['confidence'].toStringAsFixed(1)}%'),
            if (event['owner_name']?.isNotEmpty ?? false)
              Text('Owner: ${event['owner_name']}'),
          ],
        ),
        trailing: event['filename'] != null
            ? Chip(
                label: Text('IMG', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.blue.withOpacity(0.1),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && availablePlates.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Vehicle History')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle History'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAvailablePlates,
          ),
        ],
      ),
      body: Column(
        children: [
          // Plate selector
          Container(
            padding: EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select License Plate',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              value: selectedPlate,
              items: availablePlates.map((plate) {
                return DropdownMenuItem(
                  value: plate,
                  child: Text(plate),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPlate = value;
                });
                if (value != null) {
                  _loadVehicleHistory(value);
                }
              },
            ),
          ),

          // Events list
          Expanded(
            child: errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(errorMessage, style: TextStyle(fontSize: 16)),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: selectedPlate != null
                              ? () => _loadVehicleHistory(selectedPlate!)
                              : _loadAvailablePlates,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : selectedPlate == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Select a license plate to view history',
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      )
                    : isLoading
                        ? Center(child: CircularProgressIndicator())
                        : events.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history,
                                        size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text('No events found for $selectedPlate',
                                        style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: events.length,
                                itemBuilder: (context, index) =>
                                    _buildEventCard(events[index]),
                              ),
          ),
        ],
      ),
    );
  }
}
