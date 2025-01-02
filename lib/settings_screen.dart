import 'package:flutter/material.dart';
import 'config.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController(text: Config.apiUrl);
  final TextEditingController _merchantIdController = TextEditingController(text: Config.merchantId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(labelText: 'API URL'),
            ),
            TextField(
              controller: _merchantIdController,
              decoration: InputDecoration(labelText: 'Merchant ID'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Config.updateApiUrl(_urlController.text);
                await Config.updateMerchantId(_merchantIdController.text);
                setState(() {});
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}