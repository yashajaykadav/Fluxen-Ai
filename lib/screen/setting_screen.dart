import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = const FlutterSecureStorage();
  final _apiKeyController = TextEditingController();
  
  String _selectedModel = 'nvidia/nemotron-3-super-120b-a12b:free';
  bool _useVectorDb = true;

  final List<String> _availableModels = [
    'nvidia/nemotron-3-super-120b-a12b:free',
    'google/gemini-pro-1.5-exp',
    'meta-llama/llama-3-70b-instruct:free',
    'mistralai/mistral-7b-instruct:free',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = await _storage.read(key: 'openrouter_api_key');
    
    setState(() {
      _apiKeyController.text = savedKey ?? "";
      _selectedModel = prefs.getString('selected_model') ?? _availableModels[0];
      _useVectorDb = prefs.getBool('use_vector_db') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save Key Securely
    await _storage.write(key: 'openrouter_api_key', value: _apiKeyController.text);
    
    // Save Preferences
    await prefs.setString('selected_model', _selectedModel);
    await prefs.setBool('use_vector_db', _useVectorDb);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Settings saved successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("AI Configuration"),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "OpenRouter API Key",
              hintText: "Enter your sk-or-v1...",
              border: OutlineInputBorder(),
              helperText: "Stored securely in system Keystore/Keychain",
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _selectedModel,
            decoration: const InputDecoration(
              labelText: "Default AI Model",
              border: OutlineInputBorder(),
            ),
            items: _availableModels.map((m) => DropdownMenuItem(
              value: m,
              child: Text(m, overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (val) => setState(() => _selectedModel = val!),
          ),
          
          const Divider(height: 40),
          _buildSectionHeader("Memory & Vector DB"),
          SwitchListTile(
            title: const Text("Enable Long-term Memory"),
            subtitle: const Text("Uses ObjectBox Vector DB to store document context"),
            value: _useVectorDb,
            onChanged: (val) => setState(() => _useVectorDb = val),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50]),
            onPressed: () {
              // Placeholder for ObjectBox clear logic
            },
            child: const Text("Clear Vector Database", style: TextStyle(color: Colors.red)),
          ),
          
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text("Save Changes"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }
}