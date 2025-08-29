import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IpSettingsScreen extends StatefulWidget {
  const IpSettingsScreen({Key? key}) : super(key: key);

  @override
  State<IpSettingsScreen> createState() => _IpSettingsScreenState();
}

class _IpSettingsScreenState extends State<IpSettingsScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  String _currentIp = '';
  String _currentPort = '5000';
  bool _isLoading = false;

  // Predefined IP addresses for quick selection
  final List<Map<String, String>> _presetIps = [
    {'name': 'Local (localhost)', 'ip': '127.0.0.1', 'port': '5000'},
    {'name': 'Local Network', 'ip': '192.168.1.100', 'port': '5000'},
    {'name': 'Public Server', 'ip': '', 'port': '5000'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString('server_ip') ?? '127.0.0.1';
    final savedPort = prefs.getString('server_port') ?? '5000';

    setState(() {
      _currentIp = savedIp;
      _currentPort = savedPort;
      _ipController.text = savedIp;
      _portController.text = savedPort;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (_ipController.text.isEmpty) {
      _showSnackBar('Please enter an IP address', isError: true);
      return;
    }

    if (_portController.text.isEmpty) {
      _showSnackBar('Please enter a port number', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_ip', _ipController.text.trim());
      await prefs.setString('server_port', _portController.text.trim());

      setState(() {
        _currentIp = _ipController.text.trim();
        _currentPort = _portController.text.trim();
      });

      _showSnackBar('Settings saved successfully!');
    } catch (e) {
      _showSnackBar('Failed to save settings: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectPresetIp(Map<String, String> preset) async {
    setState(() {
      _ipController.text = preset['ip']!;
      _portController.text = preset['port']!;
    });

    if (preset['ip']!.isNotEmpty) {
      await _saveSettings();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Server Settings'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Settings Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings_ethernet,
                                  color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              const Text(
                                'Current Server',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.computer, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'http://$_currentIp:$_currentPort',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Manual Input Section
                  const Text(
                    'Manual Configuration',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // IP Address Input
                  TextField(
                    controller: _ipController,
                    decoration: InputDecoration(
                      labelText: 'IP Address',
                      hintText: 'e.g., 192.168.1.100 or your-domain.com',
                      prefixIcon: const Icon(Icons.language),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.url,
                  ),

                  const SizedBox(height: 16),

                  // Port Input
                  TextField(
                    controller: _portController,
                    decoration: InputDecoration(
                      labelText: 'Port',
                      hintText: 'e.g., 5000',
                      prefixIcon: const Icon(Icons.settings_input_antenna),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 20),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Settings',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Quick Presets Section
                  const Text(
                    'Quick Presets',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Preset Options
                  ..._presetIps
                      .map((preset) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Icon(
                                  preset['name']!.contains('Local')
                                      ? Icons.home
                                      : Icons.cloud,
                                  color: Colors.blue[600],
                                ),
                              ),
                              title: Text(
                                preset['name']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: preset['ip']!.isNotEmpty
                                  ? Text('${preset['ip']}:${preset['port']}')
                                  : const Text('Enter your public IP above'),
                              trailing: preset['ip']!.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios),
                                      onPressed: () => _selectPresetIp(preset),
                                    )
                                  : null,
                              onTap: preset['ip']!.isNotEmpty
                                  ? () => _selectPresetIp(preset)
                                  : null,
                            ),
                          ))
                      .toList(),

                  const SizedBox(height: 24),

                  // Help Text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Tips',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '• Use 127.0.0.1 or localhost for local testing\n'
                          '• Use your computer\'s local IP (192.168.x.x) for same network access\n'
                          '• Use your public IP or domain for remote access\n'
                          '• Make sure the server is running and accessible',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }
}

// Utility class for getting the current server configuration
class ServerConfig {
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('server_ip') ?? '127.0.0.1';
    final port = prefs.getString('server_port') ?? '5000';
    return 'http://$ip:$port';
  }

  static Future<String> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_ip') ?? '127.0.0.1';
  }

  static Future<String> getServerPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_port') ?? '5000';
  }
}
